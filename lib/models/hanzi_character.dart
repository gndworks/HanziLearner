class HanziCharacter {
  // Core fields (matching JSON structure)
  final String simplified; // Simplified character/word
  final List<String> radicals; // Radicals for all characters in the hanzi
  final int frequency; // Frequency rank
  final List<String> pos; // Parts of speech
  final List<CharacterForm> forms; // Character forms (traditional, transcriptions, meanings, classifiers)
  
  // Additional fields
  final int hskLevel;
  final String? tip; // Mnemonic tip from tips file
  
  // Convenience getters for common access patterns (used throughout the codebase)
  String get character => simplified;
  String get pinyin => forms.isNotEmpty ? forms.first.transcriptions.pinyin : '';
  String get meaning => forms.isNotEmpty && forms.first.meanings.isNotEmpty 
      ? forms.first.meanings.first 
      : '';

  HanziCharacter({
    required this.simplified,
    required this.radicals,
    required this.frequency,
    required this.pos,
    required this.forms,
    required this.hskLevel,
    this.tip,
  });
  
  // Factory constructor for parsing from JSON (HSK data format)
  // Note: radicals must be provided separately as they come from radicals_dictionary.json
  factory HanziCharacter.fromJson(
    Map<String, dynamic> json, 
    int hskLevel, 
    {String? tip, List<String>? radicals}
  ) {
    return HanziCharacter(
      simplified: json['simplified'] ?? '',
      radicals: radicals ?? [],
      frequency: json['frequency'] ?? 0,
      pos: List<String>.from(json['pos'] ?? []),
      forms: (json['forms'] as List<dynamic>?)
          ?.map((form) => CharacterForm.fromJson(form as Map<String, dynamic>))
          .toList() ?? [],
      hskLevel: hskLevel,
      tip: tip,
    );
  }
}

class CharacterForm {
  final String traditional;
  final Transcriptions transcriptions;
  final List<String> meanings;
  final List<String> classifiers;

  CharacterForm({
    required this.traditional,
    required this.transcriptions,
    required this.meanings,
    required this.classifiers,
  });
  
  factory CharacterForm.fromJson(Map<String, dynamic> json) {
    return CharacterForm(
      traditional: json['traditional'] ?? '',
      transcriptions: Transcriptions.fromJson(json['transcriptions'] ?? {}),
      meanings: List<String>.from(json['meanings'] ?? []),
      classifiers: List<String>.from(json['classifiers'] ?? []),
    );
  }
}

class Transcriptions {
  final String pinyin;
  final String numeric;
  final String wadegiles;
  final String bopomofo;
  final String romatzyh;

  Transcriptions({
    required this.pinyin,
    required this.numeric,
    required this.wadegiles,
    required this.bopomofo,
    required this.romatzyh,
  });
  
  factory Transcriptions.fromJson(Map<String, dynamic> json) {
    return Transcriptions(
      pinyin: json['pinyin'] ?? '',
      numeric: json['numeric'] ?? '',
      wadegiles: json['wadegiles'] ?? '',
      bopomofo: json['bopomofo'] ?? '',
      romatzyh: json['romatzyh'] ?? '',
    );
  }
}

