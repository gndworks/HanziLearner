import 'dart:math';
import '../models/hanzi_character.dart';
import '../data/hsk_data.dart';

class QuizService {
  final List<HanziCharacter> _allCharacters;
  final List<String> _allPinyinOptions;
  final Random _random = Random();
  
  int _currentIndex = 0;
  int? _savedProgressIndex; // Where we were before going back to review
  final List<int> _unsureIndices = [];
  bool _hasUnsureCharacters = false;
  final List<int> _incorrectIndices = [];
  bool _hasIncorrectAnswers = false;

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
    
    final isCorrect = selectedPinyin == current.pinyin;
    
    // If answer is wrong, mark this character as incorrect
    if (!isCorrect && !_incorrectIndices.contains(_currentIndex)) {
      _incorrectIndices.add(_currentIndex);
      _hasIncorrectAnswers = true;
    }
    
    return isCorrect;
  }

  void markAsUnsure() {
    if (!_unsureIndices.contains(_currentIndex)) {
      _unsureIndices.add(_currentIndex);
      _hasUnsureCharacters = true;
    }
  }

  bool moveToNext({bool wasCorrect = false}) {
    // Only remove from lists if we got it correct (meaning we're reviewing it)
    if (wasCorrect) {
      final wasReviewing = _incorrectIndices.contains(_currentIndex) || 
                          _unsureIndices.contains(_currentIndex);
      
      // If we're currently on an incorrect character that we've returned to, remove it
      if (_incorrectIndices.contains(_currentIndex)) {
        _incorrectIndices.remove(_currentIndex);
        if (_incorrectIndices.isEmpty) {
          _hasIncorrectAnswers = false;
        }
      }
      
      // If we're currently on an unsure character that we've returned to, remove it
      if (_unsureIndices.contains(_currentIndex)) {
        _unsureIndices.remove(_currentIndex);
        if (_unsureIndices.isEmpty) {
          _hasUnsureCharacters = false;
        }
      }
      
      if (wasReviewing) {
        // We were reviewing, so restore our saved progress position
        if (_savedProgressIndex != null) {
          _currentIndex = _savedProgressIndex!;
          _savedProgressIndex = null;
        }
        // Don't increment here - we're resuming from saved position
      } else {
        // Normal progression - increment
        _currentIndex++;
      }
      
      // After a correct answer, check if we should go back to incorrect/unsure characters
      // Priority: incorrect answers first, then unsure characters
      if (_hasIncorrectAnswers && _incorrectIndices.isNotEmpty) {
        // Save where we are before going back
        if (_savedProgressIndex == null) {
          _savedProgressIndex = _currentIndex;
        }
        _currentIndex = _incorrectIndices.first;
        return true;
      }
      
      if (_hasUnsureCharacters && _unsureIndices.isNotEmpty) {
        // Save where we are before going back
        if (_savedProgressIndex == null) {
          _savedProgressIndex = _currentIndex;
        }
        _currentIndex = _unsureIndices.first;
        return true;
      }
    } else {
      // Wrong answer: just move to next character in sequence
      _currentIndex++;
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

