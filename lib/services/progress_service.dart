import 'package:hive_flutter/hive_flutter.dart';

class ProgressService {
  static const String _boxName = 'hanzi_progress';
  static late Box _box;

  /// Initializes Hive and opens the progress box.
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// Marks a character as learned.
  /// We store a boolean 'true' for simplicity, but could later store a timestamp or level info.
  static Future<void> markAsLearned(String symbol) async {
    await _box.put(symbol, true);
  }

  /// Returns true if the character has been marked as learned.
  static bool isLearned(String symbol) {
    return _box.get(symbol, defaultValue: false) == true;
  }

  /// Gets the count of learned characters for a specific level.
  /// This requires checking characters against the box.
  static int getLearnedCount(List<String> levelCharacters) {
    int count = 0;
    for (final symbol in levelCharacters) {
      if (isLearned(symbol)) {
        count++;
      }
    }
    return count;
  }
  
  /// Clears all progress (useful for testing or resetting).
  static Future<void> clearAllProgress() async {
    await _box.clear();
  }
}
