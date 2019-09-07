import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rate_my_app/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Allows to kindly ask users to rate your app if custom conditions are met (eg. install time, number of launches, etc...).
class RateMyApp {
  static const MethodChannel _CHANNEL = const MethodChannel('rate_my_app');

  /// Prefix for preferences.
  String preferencesPrefix;

  /// Minimum days before being able to show the dialog.
  int minDays;

  /// Minimum launches before being able to show the dialog.
  int minLaunches;

  /// Days to add to the base date when the user clicks on "Maybe later".
  int remindDays;

  /// Launches to subtract to the number of launches when the user clicks on "Maybe later".
  int remindLaunches;

  /// The google play identifier.
  String googlePlayIdentifier;

  /// The app store identifier.
  String appStoreIdentifier;

  /// The base launch date.
  DateTime baseLaunchDate;

  /// Number of launches.
  int launches;

  /// Whether the dialog should not be opened again.
  bool doNotOpenAgain;

  /// Creates a new rate my app instance.
  RateMyApp({
    this.preferencesPrefix = 'rateMyApp_',
    this.minDays = 7,
    this.minLaunches = 10,
    this.remindDays = 7,
    this.remindLaunches = 10,
    this.googlePlayIdentifier,
    this.appStoreIdentifier,
  });

  /// Initializes the plugin (loads base launch date, app launches and whether the dialog should not be opened again).
  Future<void> init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    baseLaunchDate = DateTime.fromMillisecondsSinceEpoch(preferences.getInt(preferencesPrefix + 'baseLaunchDate') ?? DateTime.now().millisecondsSinceEpoch);
    launches = (preferences.getInt(preferencesPrefix + 'launches') ?? 0) + 1;
    doNotOpenAgain = preferences.getBool(preferencesPrefix + 'doNotOpenAgain') ?? false;
    await save();
  }

  /// Saves the plugin current data to the shared preferences.
  Future<void> save() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt(preferencesPrefix + 'baseLaunchDate', baseLaunchDate.millisecondsSinceEpoch);
    await preferences.setInt(preferencesPrefix + 'launches', launches);
    await preferences.setBool(preferencesPrefix + 'doNotOpenAgain', doNotOpenAgain);
  }

  /// Resets the plugin data.
  Future<void> reset() async {
    baseLaunchDate = DateTime.now();
    launches = 0;
    doNotOpenAgain = false;
    await save();
  }

  /// Whether the dialog should be opened.
  bool get shouldOpenDialog => !doNotOpenAgain && (DateTime.now().millisecondsSinceEpoch - baseLaunchDate.millisecondsSinceEpoch) / (1000 * 60 * 60 * 24) >= minDays && launches >= minLaunches;

  /// Returns the corresponding store identifier.
  String get storeIdentifier => Platform.isIOS ? appStoreIdentifier : googlePlayIdentifier;

  /// Shows the rate dialog.
  Future<void> showRateDialog(
    BuildContext context, {
    String title = 'Rate this app',
    TextAlign titleAlign = TextAlign.left,
    String message = 'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
    TextAlign messageAlign = TextAlign.left,
    String rateButton = 'RATE',
    String noButton = 'NO THANKS',
    String laterButton = 'MAYBE LATER',
    bool ignoreIOS = false,
    EdgeInsetsGeometry titlePadding,
    EdgeInsetsGeometry contentPadding,
    TextStyle buttonTextStyle,
  }) async {
    if (!ignoreIOS && Platform.isIOS && await _CHANNEL.invokeMethod('canRequestReview')) {
      return _CHANNEL.invokeMethod('requestReview');
    }
    return RateMyAppDialog.openDialog(context, this, title, titleAlign, message, messageAlign, rateButton, noButton, laterButton, titlePadding, contentPadding, buttonTextStyle);
  }

  /// Shows the star rate dialog.
  Future<void> showStarRateDialog(
    BuildContext context, {
    String title = 'Rate this app',
    TextAlign titleAlign = TextAlign.center,
    String message = 'You like this app ? Then take a little bit of your time to leave a rating :',
    TextAlign messageAlign = TextAlign.center,
    @required List<Widget> Function(double) onRatingChanged,
    bool ignoreIOS = false,
    StarRatingOptions starRatingOptions = const StarRatingOptions(),
  }) async {
    if (!ignoreIOS && Platform.isIOS && await _CHANNEL.invokeMethod('canRequestReview')) {
      return _CHANNEL.invokeMethod('requestReview');
    }

    assert(onRatingChanged != null);
    assert(starRatingOptions != null);
    return RateMyAppStarDialog.openDialog(context, title, titleAlign, message, messageAlign, onRatingChanged, starRatingOptions);
  }

  /// Launches the corresponding store.
  Future<void> launchStore() => RateMyApp._CHANNEL.invokeMethod('launchStore', {
        'appId': storeIdentifier,
      });
}

/// Just a little class that allows to customize some rating bar options.
class StarRatingOptions {
  /// The fill color of the stars.
  final Color starsFillColor;

  /// The border color for the stars.
  final Color starsBorderColor;

  /// The stars size.
  final double starsSize;

  /// The space between two stars.
  final double starsSpacing;

  /// The initial rating.
  final double initialRating;

  /// Whether we allow half-stars ratings.
  final bool allowHalfRating;

  /// Creates a new star rating options instance.
  const StarRatingOptions({
    this.starsFillColor = Colors.orangeAccent,
    this.starsBorderColor = Colors.orangeAccent,
    this.starsSize = 40,
    this.starsSpacing = 0,
    this.initialRating,
    this.allowHalfRating = false,
  });
}
