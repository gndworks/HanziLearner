import '../models/hanzi_character.dart';

class MemorizationService {
  static String generateMemorizationTip(HanziCharacter character) {
    final tips = <String>[];
    
    // Use tip from JSON if available
    if (character.tip != null && character.tip!.isNotEmpty) {
      return character.tip!;
    }
    
    // Add radical information
    if (character.radical.isNotEmpty) {
      tips.add('Radical: ${character.radical}');
    }
    
    // Add character-specific tips based on common patterns
    if (character.character == '好') {
      tips.add('This character combines 女 (woman) and 子 (child), representing "good" - a woman with a child is good!');
    } else if (character.character == '国') {
      tips.add('This character has 囗 (enclosure) around 玉 (jade), representing a country as a protected territory.');
    } else if (character.character == '和') {
      tips.add('This combines 禾 (grain) and 口 (mouth), suggesting harmony through sharing food.');
    } else if (character.character == '我') {
      tips.add('This character contains 戈 (spear), representing the self as someone who can defend themselves.');
    } else if (character.character == '你' || character.character == '他') {
      tips.add('Both characters start with 亻 (person radical), indicating they refer to people.');
    } else if (character.character == '的') {
      tips.add('Contains 白 (white) and 勺 (spoon), used as a possessive marker.');
    } else if (character.character == '有') {
      tips.add('Contains 月 (moon) and 又 (again), suggesting possession over time.');
    } else if (character.character == '这' || character.character == '那') {
      tips.add('These are demonstrative pronouns - 这 (this) and 那 (that).');
    } else if (character.character == '来') {
      tips.add('Contains 木 (tree), suggesting movement like a tree growing upward.');
    } else if (character.character == '去') {
      tips.add('Contains 土 (earth), suggesting going away from the ground.');
    } else if (character.character == '上' || character.character == '下') {
      tips.add('上 (up) has a line above, 下 (down) has a line below - remember the direction!');
    } else if (character.character == '中') {
      tips.add('A line through a box (丨 through 口), representing the middle or center.');
    } else if (character.character == '大') {
      tips.add('A person (人) with arms spread wide, representing "big".');
    } else if (character.character == '小') {
      tips.add('Three small strokes, representing something small.');
    } else if (character.character == '人') {
      tips.add('Looks like a person walking, the simplest representation of a person.');
    } else if (['一', '二', '三'].contains(character.character)) {
      tips.add('These are simple number characters - one, two, and three horizontal lines.');
    } else if (character.character == '四') {
      tips.add('Four is represented by a box (囗) with two lines inside.');
    } else if (character.character == '五') {
      tips.add('Five has a cross shape in the middle.');
    } else if (character.character == '六') {
      tips.add('Six has a roof (亠) and eight (八) below.');
    } else if (character.character == '七') {
      tips.add('Seven looks like a "7" rotated.');
    } else if (character.character == '八') {
      tips.add('Eight is two lines diverging, like splitting apart.');
    } else if (character.character == '九') {
      tips.add('Nine has a hook shape.');
    } else if (character.character == '十') {
      tips.add('Ten is a cross, representing completeness.');
    } else {
      tips.add('Practice writing this character multiple times to build muscle memory.');
      tips.add('Try to associate the shape with its meaning: "${character.meaning}".');
    }
    
    // Add pronunciation tip
    tips.add('Pronunciation: ${character.pinyin} - Practice saying it out loud!');
    
    // Add meaning tip
    tips.add('Meaning: ${character.meaning}');
    
    return tips.join('\n\n');
  }
}

