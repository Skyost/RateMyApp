import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a condition, which need to be met in order for the Rate my app dialog to open.
abstract class Condition {
  /// Reads the condition values from the specified shared preferences.
  void readFromPreferences(SharedPreferences preferences, String preferencesPrefix);

  /// Saves the condition values to the specified shared preferences.
  Future<void> saveToPreferences(SharedPreferences preferences, String preferencesPrefix);

  /// Resets the condition values.
  void reset();

  /// Whether this condition is met.
  bool get isMet;

  /// Triggered when an even occurs in the plugin lifecycle.
  /// Return true to save the shared preferences, false otherwise.
  bool onEventOccurred(RateMyAppEventType eventType) => false;
}

/// A condition that can easily be displayed thanks to the provided method.
abstract class DebuggableCondition extends Condition {
  /// Gets the condition values in a readable string.
  String get valuesAsString;
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
  MinimumDaysCondition({
    @required this.minDays,
    @required this.remindDays,
  })  : assert(minDays != null),
        assert(remindDays != null);

  @override
  void readFromPreferences(SharedPreferences preferences, String preferencesPrefix) {
    baseLaunchDate = DateTime.fromMillisecondsSinceEpoch(preferences.getInt(preferencesPrefix + 'baseLaunchDate') ?? DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<void> saveToPreferences(SharedPreferences preferences, String preferencesPrefix) {
    return preferences.setInt(preferencesPrefix + 'baseLaunchDate', baseLaunchDate.millisecondsSinceEpoch);
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
  String get valuesAsString {
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
  MinimumAppLaunchesCondition({
    @required this.minLaunches,
    @required this.remindLaunches,
  })  : assert(minLaunches != null),
        assert(remindLaunches != null);

  @override
  void readFromPreferences(SharedPreferences preferences, String preferencesPrefix) {
    launches = preferences.getInt(preferencesPrefix + 'launches') ?? 0;
  }

  @override
  Future<void> saveToPreferences(SharedPreferences preferences, String preferencesPrefix) {
    return preferences.setInt(preferencesPrefix + 'launches', launches);
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
  String get valuesAsString {
    return 'Minimum launches : ' + minLaunches.toString() + '\nCurrent launches : ' + launches.toString() + '\nRemind launches : ' + remindLaunches.toString();
  }
}

/// The do not open again condition.
class DoNotOpenAgainCondition extends DebuggableCondition {
  /// Whether the dialog should not be opened again.
  bool doNotOpenAgain;

  @override
  void readFromPreferences(SharedPreferences preferences, String preferencesPrefix) {
    doNotOpenAgain = preferences.getBool(preferencesPrefix + 'doNotOpenAgain') ?? false;
  }

  @override
  Future<void> saveToPreferences(SharedPreferences preferences, String preferencesPrefix) {
    return preferences.setBool(preferencesPrefix + 'doNotOpenAgain', doNotOpenAgain);
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
  String get valuesAsString {
    return 'Do not open again ? ' + (doNotOpenAgain ? 'Yes' : 'No');
  }
}
