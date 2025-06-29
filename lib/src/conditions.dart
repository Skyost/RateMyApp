import 'package:flutter/foundation.dart';
import 'package:rate_my_app/rate_my_app.dart';

/// Represents a condition, which need to be met in order for the Rate my app dialog to open.
abstract class Condition {
  /// Whether this condition is met.
  bool get isMet;

  /// Triggered when an even occurs in the plugin lifecycle.
  /// Return true to save the shared preferences, false otherwise.
  bool onEventOccurred(RateMyAppEventType eventType) => false;
}

/// A condition that reads and stores its values to the shared preferences.
mixin SharedPreferencesCondition on Condition {
  /// Reads the condition values from the specified shared preferences.
  Future<void> readFromPreferences(SharedPreferencesAsync preferences, String preferencesPrefix);

  /// Saves the condition values to the specified shared preferences.
  Future<void> saveToPreferences(SharedPreferencesAsync preferences, String preferencesPrefix);
}

/// A resetable condition.
mixin ResetableCondition on Condition {
  /// Resets the condition values.
  void reset();
}

/// A condition that can easily be displayed thanks to the provided method.
mixin DebuggableCondition on Condition {
  /// Gets the condition values in a readable map.
  Map<String, dynamic> get debugMap;

  @override
  String toString() {
    String result = '';
    for (MapEntry<String, dynamic> entry in debugMap.entries) {
      result += '${entry.key} : ${entry.value}\n';
    }
    if (result.endsWith('\n')) {
      result = result.substring(0, result.length - '\n'.length);
    }
    return result;
  }

  /// Prints this condition to the console, if in debug mode.
  void printToConsole() {
    if (kDebugMode) {
      print(toString());
    }
  }
}

/// The minimum days condition.
class MinimumDaysCondition extends Condition with SharedPreferencesCondition, ResetableCondition, DebuggableCondition {
  /// Minimum days before being able to show the dialog.
  final int minDays;

  /// Days to add to the base date when the user clicks on "Maybe later".
  final int remindDays;

  /// The minimum date required to meet this condition.
  late DateTime minimumDate;

  /// Creates a new minimum days condition instance.
  MinimumDaysCondition({
    required this.minDays,
    required this.remindDays,
  });

  @override
  Future<void> readFromPreferences(SharedPreferencesAsync preferences, String preferencesPrefix) async {
    minimumDate = DateTime.fromMillisecondsSinceEpoch((await preferences.getInt('${preferencesPrefix}minimumDate')) ?? _now().millisecondsSinceEpoch);
  }

  @override
  Future<void> saveToPreferences(SharedPreferencesAsync preferences, String preferencesPrefix) {
    return preferences.setInt('${preferencesPrefix}minimumDate', minimumDate.millisecondsSinceEpoch);
  }

  @override
  void reset() => minimumDate = _now();

  @override
  bool get isMet => DateTime.now().isAfter(minimumDate);

  @override
  bool onEventOccurred(RateMyAppEventType eventType) {
    if (eventType == RateMyAppEventType.laterButtonPressed || eventType == RateMyAppEventType.requestReview) {
      minimumDate = _now(Duration(days: remindDays));
      return true;
    }

    return false;
  }

  @override
  Map<String, dynamic> get debugMap => {
        'Minimum days': minDays,
        'Remind days': remindDays,
        'Minimum valid date': _dateToString(minimumDate),
      };

  /// Returns a formatted date string.
  String _dateToString(DateTime date) => '${_addZeroIfNeeded(date.day)}/${_addZeroIfNeeded(date.month)}/${date.year} ${_addZeroIfNeeded(date.hour)}:${_addZeroIfNeeded(date.minute)}';

  /// Adds a zero to a given number if needed.
  String _addZeroIfNeeded(int number) => number.toString().padLeft(2, '0');

  /// Returns the current date with the minimum days added.
  DateTime _now([Duration? toAdd]) => DateTime.now().add(toAdd ?? Duration(days: minDays));
}

/// The minimum app launches condition.
class MinimumAppLaunchesCondition extends Condition with SharedPreferencesCondition, ResetableCondition, DebuggableCondition {
  /// Minimum launches before being able to show the dialog.
  final int minLaunches;

  /// Launches to subtract to the number of launches when the user clicks on "Maybe later".
  final int remindLaunches;

  /// Number of app launches.
  var launches = 0;

  /// Creates a new minimum app launches condition instance.
  MinimumAppLaunchesCondition({
    required this.minLaunches,
    required this.remindLaunches,
  });

  @override
  Future<void> readFromPreferences(SharedPreferencesAsync preferences, String preferencesPrefix) async {
    launches = (await preferences.getInt('${preferencesPrefix}launches')) ?? 0;
  }

  @override
  Future<void> saveToPreferences(SharedPreferencesAsync preferences, String preferencesPrefix) {
    return preferences.setInt('${preferencesPrefix}launches', launches);
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

    if (eventType == RateMyAppEventType.laterButtonPressed || eventType == RateMyAppEventType.requestReview) {
      launches -= remindLaunches;
      return true;
    }

    return false;
  }

  @override
  Map<String, dynamic> get debugMap => {
        'Minimum launches': minLaunches,
        'Remind launches': remindLaunches,
        'Current launches': launches,
      };
}

/// The do not open again condition.
class DoNotOpenAgainCondition extends Condition with SharedPreferencesCondition, ResetableCondition, DebuggableCondition {
  /// Whether the dialog should not be opened again.
  late bool doNotOpenAgain;

  @override
  Future<void> readFromPreferences(SharedPreferencesAsync preferences, String preferencesPrefix) async {
    doNotOpenAgain = (await preferences.getBool('${preferencesPrefix}doNotOpenAgain')) ?? false;
  }

  @override
  Future<void> saveToPreferences(SharedPreferencesAsync preferences, String preferencesPrefix) {
    return preferences.setBool('${preferencesPrefix}doNotOpenAgain', doNotOpenAgain);
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
  Map<String, dynamic> get debugMap => {
        'Do not open again': doNotOpenAgain ? 'Yes' : 'No',
      };
}
