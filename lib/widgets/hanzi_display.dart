import 'package:flutter/material.dart';
import '../models/hanzi_character.dart';

class HanziDisplay extends StatelessWidget {
  final HanziCharacter character;

  const HanziDisplay({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: SelectableText(
              character.character,
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (character.meaning.isNotEmpty) ...[
          const SizedBox(height: 24),
          Center(
            child: SelectableText(
              '(${character.meaning})',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

