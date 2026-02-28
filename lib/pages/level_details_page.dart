import 'package:flutter/material.dart';
import '../data/hsk_data.dart';
import '../models/hanzi_character.dart';
import '../services/progress_service.dart';
import '../services/quiz_service.dart';
import 'quiz_page.dart';

class LevelDetailsPage extends StatefulWidget {
  final int level;

  const LevelDetailsPage({
    super.key,
    required this.level,
  });

  @override
  State<LevelDetailsPage> createState() => _LevelDetailsPageState();
}

class _LevelDetailsPageState extends State<LevelDetailsPage> {
  List<HanziCharacter> characters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final data = await HSKData.getHSKLevel(widget.level);
    if (mounted) {
      setState(() {
        characters = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('HSK Level ${widget.level}'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryHeader(),
                Expanded(
                  child: _buildCharactersGrid(),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: characters.isEmpty 
          ? null 
          : FloatingActionButton.extended(
              onPressed: () => _startQuiz(context),
              label: const Text('Start Study Session'),
              icon: const Icon(Icons.school),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
    );
  }

  Widget _buildSummaryHeader() {
    final learned = ProgressService.getLearnedCount(
      characters.map((c) => c.character).toList(),
    );
    final total = characters.length;
    final progress = total > 0 ? learned / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$learned / $total Learned',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharactersGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final char = characters[index];
        final isLearned = ProgressService.isLearned(char.character);

        return _buildCharacterCard(char, isLearned);
      },
    );
  }

  Widget _buildCharacterCard(HanziCharacter char, bool isLearned) {
    return Container(
      decoration: BoxDecoration(
        color: isLearned ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLearned ? Colors.green.shade200 : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              char.character,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isLearned ? Colors.green.shade900 : Colors.black87,
              ),
            ),
            if (isLearned)
              Icon(
                Icons.check_circle,
                size: 14,
                color: Colors.green.shade600,
              ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(level: widget.level),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _loadCharacters();
        });
      }
    });
  }
}
