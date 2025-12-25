import 'package:flutter/material.dart';
import '../models/hanzi_character.dart';
import 'radical_info_dialog.dart';

class RadicalButtons extends StatelessWidget {
  final HanziCharacter character;

  const RadicalButtons({
    super.key,
    required this.character,
  });

  void _showRadicalPopup(BuildContext context, String symbol) {
    RadicalInfoDialog.show(context, symbol);
  }

  @override
  Widget build(BuildContext context) {
    // The radicals field contains a list of radical symbols
    final radicals = character.radicals;
    
    if (radicals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            radicals.length == 1 ? 'Radical:' : 'Radicals:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: radicals.map((radicalSymbol) {
              return InkWell(
                onTap: () => _showRadicalPopup(context, radicalSymbol),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        radicalSymbol,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

