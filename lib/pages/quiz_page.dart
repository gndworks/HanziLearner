import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../services/memorization_service.dart';
import '../widgets/session_header.dart';
import '../widgets/hanzi_display.dart';
import '../widgets/quiz_options.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  QuizService? _quizService;
  List<String> _options = [];
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeQuizService();
  }

  Future<void> _initializeQuizService() async {
    final service = await QuizService.create(hskLevel: 1);
    if (mounted) {
      setState(() {
        _quizService = service;
        _isLoading = false;
      });
      _loadQuestion();
    }
  }

  void _loadQuestion() {
    if (_quizService == null) return;
    final character = _quizService!.getCurrentCharacter();
    if (character != null) {
      setState(() {
        _options = _quizService!.generateOptions();
        _selectedAnswer = null;
        _showResult = false;
        _isCorrect = false;
      });
    }
  }

  void _selectAnswer(String pinyin) {
    if (_showResult || _quizService == null) return;
    
    setState(() {
      _selectedAnswer = pinyin;
      _isCorrect = _quizService!.checkAnswer(pinyin);
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
    if (_quizService == null) return;
    final hasMore = _quizService!.moveToNext(wasCorrect: wasCorrect);
    if (hasMore) {
      _loadQuestion();
    } else {
      _showCompletionDialog();
    }
  }

  void _showUnsureDialog() {
    if (_quizService == null) return;
    final character = _quizService!.getCurrentCharacter();
    if (character == null) return;

    final tip = MemorizationService.generateMemorizationTip(character);
    _quizService!.markAsUnsure();

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
            onPressed: () {
              Navigator.of(context).pop();
              _moveToNext(wasCorrect: false);
            },
            child: const Text('Got it, to the next one'),
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
        content: Text('You have learned ${_quizService?.getSessionWordCount() ?? 0} characters in this session.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Reset quiz
              setState(() {
                _isLoading = true;
              });
              final service = await QuizService.create(hskLevel: 1);
              if (mounted) {
                setState(() {
                  _quizService = service;
                  _isLoading = false;
                });
                _loadQuestion();
              }
            },
            child: const Text('Start Over'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _quizService == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final character = _quizService!.getCurrentCharacter();
    
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
              SessionHeader(
                sessionWordCount: _quizService!.getSessionWordCount(),
                isReviewing: _quizService!.isReviewing(),
              ),
              const SizedBox(height: 32),
              
              HanziDisplay(character: character),
              const SizedBox(height: 32),
              
              // Multiple choice options
              Expanded(
                child: SingleChildScrollView(
                  child: QuizOptions(
                    options: _options,
                    selectedAnswer: _selectedAnswer,
                    correctPinyin: character.pinyin,
                    showResult: _showResult,
                    onSelect: _selectAnswer,
                  ),
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
                  label: const Text('Unsure? Get a tip and skip'),
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

