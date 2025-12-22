class HanziCharacter {
  final String character;
  final String pinyin;
  final String meaning;
  final int hskLevel;
  final List<String> radicals;

  HanziCharacter({
    required this.character,
    required this.pinyin,
    required this.meaning,
    required this.hskLevel,
    this.radicals = const [],
  });
}

