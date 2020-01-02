import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rate_my_app/src/conditions.dart';
import 'package:rate_my_app/src/dialogs.dart';
import 'package:rate_my_app/src/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Allows to kindly ask users to rate your app if custom conditions are met (eg. install time, number of launches, etc...).
class RateMyApp {
  /// The plugin channel.
  static const MethodChannel _channel = const MethodChannel('rate_my_app');

  /// Prefix for preferences.
  String preferencesPrefix;

  /// The google play identifier.
  String googlePlayIdentifier;

  /// The app store identifier.
  String appStoreIdentifier;

  /// All conditions that should be met to show the dialog.
  List<Condition> conditions;

  /// Creates a new rate my app instance.
  RateMyApp({
    this.preferencesPrefix = 'rateMyApp_',
    int minDays,
    int remindDays,
    int minLaunches,
    int remindLaunches,
    this.googlePlayIdentifier,
    this.appStoreIdentifier,
  })  : conditions = [],
        assert(preferencesPrefix != null) {
    populateWithDefaultConditions(
      minDays: minDays,
      remindDays: remindDays,
      minLaunches: minLaunches,
      remindLaunches: remindLaunches,
    );
  }

  /// Creates a new rate my app instance with custom conditions.
  RateMyApp.customConditions({
    this.preferencesPrefix = 'rateMyApp_',
    this.googlePlayIdentifier,
    this.appStoreIdentifier,
    @required this.conditions,
  })  : assert(preferencesPrefix != null),
        assert(conditions != null);

  /// Initializes the plugin (loads base launch date, app launches and whether the dialog should not be opened again).
  Future<void> init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    conditions.forEach((condition) => condition.readFromPreferences(preferences));

    callEvent(RateMyAppEventType.initialized);
  }

  /// Saves the plugin current data to the shared preferences.
  Future<void> save() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    for (Condition condition in conditions) {
      await condition.saveToPreferences(preferences);
    }

    callEvent(RateMyAppEventType.saved);
  }

  /// Resets the plugin data.
  Future<void> reset() async {
    conditions.forEach((condition) => condition.reset());
    await save();
  }

  /// Whether the dialog should be opened.
  bool get shouldOpenDialog => conditions.firstWhere((condition) => !condition.isMet, orElse: () => null) == null;

  /// Returns the corresponding store identifier.
  String get storeIdentifier {
    if (Platform.isIOS) {
      return appStoreIdentifier;
    }

    if (Platform.isAndroid) {
      return googlePlayIdentifier;
    }

    return null;
  }

  /// Shows the rate dialog.
  Future<void> showRateDialog(
    BuildContext context, {
    String title,
    String message,
    String rateButton,
    String noButton,
    String laterButton,
    RateMyAppDialogButtonClickListener listener,
    bool ignoreIOS = false,
    DialogStyle dialogStyle,
  }) async {
    if (!ignoreIOS && Platform.isIOS && await _channel.invokeMethod('canRequestReview')) {
      callEvent(RateMyAppEventType.iOSRequestReview);
      return _channel.invokeMethod('requestReview');
    }

    callEvent(RateMyAppEventType.dialogOpen);
    return RateMyAppDialog.openDialog(
      context,
      this,
      title: title ?? 'Rate this app',
      message: message ?? 'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
      rateButton: rateButton ?? 'RATE',
      noButton: noButton ?? 'NO THANKS',
      laterButton: laterButton ?? 'MAYBE LATER',
      listener: listener,
      dialogStyle: dialogStyle ?? DialogStyle(),
    );
  }

  /// Shows the star rate dialog.
  Future<void> showStarRateDialog(
    BuildContext context, {
    String title,
    String message,
    List<Widget> Function(double) onRatingChanged,
    bool ignoreIOS = false,
    DialogStyle dialogStyle,
    StarRatingOptions starRatingOptions,
  }) async {
    if (!ignoreIOS && Platform.isIOS && await _channel.invokeMethod('canRequestReview')) {
      callEvent(RateMyAppEventType.iOSRequestReview);
      return _channel.invokeMethod('requestReview');
    }

    assert(onRatingChanged != null);
    callEvent(RateMyAppEventType.starDialogOpen);
    return RateMyAppStarDialog.openDialog(
      context,
      this,
      title: title ?? 'Rate this app',
      message: message ?? 'You like this app ? Then take a little bit of your time to leave a rating :',
      onRatingChanged: onRatingChanged,
      dialogStyle: dialogStyle ??
          DialogStyle(
            titleAlign: TextAlign.center,
            messageAlign: TextAlign.center,
            messagePadding: EdgeInsets.only(bottom: 20),
          ),
      starRatingOptions: starRatingOptions ?? StarRatingOptions(),
    );
  }

  /// Launches the corresponding store.
  Future<void> launchStore() => RateMyApp._channel.invokeMethod('launchStore', {
        'appId': storeIdentifier,
      });

  /// Calls the specified event.
  Future<void> callEvent(RateMyAppEventType eventType) {
    bool saveSharedPreferences = false;
    conditions.forEach((condition) => saveSharedPreferences = condition.onEventOccurred(eventType) || saveSharedPreferences);
    return saveSharedPreferences ? save() : null;
  }

  /// Adds the default conditions to the current conditions list.
  void populateWithDefaultConditions({
    int minDays,
    int remindDays,
    int minLaunches,
    int remindLaunches,
  }) {
    conditions.add(MinimumDaysCondition(
      this,
      minDays: minDays ?? 7,
      remindDays: remindDays ?? 7,
    ));
    conditions.add(MinimumAppLaunchesCondition(
      this,
      minLaunches: minLaunches ?? 10,
      remindLaunches: remindLaunches ?? 10,
    ));
    conditions.add(DoNotOpenAgainCondition(this));
  }
}

/// Represents all events that can occur during the rate my app lifecycle.
enum RateMyAppEventType {
  /// When rate my app is fully initialized.
  initialized,

  /// When rate my app is saved.
  saved,

  /// When a native iOS rating dialog will be opened.
  iOSRequestReview,

  /// When the classic Rate my app dialog will be opened.
  dialogOpen,

  /// When the star dialog will be opened.
  starDialogOpen,

  /// When the rate button has been pressed.
  rateButtonPressed,

  /// When the later button has been pressed.
  laterButtonPressed,

  /// When the no button has been pressed.
  noButtonPressed,
}
