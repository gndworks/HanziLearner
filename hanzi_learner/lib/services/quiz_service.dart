import 'dart:math';
import '../models/hanzi_character.dart';
import '../data/hsk_data.dart';

class QuizService {
  final List<HanziCharacter> _allAvailableCharacters;
  final List<String> _allPinyinOptions;
  final Random _random = Random();
  
  // Active characters (initially 5 random ones)
  final List<HanziCharacter> _activeCharacters = [];
  final Map<int, int> _correctCountMap = {}; // character index -> correct count
  
  int _currentIndex = 0;
  int? _savedProgressIndex; // Where we were before going back to review
  final List<int> _unsureIndices = [];
  bool _hasUnsureCharacters = false;
  final List<int> _incorrectIndices = [];
  bool _hasIncorrectAnswers = false;
  
  int _nextAvailableCharacterIndex = 0;
  int _sessionWordCount = 0; // Total words answered in this session
  final int _sessionTarget; // Number of words to learn in this session

  QuizService({int hskLevel = 1, int sessionTarget = 5}) 
      : _allAvailableCharacters = HSKData.getHSKLevel1(),
        _allPinyinOptions = HSKData.getAllPinyinOptions(),
        _sessionTarget = sessionTarget {
    _initializeActiveCharacters();
  }

  void _initializeActiveCharacters() {
    // Shuffle all available characters
    final shuffled = List<HanziCharacter>.from(_allAvailableCharacters);
    shuffled.shuffle(_random);
    
    // Start with 5 random characters
    _activeCharacters.addAll(shuffled.take(5));
    _nextAvailableCharacterIndex = 5;
    
    // Initialize correct count for all active characters
    for (int i = 0; i < _activeCharacters.length; i++) {
      _correctCountMap[i] = 0;
    }
  }
  
  void _replaceLearnedCharacter(int index) {
    // Character at index has been learned (2 correct answers)
    // Replace it with a new character from the pool
    if (_nextAvailableCharacterIndex >= _allAvailableCharacters.length) {
      // No more characters available
      // If we have more than 1 character, remove this learned one
      if (_activeCharacters.length > 1) {
        _activeCharacters.removeAt(index);
        _correctCountMap.remove(index);
        // Adjust indices
        _adjustIndicesAfterRemoval(index);
      }
      // Otherwise, keep it (we need at least one character)
      return;
    }
    
    // Get next character from available pool
    _activeCharacters[index] = _allAvailableCharacters[_nextAvailableCharacterIndex];
    _correctCountMap[index] = 0;
    _nextAvailableCharacterIndex++;
    
    // Remove from incorrect/unsure lists if it was there
    _incorrectIndices.remove(index);
    _unsureIndices.remove(index);
    if (_incorrectIndices.isEmpty) {
      _hasIncorrectAnswers = false;
    }
    if (_unsureIndices.isEmpty) {
      _hasUnsureCharacters = false;
    }
  }
  
  void _adjustIndicesAfterRemoval(int removedIndex) {
    // Adjust all indices in maps that are greater than removedIndex
    final newCorrectCountMap = <int, int>{};
    final newIncorrectIndices = <int>[];
    final newUnsureIndices = <int>[];
    
    for (final entry in _correctCountMap.entries) {
      if (entry.key < removedIndex) {
        newCorrectCountMap[entry.key] = entry.value;
      } else if (entry.key > removedIndex) {
        newCorrectCountMap[entry.key - 1] = entry.value;
      }
    }
    
    for (final idx in _incorrectIndices) {
      if (idx < removedIndex) {
        newIncorrectIndices.add(idx);
      } else if (idx > removedIndex) {
        newIncorrectIndices.add(idx - 1);
      }
    }
    
    for (final idx in _unsureIndices) {
      if (idx < removedIndex) {
        newUnsureIndices.add(idx);
      } else if (idx > removedIndex) {
        newUnsureIndices.add(idx - 1);
      }
    }
    
    _correctCountMap.clear();
    _correctCountMap.addAll(newCorrectCountMap);
    _incorrectIndices.clear();
    _incorrectIndices.addAll(newIncorrectIndices);
    _unsureIndices.clear();
    _unsureIndices.addAll(newUnsureIndices);
    
    if (_savedProgressIndex != null && _savedProgressIndex! > removedIndex) {
      _savedProgressIndex = _savedProgressIndex! - 1;
    }
    if (_currentIndex > removedIndex) {
      _currentIndex--;
    }
  }

