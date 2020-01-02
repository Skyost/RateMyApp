import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a condition, which need to be met in order for the rate my app dialog to open.
abstract class Condition {
  /// The rate my app instance.
  @protected
  final RateMyApp rateMyApp;

  /// Creates a new condition instance.
  const Condition(this.rateMyApp) : assert(rateMyApp != null);

  /// Reads the condition state from the specified shared preferences.
  void readFromPreferences(SharedPreferences preferences);

  /// Saves the condition state to the specified shared preferences.
  Future<void> saveToPreferences(SharedPreferences preferences);

  /// Resets the condition state.
  void reset();

  /// Whether this condition is met.
  bool get isMet;

  /// Triggered when an even occurs in the plugin lifecycle.
  /// Return true to save the shared preferences, false otherwise.
  bool onEventOccurred(RateMyAppEventType eventType) => false;

  /// Returns an iterable containing all conditions matching the specified type.
  /// This can be particularly useful when you want to get a value of a condition added to a specified rate my app instance.
  static Iterable<Condition> getFromRateMyApp(RateMyApp rateMyApp, Type type) {
    return rateMyApp.conditions.where((condition) => condition.runtimeType == type);
  }
}

/// A condition that can easily be displayed thanks to the provided method.
abstract class DebuggableCondition extends Condition {
  /// Creates a new debuggable condition instance.
  const DebuggableCondition(RateMyApp rateMyApp) : super(rateMyApp);

  /// Gets the condition values in a readable string.
  String valuesAsString();
}

/// The minimum days condition.
class MinimumDaysCondition extends DebuggableCondition {
  /// Minimum days before being able to show the dialog.
  final int minDays;

  /// Days to add to the base date when the user clicks on "Maybe later" (not for the star rating dialog).
  final int remindDays;

  /// The base launch date.
  DateTime baseLaunchDate;

  /// Creates a new minimum days condition instance.
  MinimumDaysCondition(
    RateMyApp rateMyApp, {
    @required this.minDays,
    @required this.remindDays,
  })  : assert(minDays != null),
        assert(remindDays != null),
        super(rateMyApp);

  @override
  void readFromPreferences(SharedPreferences preferences) {
    baseLaunchDate = DateTime.fromMillisecondsSinceEpoch(preferences.getInt(rateMyApp.preferencesPrefix + 'baseLaunchDate') ?? DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<void> saveToPreferences(SharedPreferences preferences) {
    return preferences.setInt(rateMyApp.preferencesPrefix + 'baseLaunchDate', baseLaunchDate.millisecondsSinceEpoch);
  }

  @override
  void reset() => baseLaunchDate = DateTime.now();

  @override
  bool get isMet {
    return (DateTime.now().millisecondsSinceEpoch - baseLaunchDate.millisecondsSinceEpoch) / (1000 * 60 * 60 * 24) >= minDays;
  }

  @override
  bool onEventOccurred(RateMyAppEventType eventType) {
    if (eventType == RateMyAppEventType.laterButtonPressed) {
      baseLaunchDate = baseLaunchDate.add(Duration(
        days: remindDays,
      ));
      return true;
    }

    return false;
  }

  @override
  String valuesAsString() {
    return 'Minimum days : ' + minDays.toString() + '\nBase launch : ' + _dateToString(baseLaunchDate) + '\nRemind days : ' + remindDays.toString();
  }

  /// Returns a formatted date string.
  String _dateToString(DateTime date) => date.day.toString().padLeft(2, '0') + '/' + date.month.toString().padLeft(2, '0') + '/' + date.year.toString();
}

/// The minimum app launches condition.
class MinimumAppLaunchesCondition extends DebuggableCondition {
  /// Minimum launches before being able to show the dialog.
  final int minLaunches;

  /// Launches to subtract to the number of launches when the user clicks on "Maybe later" (not for the star rating dialog).
  final int remindLaunches;

  /// Number of app launches.
  int launches;

  /// Creates a new minimum app launches condition instance.
  MinimumAppLaunchesCondition(
    RateMyApp rateMyApp, {
    @required this.minLaunches,
    @required this.remindLaunches,
  })  : assert(minLaunches != null),
        assert(remindLaunches != null),
        super(rateMyApp);

  @override
  void readFromPreferences(SharedPreferences preferences) {
    launches = preferences.getInt(rateMyApp.preferencesPrefix + 'launches') ?? 0;
  }

  @override
  Future<void> saveToPreferences(SharedPreferences preferences) {
    return preferences.setInt(rateMyApp.preferencesPrefix + 'launches', launches);
  }

  @override
  void reset() => launches = 0;

  @override
  bool get isMet => launches >= minLaunches;

  @override
  bool onEventOccurred(RateMyAppEventType eventType) {
    if (eventType == RateMyAppEventType.initialized) {
      launches++;
      return true;
    }

    if (eventType == RateMyAppEventType.laterButtonPressed) {
      launches -= remindLaunches;
      return true;
    }

    return false;
  }

  @override
  String valuesAsString() {
    return 'Minimum launches : ' + minLaunches.toString() + '\nCurrent launches : ' + launches.toString() + '\nRemind launches : ' + remindLaunches.toString();
  }
}

/// The do not open again condition.
class DoNotOpenAgainCondition extends DebuggableCondition {
  /// Whether the dialog should not be opened again.
  bool doNotOpenAgain;

  /// Creates a new do not open again condition instance.
  DoNotOpenAgainCondition(RateMyApp rateMyApp) : super(rateMyApp);

  @override
  void readFromPreferences(SharedPreferences preferences) {
    doNotOpenAgain = preferences.getBool(rateMyApp.preferencesPrefix + 'doNotOpenAgain') ?? false;
  }

  @override
  Future<void> saveToPreferences(SharedPreferences preferences) {
    return preferences.setBool(rateMyApp.preferencesPrefix + 'doNotOpenAgain', doNotOpenAgain);
  }

  @override
  void reset() => doNotOpenAgain = false;

  @override
  bool get isMet => !doNotOpenAgain;

  @override
  bool onEventOccurred(RateMyAppEventType eventType) {
    if (eventType == RateMyAppEventType.rateButtonPressed || eventType == RateMyAppEventType.noButtonPressed) {
      doNotOpenAgain = true;
      return true;
    }

    return false;
  }

  @override
  String valuesAsString() {
    return 'Do not open again ? ' + (doNotOpenAgain ? 'Yes' : 'No');
  }
}
