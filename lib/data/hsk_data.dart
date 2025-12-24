import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hanzi_character.dart';

class HSKData {
  static List<HanziCharacter>? _cachedHSK1;
  static Map<String, String>? _cachedTips;

  static Future<List<HanziCharacter>> getHSKLevel1() async {
    if (_cachedHSK1 != null) {
      return _cachedHSK1!;
    }

    // Load HSK1 data
    final String hsk1JsonString = await rootBundle.loadString('assets/hsk/1.json');
    final List<dynamic> hsk1Data = json.decode(hsk1JsonString);

    // Load tips
    final String tipsJsonString = await rootBundle.loadString('assets/tips/hsk1.json');
    final List<dynamic> tipsData = json.decode(tipsJsonString);
    
    // Create a map of simplified -> tip for quick lookup
    _cachedTips = {
      for (var tip in tipsData)
        tip['s'] as String: tip['t'] as String
    };

    // Convert JSON data to HanziCharacter objects
    _cachedHSK1 = hsk1Data.map((json) {
      final simplified = json['simplified'] as String;
      final tip = _cachedTips![simplified];
      return HanziCharacter.fromJson(json as Map<String, dynamic>, 1, tip: tip);
    }).toList();

    return _cachedHSK1!;
  }

  static Future<List<String>> getAllPinyinOptions() async {
    final characters = await getHSKLevel1();
    return characters
        .map((char) => char.pinyin)
        .where((pinyin) => pinyin.isNotEmpty)
        .toSet()
        .toList();
  }
}

