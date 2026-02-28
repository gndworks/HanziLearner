import 'package:hive_flutter/hive_flutter.dart';

class ProgressService {
  static const String _boxName = 'hanzi_progress';
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  static Future<void> markAsLearned(String symbol) async {
    await _box.put(symbol, true);
  }

  static bool isLearned(String symbol) {
    return _box.get(symbol, defaultValue: false) == true;
  }

  static int getLearnedCount(List<String> levelCharacters) {
    int count = 0;
    for (final symbol in levelCharacters) {
      if (isLearned(symbol)) {
        count++;
      }
    }
    return count;
  }
  
  static Future<void> clearAllProgress() async {
    await _box.clear();
  }
}
