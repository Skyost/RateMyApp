import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rate_my_app/src/conditions.dart';
import 'package:rate_my_app/src/dialogs.dart';
import 'package:rate_my_app/src/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Allows to kindly ask users to rate your app if custom conditions are met (eg. install time, number of launches, etc...).
class RateMyApp {
  /// The plugin channel.
  static const MethodChannel _channel = MethodChannel('rate_my_app');

  /// Prefix for preferences.
  String preferencesPrefix;

  /// The google play identifier.
  String googlePlayIdentifier;

  /// The app store identifier.
  String appStoreIdentifier;

  /// All conditions that should be met to show the dialog.
  List<Condition> conditions;

  /// Creates a new Rate my app instance.
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

  /// Creates a new Rate my app instance with custom conditions.
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

    return callEvent(RateMyAppEventType.initialized);
  }

  /// Saves the plugin current data to the shared preferences.
  Future<void> save() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    for (Condition condition in conditions) {
      await condition.saveToPreferences(preferences);
    }

    return callEvent(RateMyAppEventType.saved);
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
    DialogContentBuilder contentBuilder,
    DialogActionsBuilder actionsBuilder,
    String rateButton,
    String noButton,
    String laterButton,
    RateMyAppDialogButtonClickListener listener,
    bool ignoreIOS = false,
    DialogStyle dialogStyle,
    VoidCallback onDismissed,
  }) async {
    if (!ignoreIOS && Platform.isIOS && await _channel.invokeMethod('canRequestReview')) {
      unawaited(callEvent(RateMyAppEventType.iOSRequestReview));
      return _channel.invokeMethod('requestReview');
    }

    unawaited(callEvent(RateMyAppEventType.dialogOpen));
    RateMyAppDialogButton clickedButton = await showDialog<RateMyAppDialogButton>(
      context: context,
      builder: (context) => RateMyAppDialog(
        this,
        title: title ?? 'Rate this app',
        message: message ?? 'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
        contentBuilder: contentBuilder ?? ((context, defaultContent) => defaultContent),
        actionsBuilder: actionsBuilder,
        rateButton: rateButton ?? 'RATE',
        noButton: noButton ?? 'NO THANKS',
        laterButton: laterButton ?? 'MAYBE LATER',
        listener: listener,
        dialogStyle: dialogStyle ?? const DialogStyle(),
      ),
    );

    if (clickedButton == null && onDismissed != null) {
      onDismissed();
    }
  }

  /// Shows the star rate dialog.
  Future<void> showStarRateDialog(
    BuildContext context, {
    String title,
    String message,
    DialogContentBuilder contentBuilder,
    StarDialogActionsBuilder actionsBuilder,
    bool ignoreIOS = false,
    DialogStyle dialogStyle,
    StarRatingOptions starRatingOptions,
    VoidCallback onDismissed,
  }) async {
    if (!ignoreIOS && Platform.isIOS && await _channel.invokeMethod('canRequestReview')) {
      unawaited(callEvent(RateMyAppEventType.iOSRequestReview));
      return _channel.invokeMethod('requestReview');
    }

    assert(actionsBuilder != null);
    unawaited(callEvent(RateMyAppEventType.starDialogOpen));

    RateMyAppDialogButton clickedButton = await showDialog(
      context: context,
      builder: (context) => RateMyAppStarDialog(
        this,
        title: title ?? 'Rate this app',
        message: message ?? 'You like this app ? Then take a little bit of your time to leave a rating :',
        contentBuilder: contentBuilder ?? ((context, defaultContent) => defaultContent),
        actionsBuilder: actionsBuilder,
        dialogStyle: dialogStyle ??
            const DialogStyle(
              titleAlign: TextAlign.center,
              messageAlign: TextAlign.center,
              messagePadding: EdgeInsets.only(bottom: 20),
            ),
        starRatingOptions: starRatingOptions ?? const StarRatingOptions(),
      ),
    );

    if (clickedButton == null && onDismissed != null) {
      onDismissed();
    }
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

/// Represents all events that can occur during the Rate my app lifecycle.
enum RateMyAppEventType {
  /// When Rate my app is fully initialized.
  initialized,

  /// When Rate my app is saved.
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
