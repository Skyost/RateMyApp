import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_review/app_review.dart';

/// Allows to kindly ask users to rate your app if custom conditions are met (eg. install time, number of launches, etc...).
class RateMyApp {
  // static const MethodChannel _channel = const MethodChannel('rate_my_app');

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

  /// The base launch date.
  DateTime baseLaunchDate;

  /// Number of launches.
  int launches;

  /// Whether the dialog should not be opened again.
  bool doNotOpenAgain;

  /// Creates a new rate my app instance.
  RateMyApp({
    this.preferencesPrefix = 'rateMyApp',
    this.minDays = 7,
    this.minLaunches = 10,
    this.remindDays = 7,
    this.remindLaunches = 10,
  });

  /// Initializes the plugin (loads base launch date, app launches and whether the dialog should not be opened again).
  Future<void> init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    baseLaunchDate = DateTime.fromMillisecondsSinceEpoch((preferences.getInt('baseLaunchDate') ?? DateTime.now().millisecondsSinceEpoch));
    launches = (preferences.getInt('launches') ?? 0) + 1;
    doNotOpenAgain = preferences.getBool('doNotOpenAgain') ?? false;
    await save();
  }

  /// Saves the plugin current data to the shared preferences.
  Future<void> save() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('baseLaunchDate', baseLaunchDate.millisecondsSinceEpoch);
    preferences.setInt('launches', launches);
    preferences.setBool('doNotOpenAgain', doNotOpenAgain);
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

  /// Shows the rate dialog.
  Future<void> showRateDialog(
    BuildContext context, {
    String title = 'Rate this app',
    String message = 'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
    String rateButton = 'RATE',
    String noButton = 'NO THANKS',
    String laterButton = 'MAYBE LATER',
  }) async =>
      await (Platform.isIOS ? AppReview.requestReview : RateMyAppDialog.openDialog(this, context, title, message, rateButton, noButton, laterButton));
}

/// The Android rate my app dialog.
class RateMyAppDialog extends StatelessWidget {
  /// The dialog's message.
  final String _message;

  /// Creates a new rate my app dialog.
  RateMyAppDialog(this._message);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Text(_message),
      );

  /// Opens the dialog.
  static Future<void> openDialog(RateMyApp rateMyApp, BuildContext context, String title, String message, String rateButton, String noButton, String laterButton) async => await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: RateMyAppDialog(message),
              actions: [
                Wrap(
                  alignment: WrapAlignment.end,
                  children: [
                    FlatButton(
                      child: Text(rateButton),
                      onPressed: () => AppReview.storeListing,
                    ),
                    FlatButton(
                      child: Text(laterButton),
                      onPressed: () {
                        rateMyApp.baseLaunchDate.add(Duration(
                          days: rateMyApp.remindDays,
                        ));
                        rateMyApp.launches += rateMyApp.remindLaunches;
                        rateMyApp.save().then((v) => Navigator.pop(context));
                      },
                    ),
                    FlatButton(
                      child: Text(noButton),
                      onPressed: () {
                        rateMyApp.doNotOpenAgain = true;
                        rateMyApp.save().then((v) => Navigator.pop(context));
                      },
                    ),
                  ],
                ),
              ],
            ),
      );
}
