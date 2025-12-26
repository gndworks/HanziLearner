import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/radical.dart';

class RadicalsService {
  static Map<String, String>? _cachedRadicalsDictionary;
  static List<Radical>? _cachedRadicalsWithTips;

  /// Loads the radicals dictionary from assets
  static Future<Map<String, String>> _loadRadicalsDictionary() async {
    if (_cachedRadicalsDictionary != null) {
      return _cachedRadicalsDictionary!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/radicals/radicals_dictionary.json');
      final Map<String, dynamic> dictionary = json.decode(jsonString);
      _cachedRadicalsDictionary = dictionary.map((key, value) => MapEntry(key, value as String));
      return _cachedRadicalsDictionary!;
    } catch (e) {
      // Return empty map if loading fails
      return {};
    }
  }

  /// Loads radicals with tips from assets
  static Future<List<Radical>> _loadRadicalsWithTips() async {
    if (_cachedRadicalsWithTips != null) {
      return _cachedRadicalsWithTips!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/radicals/radicals_with_tips.json');
      final List<dynamic> radicalsData = json.decode(jsonString);
      _cachedRadicalsWithTips = radicalsData
          .map((json) => Radical.fromJson(json as Map<String, dynamic>))
          .toList();
      return _cachedRadicalsWithTips!;
    } catch (e) {
      return [];
    }
  }

  /// Gets radical info by symbol (checks both main symbol and alternate symbols)
  /// Returns null if not found
  static Future<Radical?> getRadicalInfo(String symbol) async {
    final radicals = await _loadRadicalsWithTips();
    
    for (var radical in radicals) {
      if (radical.symbol == symbol) {
        return radical;
      }
      if (radical.alternateSymbols != null && radical.alternateSymbols!.contains(symbol)) {
        return radical;
      }
    }
    
    return null;
  }

  /// Gets radicals for a hanzi string by looking up each character
  /// Returns a list of unique radicals found for the characters
  static Future<List<String>> getRadicalsForHanzi(String hanzi) async {
    final dictionary = await _loadRadicalsDictionary();
    final radicals = <String>{};
    
    // Iterate through each character in the hanzi string
    for (int i = 0; i < hanzi.length; i++) {
      final character = hanzi[i];
      final radical = dictionary[character];
      if (radical != null && radical.isNotEmpty) {
        radicals.add(radical);
      }
    }
    
    return radicals.toList();
  }
}

