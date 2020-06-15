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

  /// Days to add to the base date when the user clicks on "Maybe later".
  final int remindDays;

  /// The minimum date required to meet this condition.
  DateTime minimumDate;

  /// Creates a new minimum days condition instance.
  MinimumDaysCondition({
    @required this.minDays,
    @required this.remindDays,
  })  : assert(minDays != null),
        assert(remindDays != null);

  @override
  void readFromPreferences(SharedPreferences preferences, String preferencesPrefix) {
    minimumDate = DateTime.fromMillisecondsSinceEpoch(preferences.getInt(preferencesPrefix + 'minimumDate') ?? _now().millisecondsSinceEpoch);
  }

  @override
  Future<void> saveToPreferences(SharedPreferences preferences, String preferencesPrefix) {
    return preferences.setInt(preferencesPrefix + 'minimumDate', minimumDate.millisecondsSinceEpoch);
  }

  @override
  void reset() => minimumDate = _now();

  @override
  bool get isMet => DateTime.now().isAfter(minimumDate);

  @override
  bool onEventOccurred(RateMyAppEventType eventType) {
    if (eventType == RateMyAppEventType.laterButtonPressed || eventType == RateMyAppEventType.iOSRequestReview) {
      minimumDate = _now(Duration(days: remindDays));
      return true;
    }

    return false;
  }

  @override
  String get valuesAsString {
    return 'Minimum days : $minDays\nRemind days : $remindDays\nMinimum valid date : ${_dateToString(minimumDate)}';
  }

  /// Returns a formatted date string.
  String _dateToString(DateTime date) => '${_addZeroIfNeeded(date.day)}/${_addZeroIfNeeded(date.month)}/${date.year} ${_addZeroIfNeeded(date.hour)}:${_addZeroIfNeeded(date.minute)}';

  /// Adds a zero to a given number if needed.
  String _addZeroIfNeeded(int number) => number.toString().padLeft(2, '0');

  /// Returns the current date with the minimum days added.
  DateTime _now([Duration toAdd]) => DateTime.now().add(toAdd ?? Duration(days: minDays));
}

/// The minimum app launches condition.
class MinimumAppLaunchesCondition extends DebuggableCondition {
  /// Minimum launches before being able to show the dialog.
  final int minLaunches;

  /// Launches to subtract to the number of launches when the user clicks on "Maybe later".
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

    if (eventType == RateMyAppEventType.laterButtonPressed || eventType == RateMyAppEventType.iOSRequestReview) {
      launches -= remindLaunches;
      return true;
    }

    return false;
  }

  @override
  String get valuesAsString {
    return 'Minimum launches : $minLaunches\nRemind launches : $remindLaunches\nCurrent launches : $launches';
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
