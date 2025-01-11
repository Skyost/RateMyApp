import 'package:rate_my_app/rate_my_app.dart';

/// Here's an example of a custom condition.
/// Will not be met if the dialog has been opened too many times.
/// Add it using : `rateMyApp.conditions.add(MaxDialogOpeningCondition(_rateMyApp));`.
class MaxDialogOpeningCondition extends Condition with SharedPreferencesCondition, ResetableCondition, DebuggableCondition {
  /// Maximum default dialog opening count (inclusive).
  final int maxDialogOpeningCount;

  /// Maximum star dialog opening count (inclusive).
  final int maxStarDialogOpeningCount;

  /// Current dialog opening count.
  late int dialogOpeningCount;

  /// Current star dialog opening count.
  late int starDialogOpeningCount;

  /// Creates a new max dialog opening condition instance.
  MaxDialogOpeningCondition({
    this.maxDialogOpeningCount = 3,
    this.maxStarDialogOpeningCount = 3,
  });

  @override
  Future<void> readFromPreferences(SharedPreferencesAsync preferences, String preferencesPrefix) async {
    // Here we can read the values (or we set their default values).
    dialogOpeningCount = (await preferences.getInt('${preferencesPrefix}dialogOpeningCount')) ?? 0;
    starDialogOpeningCount = (await preferences.getInt('${preferencesPrefix}starDialogOpeningCount')) ?? 0;
  }

  @override
  Future<void> saveToPreferences(SharedPreferencesAsync preferences, String preferencesPrefix) async {
    // Here we save our current values.
    await preferences.setInt('${preferencesPrefix}dialogOpeningCount', dialogOpeningCount);
    await preferences.setInt('${preferencesPrefix}starDialogOpeningCount', starDialogOpeningCount);
  }

  @override
  void reset() {
    // Allows to reset this condition values back to their default values.
    dialogOpeningCount = 0;
    starDialogOpeningCount = 0;
  }

  @override
  bool onEventOccurred(RateMyAppEventType eventType) {
    if (eventType == RateMyAppEventType.dialogOpen) {
      // If the default dialog has been opened, we update our default dialog counter.
      dialogOpeningCount++;
      return true; // Returning true allows to trigger a shared preferences save.
    }

    if (eventType == RateMyAppEventType.starDialogOpen) {
      // If the star dialog has been opened, we update our star dialog counter.
      starDialogOpeningCount++;
      return true;
    }

    return false; // Otherwise, no need to save anything.
  }

  @override
  Map<String, dynamic> get debugMap {
    // Allows to easily debug this condition.
    return {
      'Dialog opening count': dialogOpeningCount,
      'Max dialog opening count': maxDialogOpeningCount,
      'Star dialog opening count': starDialogOpeningCount,
      'Max star dialog opening count': maxStarDialogOpeningCount,
    };
  }

  @override
  bool get isMet {
    // This allows to check whether this condition is met in its current state.
    return dialogOpeningCount <= maxDialogOpeningCount && starDialogOpeningCount <= maxStarDialogOpeningCount;
  }
}
