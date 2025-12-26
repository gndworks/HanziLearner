class Radical {
  final String symbol;
  final String pinyin;
  final String englishDescription;
  final String origin;
  final String tip;
  final List<String>? alternateSymbols;

  Radical({
    required this.symbol,
    required this.pinyin,
    required this.englishDescription,
    required this.origin,
    required this.tip,
    this.alternateSymbols,
  });

  factory Radical.fromJson(Map<String, dynamic> json) {
    // Handle both old format (alternateSymbol as String) and new format (alternateSymbols as List)
    List<String>? alternateSymbols;
    if (json['alternateSymbols'] != null) {
      alternateSymbols = List<String>.from(json['alternateSymbols'] as List);
    } else if (json['alternateSymbol'] != null) {
      // Backward compatibility: convert single alternateSymbol to list
      alternateSymbols = [json['alternateSymbol'] as String];
    }

    return Radical(
      symbol: json['symbol'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      englishDescription: json['english_description'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
      alternateSymbols: alternateSymbols,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'pinyin': pinyin,
      'english_description': englishDescription,
      'origin': origin,
      'tip': tip,
      'alternateSymbols': alternateSymbols,
    };
  }
}


