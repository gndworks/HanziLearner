import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../services/memorization_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late QuizService _quizService;
  List<String> _options = [];
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _quizService = QuizService(hskLevel: 1);
    _loadQuestion();
  }

  void _loadQuestion() {
    final character = _quizService.getCurrentCharacter();
    if (character != null) {
      setState(() {
        _options = _quizService.generateOptions();
        _selectedAnswer = null;
        _showResult = false;
        _isCorrect = false;
      });
    }
  }

  void _selectAnswer(String pinyin) {
    if (_showResult) return;
    
    setState(() {
      _selectedAnswer = pinyin;
      _isCorrect = _quizService.checkAnswer(pinyin);
      _showResult = true;
    });

    if (_isCorrect) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _moveToNext(wasCorrect: true);
        }
      });
    }
  }

  void _moveToNext({bool wasCorrect = false}) {
    final hasMore = _quizService.moveToNext(wasCorrect: wasCorrect);
    if (hasMore) {
      _loadQuestion();
    } else {
      _showCompletionDialog();
    }
  }

  void _showUnsureDialog() {
    final character = _quizService.getCurrentCharacter();
    if (character == null) return;

    final tip = MemorizationService.generateMemorizationTip(character);
    _quizService.markAsUnsure();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Memorization Tip for ${character.character}'),
        content: SingleChildScrollView(
          child: Text(
            tip,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Text('You have learned ${_quizService.getSessionWordCount()} characters in this session.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset quiz
              setState(() {
                _quizService = QuizService(hskLevel: 1);
                _loadQuestion();
              });
            },
            child: const Text('Start Over'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final character = _quizService.getCurrentCharacter();
    
    if (character == null) {
      return const Scaffold(
        body: Center(child: Text('No more characters!')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('HSK Level 1 - Hanzi Learner'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Session word count
              Text(
                'Words this session: ${_quizService.getSessionWordCount()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 32),
              
              // Revision label
              if (_quizService.isReviewing())
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'REVISION',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              if (_quizService.isReviewing()) const SizedBox(height: 16),
              
              // Hanzi character display
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    character.character,
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Meaning display
              if (character.meaning.isNotEmpty)
                Text(
                  '(${character.meaning})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 32),
              
              // Multiple choice options
              Expanded(
                child: Column(
                  children: _options.map((pinyin) {
                    final isSelected = _selectedAnswer == pinyin;
                    final isCorrectOption = pinyin == character.pinyin;
                    Color? buttonColor;
                    
                    if (_showResult) {
                      if (isCorrectOption) {
                        buttonColor = Colors.green;
                      } else if (isSelected && !isCorrectOption) {
                        buttonColor = Colors.red;
                      }
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () => _selectAnswer(pinyin),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor ?? 
                                (isSelected ? Colors.blue.shade100 : null),
                            foregroundColor: buttonColor != null 
                                ? Colors.white 
                                : (isSelected ? Colors.blue.shade900 : null),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: _showResult ? 0 : 2,
                          ),
                          child: Text(
                            pinyin,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Next button (shown when answer is wrong)
              if (_showResult && !_isCorrect)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _moveToNext,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Unsure button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _showUnsureDialog,
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Unsure? Get a tip'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                    side: BorderSide(color: Colors.orange.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

