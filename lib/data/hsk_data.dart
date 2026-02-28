import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hanzi_character.dart';
import '../services/radicals_service.dart';

class HSKData {
  static final Map<int, List<HanziCharacter>> _cachedLevels = {};
  static final Map<int, Map<String, String>> _cachedTips = {};

  static Future<List<HanziCharacter>> getHSKLevel(int level) async {
    if (_cachedLevels.containsKey(level)) {
      return _cachedLevels[level]!;
    }

    try {
      // Load level data
      final String hskJsonString = await rootBundle.loadString('assets/hsk/$level.json');
      final List<dynamic> hskData = json.decode(hskJsonString);

      // Load tips for this level
      Map<String, String> levelTips = {};
      try {
        final String tipsJsonString = await rootBundle.loadString('assets/tips/hsk$level.json');
        final List<dynamic> tipsData = json.decode(tipsJsonString);
        levelTips = {
          for (var tip in tipsData)
            tip['s'] as String: tip['t'] as String
        };
        _cachedTips[level] = levelTips;
      } catch (e) {
        // Fallback if tips file doesn't exist
        print('No tips found for level $level');
      }

      // Convert JSON data to HanziCharacter objects
      final characters = await Future.wait(hskData.map((json) async {
        final simplified = json['simplified'] as String;
        final tip = levelTips[simplified];
        // Get radicals for all characters in the hanzi
        final radicals = await RadicalsService.getRadicalsForHanzi(simplified);
        return HanziCharacter.fromJson(
          json as Map<String, dynamic>, 
          level, 
          tip: tip,
          radicals: radicals,
        );
      }));

      _cachedLevels[level] = characters;
      return characters;
    } catch (e) {
      print('Error loading HSK level $level: $e');
      return [];
    }
  }

  static Future<List<String>> getAllPinyinOptions({int level = 1}) async {
    final characters = await getHSKLevel(level);
    return characters
        .map((char) => char.pinyin)
        .where((pinyin) => pinyin.isNotEmpty)
        .toSet()
        .toList();
  }
}

