import 'dart:math';
import '../models/hanzi_character.dart';
import '../data/hsk_data.dart';
import 'progress_service.dart';

class QuizService {
  final List<HanziCharacter> _allAvailableCharacters;
  final List<String> _allPinyinOptions;
  final Random _random = Random();
  final int hskLevel;
  
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

  QuizService._({
    required List<HanziCharacter> allAvailableCharacters,
    required List<String> allPinyinOptions,
    required int sessionTarget,
    required this.hskLevel,
  })  : _allAvailableCharacters = allAvailableCharacters,
        _allPinyinOptions = allPinyinOptions,
        _sessionTarget = sessionTarget {
    _initializeActiveCharacters();
  }

  static Future<QuizService> create({int hskLevel = 1, int sessionTarget = 5}) async {
    final characters = await HSKData.getHSKLevel(hskLevel);
    final pinyinOptions = await HSKData.getAllPinyinOptions(level: hskLevel);
    return QuizService._(
      allAvailableCharacters: characters,
      allPinyinOptions: pinyinOptions,
      sessionTarget: sessionTarget,
      hskLevel: hskLevel,
    );
  }

  void _initializeActiveCharacters() {
    final unlearned = _allAvailableCharacters
        .where((char) => !ProgressService.isLearned(char.character))
        .toList();
    
    final pool = unlearned.isNotEmpty ? unlearned : _allAvailableCharacters;
    final shuffled = List<HanziCharacter>.from(pool);
    shuffled.shuffle(_random);
    
    final initialCount = min(5, shuffled.length);
    _activeCharacters.addAll(shuffled.take(initialCount));
    _nextAvailableCharacterIndex = initialCount;
    
    for (int i = 0; i < _activeCharacters.length; i++) {
      _correctCountMap[i] = 0;
    }
  }
  
  void _replaceLearnedCharacter(int index) {
    ProgressService.markAsLearned(_activeCharacters[index].character);

    final unlearnedRemaining = _allAvailableCharacters
        .skip(_nextAvailableCharacterIndex)
        .where((char) => !ProgressService.isLearned(char.character))
        .toList();

    if (unlearnedRemaining.isEmpty) {
      if (_activeCharacters.length > 1) {
        _activeCharacters.removeAt(index);
        _correctCountMap.remove(index);
        _adjustIndicesAfterRemoval(index);
      }
      return;
    }
    
    _activeCharacters[index] = unlearnedRemaining.first;
    _correctCountMap[index] = 0;
    
    _nextAvailableCharacterIndex = _allAvailableCharacters.indexOf(unlearnedRemaining.first) + 1;
    
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
      _correctCountMap[_currentIndex] = (_correctCountMap[_currentIndex] ?? 0) + 1;
    } else {
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
      final currentCount = _correctCountMap[_currentIndex];
      if (currentCount != null && currentCount >= 2) {
        if (currentCount == 2) {
          _sessionWordCount++;
        }
        
        if (_sessionWordCount >= _sessionTarget && !isReviewing()) {
          ProgressService.markAsLearned(_activeCharacters[_currentIndex].character);
          return false;
        }

        _replaceLearnedCharacter(_currentIndex);
      }
      
      if (_incorrectIndices.contains(_currentIndex)) {
        _incorrectIndices.remove(_currentIndex);
        if (_incorrectIndices.isEmpty) {
          _hasIncorrectAnswers = false;
        }
      }
      
      if (_unsureIndices.contains(_currentIndex)) {
        _unsureIndices.remove(_currentIndex);
        if (_unsureIndices.isEmpty) {
          _hasUnsureCharacters = false;
        }
      }
    }
    
    if (_savedProgressIndex != null) {
      _currentIndex = _savedProgressIndex!;
      _savedProgressIndex = null;
    } else {
      _currentIndex++;
    }

    if (_currentIndex >= _activeCharacters.length && _sessionWordCount < _sessionTarget) {
      _currentIndex = 0;
    }
    
    if (wasCorrect) {
      if (_hasIncorrectAnswers && _incorrectIndices.isNotEmpty) {
        if (_savedProgressIndex == null) {
          _savedProgressIndex = _currentIndex;
        }
        _currentIndex = _incorrectIndices.first;
      } else if (_hasUnsureCharacters && _unsureIndices.isNotEmpty) {
        if (_savedProgressIndex == null) {
          _savedProgressIndex = _currentIndex;
        }
        _currentIndex = _unsureIndices.first;
      }
    }
    
    return hasMoreCharacters();
  }

  bool hasMoreCharacters() {
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

