class Radical {
  final String symbol;
  final String pinyin;
  final String englishDescription;
  final String origin;
  final String tip;
  final String? alternateSymbol;

  Radical({
    required this.symbol,
    required this.pinyin,
    required this.englishDescription,
    required this.origin,
    required this.tip,
    this.alternateSymbol,
  });

  factory Radical.fromJson(Map<String, dynamic> json) {
    return Radical(
      symbol: json['symbol'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      englishDescription: json['english_description'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      tip: json['tip'] as String? ?? '',
      alternateSymbol: json['alternateSymbol'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'pinyin': pinyin,
      'english_description': englishDescription,
      'origin': origin,
      'tip': tip,
      'alternateSymbol': alternateSymbol,
    };
  }
}

