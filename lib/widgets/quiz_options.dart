import 'package:flutter/material.dart';

class QuizOptions extends StatelessWidget {
  final List<String> options;
  final String? selectedAnswer;
  final String correctPinyin;
  final bool showResult;
  final Function(String) onSelect;

  const QuizOptions({
    super.key,
    required this.options,
    required this.selectedAnswer,
    required this.correctPinyin,
    required this.showResult,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((pinyin) {
        final isSelected = selectedAnswer == pinyin;
        final isCorrectOption = pinyin == correctPinyin;
        Color? buttonColor;

        if (showResult) {
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
              onPressed: () => onSelect(pinyin),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor ??
                    (isSelected ? Colors.blue.shade100 : null),
                foregroundColor: buttonColor != null
                    ? Colors.white
                    : (isSelected ? Colors.blue.shade900 : null),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: showResult ? 0 : 2,
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
    );
  }
}

