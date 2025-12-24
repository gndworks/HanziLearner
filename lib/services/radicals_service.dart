import 'dart:convert';
import 'package:flutter/services.dart';

class RadicalsService {
  static Map<String, String>? _cachedRadicalsDictionary;

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

