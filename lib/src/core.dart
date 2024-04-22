import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rate_my_app/src/conditions.dart';
import 'package:rate_my_app/src/dialogs.dart';
import 'package:rate_my_app/src/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Allows to kindly ask users to rate your app if custom conditions are met (eg. install time, number of launches, etc...).
class RateMyApp {
  /// The plugin channel.
  static const MethodChannel _channel = MethodChannel('rate_my_app');

  /// Prefix for preferences.
  final String preferencesPrefix;

  /// The google play identifier.
  final String? googlePlayIdentifier;

  /// The app store identifier.
  final String? appStoreIdentifier;

  /// All conditions that should be met to show the dialog.
  final List<Condition> conditions;

  /// Creates a new Rate my app instance.
  RateMyApp({
    this.preferencesPrefix = 'rateMyApp_',
    int? minDays,
    int? remindDays,
    int? minLaunches,
    int? remindLaunches,
    this.googlePlayIdentifier,
    this.appStoreIdentifier,
  }) : conditions = [] {
    populateWithDefaultConditions(
      minDays: minDays,
      remindDays: remindDays,
      minLaunches: minLaunches,
      remindLaunches: remindLaunches,
    );
  }

  /// Creates a new Rate my app instance with custom conditions.
  const RateMyApp.customConditions({
    this.preferencesPrefix = 'rateMyApp_',
    this.googlePlayIdentifier,
    this.appStoreIdentifier,
    required this.conditions,
  });

