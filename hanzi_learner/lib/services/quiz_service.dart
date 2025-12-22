import 'dart:math';
import '../models/hanzi_character.dart';
import '../data/hsk_data.dart';

class QuizService {
  final List<HanziCharacter> _allCharacters;
  final List<String> _allPinyinOptions;
  final Random _random = Random();
  
  int _currentIndex = 0;
  final List<int> _unsureIndices = [];
  bool _hasUnsureCharacters = false;

  QuizService({int hskLevel = 1}) 
      : _allCharacters = HSKData.getHSKLevel1(),
        _allPinyinOptions = HSKData.getAllPinyinOptions() {
    _shuffleCharacters();
  }

  void _shuffleCharacters() {
    _allCharacters.shuffle(_random);
  }

  HanziCharacter? getCurrentCharacter() {
    if (_currentIndex >= _allCharacters.length) {
      return null;
    }
    return _allCharacters[_currentIndex];
  }

  List<String> generateOptions() {
    final current = getCurrentCharacter();
    if (current == null) return [];
    
    final options = <String>[current.pinyin];
    final wrongOptions = _allPinyinOptions
        .where((pinyin) => pinyin != current.pinyin)
        .toList()
      ..shuffle(_random);
    
    options.addAll(wrongOptions.take(3));
    options.shuffle(_random);
    
    return options;
  }

  bool checkAnswer(String selectedPinyin) {
    final current = getCurrentCharacter();
    if (current == null) return false;
    
    return selectedPinyin == current.pinyin;
  }

  void markAsUnsure() {
    if (!_unsureIndices.contains(_currentIndex)) {
      _unsureIndices.add(_currentIndex);
      _hasUnsureCharacters = true;
    }
  }

  bool moveToNext() {
    // If we're currently on an unsure character that we've returned to, remove it
    if (_unsureIndices.contains(_currentIndex)) {
      _unsureIndices.remove(_currentIndex);
      if (_unsureIndices.isEmpty) {
        _hasUnsureCharacters = false;
      }
    }
    
    _currentIndex++;
    
    // If there are unsure characters, go back to the first one
    if (_hasUnsureCharacters && _unsureIndices.isNotEmpty) {
      _currentIndex = _unsureIndices.first;
      return true;
    }
    
    return _currentIndex < _allCharacters.length;
  }

  bool hasMoreCharacters() {
    return _currentIndex < _allCharacters.length;
  }

  int getProgress() {
    return _currentIndex;
  }

  int getTotalCount() {
    return _allCharacters.length;
  }
}