  HanziCharacter? getCurrentCharacter() {
    if (_currentIndex >= _activeCharacters.length) {
      return null;
    }
    return _activeCharacters[_currentIndex];
  }
  
  bool isReviewing() {
    return _savedProgressIndex != null;
  }
  
  bool isLearned(int index) {
    return _correctCountMap[index] != null && _correctCountMap[index]! >= 2;
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
    
    if (isCorrect) {
      // Increment correct count
      _correctCountMap[_currentIndex] = (_correctCountMap[_currentIndex] ?? 0) + 1;
    } else {
      // If answer is wrong, mark this character as incorrect
      if (!_incorrectIndices.contains(_currentIndex)) {
        _incorrectIndices.add(_currentIndex);
        _hasIncorrectAnswers = true;
      }
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
    if (wasCorrect) {
      // Check if character is now learned (2 correct answers)
      final currentCount = _correctCountMap[_currentIndex];
      if (currentCount != null && currentCount >= 2) {
        // Character is learned - increment session counter only when it reaches exactly 2
        if (currentCount == 2) {
          _sessionWordCount++;
        }
        
        // If we reached our target, we can stop (unless we have revisions pending)
        if (_sessionWordCount >= _sessionTarget && !isReviewing()) {
          return false;
        }

        // Character is learned, replace it with a new one
        _replaceLearnedCharacter(_currentIndex);
        // After replacement, _currentIndex still points to the same position (now with new character)
      }
      
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
    }
    
    // Handle progression or restoration from revision
    if (_savedProgressIndex != null) {
      // We were in revision mode, so restore our saved progress position
      _currentIndex = _savedProgressIndex!;
      _savedProgressIndex = null;
    } else {
      // Normal progression - increment
      _currentIndex++;
    }

    // Wrap around if we haven't reached the target yet
    if (_currentIndex >= _activeCharacters.length && _sessionWordCount < _sessionTarget) {
      _currentIndex = 0;
    }
    
    // After a correct answer, check if we should go back to incorrect/unsure characters
    // Priority: incorrect answers first, then unsure characters
    if (wasCorrect) {
      if (_hasIncorrectAnswers && _incorrectIndices.isNotEmpty) {
        // Save where we are before going back
        if (_savedProgressIndex == null) {
          _savedProgressIndex = _currentIndex;
        }
        _currentIndex = _incorrectIndices.first;
      } else if (_hasUnsureCharacters && _unsureIndices.isNotEmpty) {
        // Save where we are before going back
        if (_savedProgressIndex == null) {
          _savedProgressIndex = _currentIndex;
        }
        _currentIndex = _unsureIndices.first;
      }
    }
    
    return hasMoreCharacters();
  }

  bool hasMoreCharacters() {
    // We have more characters if:
    // 1. We haven't reached the learned target yet
    // 2. OR we have pending revisions (incorrect or unsure)
    return _activeCharacters.isNotEmpty && 
           (_sessionWordCount < _sessionTarget || 
            _incorrectIndices.isNotEmpty || 
            _unsureIndices.isNotEmpty);
  }

  int getProgress() {
    return _sessionWordCount;
  }

  int getTotalCount() {
    return _sessionTarget;
  }
  
  int getLearnedCount() {
    return _correctCountMap.values.where((count) => count >= 2).length;
  }
  
  int getSessionWordCount() {
    return _sessionWordCount;
  }
}