  /// Initializes the plugin (loads base launch date, app launches and whether the dialog should not be opened again).
  Future<void> init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    for (Condition condition in conditions) {
      condition.readFromPreferences(preferences, preferencesPrefix);
    }
    await callEvent(RateMyAppEventType.initialized);
  }

  /// Saves the plugin current data to the shared preferences.
  Future<void> save() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    for (Condition condition in conditions) {
      await condition.saveToPreferences(preferences, preferencesPrefix);
    }

    await callEvent(RateMyAppEventType.saved);
  }

  /// Resets the plugin data.
  Future<void> reset() async {
    for (Condition condition in conditions) {
      condition.reset();
    }
    await save();
  }

  /// Whether the dialog should be opened.
  bool get shouldOpenDialog {
    for (Condition condition in conditions) {
      if (!condition.isMet) {
        return false;
      }
    }
    return true;
  }

  /// Returns the corresponding store identifier.
  String? get storeIdentifier {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return googlePlayIdentifier;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return appStoreIdentifier;
      default:
        return null;
    }
  }

  /// Returns whether native review dialog is supported.
  Future<bool?> get isNativeReviewDialogSupported =>
      _channel.invokeMethod<bool>('isNativeDialogSupported');

  /// Launches the native review dialog.
  /// You should check for [isNativeReviewDialogSupported] before running the method.
  Future<void> launchNativeReviewDialog() =>
      _channel.invokeMethod('launchNativeReviewDialog');

  /// Shows the rate dialog.
  Future<void> showRateDialog(
    BuildContext context, {
    String title = 'Rate this app',
    String message =
        'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
    DialogContentBuilder? contentBuilder,
    DialogActionsBuilder? actionsBuilder,
    String rateButton = 'Rate',
    String noButton = 'No thanks',
    String laterButton = 'Maybe later',
    RateMyAppDialogButtonClickListener? listener,
    bool ignoreNativeDialog = false,
    DialogStyle dialogStyle = const DialogStyle(),
    VoidCallback? onDismissed,
    bool barrierDismissible = true,
    String barrierLabel = '',
    DialogTransition dialogTransition = const DialogTransition(),
  }) async {
    if (!ignoreNativeDialog &&
        ((await isNativeReviewDialogSupported) ?? false)) {
      callEvent(RateMyAppEventType.requestReview);
      await launchNativeReviewDialog();
      return;
    }

    RateMyAppDialog rateMyAppDialog = RateMyAppDialog(
      this,
      title: title,
      message: message,
      contentBuilder:
          contentBuilder ?? ((context, defaultContent) => defaultContent),
      actionsBuilder: actionsBuilder,
      rateButton: rateButton,
      noButton: noButton,
      laterButton: laterButton,
      listener: listener,
      dialogStyle: dialogStyle,
    );

    callEvent(RateMyAppEventType.dialogOpen);

    RateMyAppDialogButton? clickedButton;
    if (context.mounted) {
      // Using [showDialog()] when [TransitionType.none] to get rid of the default fading animation of [showGeneralDialog].
      clickedButton = dialogTransition.transitionType == TransitionType.none
          ? await showDialog<RateMyAppDialogButton>(
              context: context,
              builder: (context) => rateMyAppDialog,
              barrierDismissible: barrierDismissible,
            )
          : await showGeneralDialog<RateMyAppDialogButton>(
              context: context,
              barrierLabel: barrierLabel,
              transitionDuration: dialogTransition.transitionDuration,
              barrierDismissible: barrierDismissible,
              transitionBuilder: dialogTransition.customTransitionBuilder ??
                  (context, animation1, animation2, child) => buildAnimations(
                        animation: animation1,
                        child: child,
                        dialogTransition: dialogTransition,
                      ),
              pageBuilder: (context, animation1, animation2) => rateMyAppDialog,
            );
    }

    if (clickedButton == null && onDismissed != null) {
      onDismissed();
    }
  }

  /// Shows the star rate dialog.
  Future<void> showStarRateDialog(
    BuildContext context, {
    String title = 'Rate this app',
    String message =
        'You like this app ? Then take a little bit of your time to leave a rating :',
    DialogContentBuilder? contentBuilder,
    StarDialogActionsBuilder? actionsBuilder,
    bool ignoreNativeDialog = false,
    DialogStyle dialogStyle = const DialogStyle(
      titleAlign: TextAlign.center,
      messageAlign: TextAlign.center,
      messagePadding: EdgeInsets.only(bottom: 20),
    ),
    StarRatingOptions starRatingOptions = const StarRatingOptions(),
    VoidCallback? onDismissed,
    bool barrierDismissible = true,
    String barrierLabel = '',
    DialogTransition dialogTransition = const DialogTransition(),
  }) async {
    if (!ignoreNativeDialog &&
        ((await isNativeReviewDialogSupported) ?? false)) {
      callEvent(RateMyAppEventType.requestReview);
      await launchNativeReviewDialog();
      return;
    }

    assert(actionsBuilder != null, 'You should provide an actions builder.');
    callEvent(RateMyAppEventType.starDialogOpen);

    RateMyAppStarDialog starRateDialog = RateMyAppStarDialog(
      this,
      title: title,
      message: message,
      contentBuilder:
          contentBuilder ?? ((context, defaultContent) => defaultContent),
      actionsBuilder: actionsBuilder,
      dialogStyle: dialogStyle,
      starRatingOptions: starRatingOptions,
    );

    RateMyAppDialogButton? clickedButton;
    if (context.mounted) {
      // Using [showDialog()] when [TransitionType.none] to get rid of the default fading animation of [showGeneralDialog].
      clickedButton = dialogTransition.transitionType == TransitionType.none
          ? await showDialog(
              context: context, builder: (context) => starRateDialog)
          : await showGeneralDialog(
              context: context,
              transitionDuration: dialogTransition.transitionDuration,
              barrierLabel: barrierLabel,
              barrierDismissible: barrierDismissible,
              transitionBuilder: dialogTransition.customTransitionBuilder ??
                  (context, animation1, animation2, child) => buildAnimations(
                        animation: animation1,
                        child: child,
                        dialogTransition: dialogTransition,
                      ),
              pageBuilder: (context, animation1, animation2) => starRateDialog,
            );
    }

    if (clickedButton == null && onDismissed != null) {
      onDismissed();
    }
  }

  /// Launches the corresponding store.
  Future<LaunchStoreResult> launchStore() async {
    int? result = await _channel.invokeMethod<int>('launchStore',
        storeIdentifier == null ? null : {'appId': storeIdentifier});
    return LaunchStoreResult.values.firstWhere((value) => value.index == result, orElse: () => LaunchStoreResult.errorOccurred);
  }

  /// Calls the specified event.
  Future<void> callEvent(RateMyAppEventType eventType) async {
    bool saveSharedPreferences = false;
    for (Condition condition in conditions) {
      saveSharedPreferences =
          condition.onEventOccurred(eventType) || saveSharedPreferences;
    }
    if (saveSharedPreferences) {
      await save();
    }
  }

  /// Adds the default conditions to the current conditions list.
  void populateWithDefaultConditions({
    int? minDays,
    int? remindDays,
    int? minLaunches,
    int? remindLaunches,
  }) {
    conditions.add(MinimumDaysCondition(
      minDays: minDays ?? 7,
      remindDays: remindDays ?? 7,
    ));
    conditions.add(MinimumAppLaunchesCondition(
      minLaunches: minLaunches ?? 10,
      remindLaunches: remindLaunches ?? 10,
    ));
    conditions.add(DoNotOpenAgainCondition());
  }

  /// Builds the animations widget.
  Widget buildAnimations({
    required Animation<double> animation,
    required Widget child,
    required DialogTransition dialogTransition,
  }) {
    switch (dialogTransition.transitionType) {
      case TransitionType.fade:
        return FadeTransition(
          opacity:
              CurvedAnimation(curve: dialogTransition.curve, parent: animation),
          child: child,
        );
      case TransitionType.rotation:
        return RotationTransition(
          turns:
              CurvedAnimation(curve: dialogTransition.curve, parent: animation),
          child: child,
        );
      case TransitionType.scale:
        return ScaleTransition(
          alignment: dialogTransition.alignment ?? Alignment.center,
          scale:
              CurvedAnimation(curve: dialogTransition.curve, parent: animation),
          child: child,
        );
      case TransitionType.scaleAndFade:
        return FadeTransition(
          opacity:
              CurvedAnimation(curve: dialogTransition.curve, parent: animation),
          child: ScaleTransition(
            scale: CurvedAnimation(
                curve: dialogTransition.curve, parent: animation),
            child: child,
          ),
        );
      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
                  begin: dialogTransition.startOffset ?? const Offset(1, 0),
                  end: Offset.zero)
              .animate(
            CurvedAnimation(parent: animation, curve: dialogTransition.curve),
          ),
        );
      default:
        return child;
    }
  }
}

/// Represents all events that can occur during the Rate my app lifecycle.
enum RateMyAppEventType {
  /// When Rate my app is fully initialized.
  initialized,

  /// When Rate my app is saved.
  saved,

  /// When a native rating dialog is requested.
  requestReview,

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

/// Allows to handle the result of the `launchStore` method.
enum LaunchStoreResult {
  /// The store has been opened, everything is okay.
  storeOpened,

  /// The store has not been opened, but a link to your app has been opened in the user web browser.
  browserOpened,

  /// An error occurred and the method did nothing.
  errorOccurred,
}
