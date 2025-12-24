import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hanzi_character.dart';

class RadicalButtons extends StatelessWidget {
  final HanziCharacter character;

  const RadicalButtons({
    super.key,
    required this.character,
  });

  Future<Map<String, dynamic>?> _loadRadicalInfo(String symbol) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/radicals/radicals_with_tips.json');
      final List<dynamic> radicalsData = json.decode(jsonString);
      
      for (var radical in radicalsData) {
        if (radical['symbol'] == symbol) {
          return radical as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Error loading radical info: $e');
    }
    return null;
  }

  void _showRadicalPopup(BuildContext context, String symbol) async {
    final radicalInfo = await _loadRadicalInfo(symbol);
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              symbol,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            if (radicalInfo != null)
              Text(
                radicalInfo['pinyin'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: radicalInfo != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (radicalInfo['english_description'] != null) ...[
                      Text(
                        radicalInfo['english_description'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (radicalInfo['origin'] != null) ...[
                      Text(
                        'Origin:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        radicalInfo['origin'] as String,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (radicalInfo['tip'] != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline, 
                                     size: 18, 
                                     color: Colors.orange.shade700),
                                const SizedBox(width: 6),
                                Text(
                                  'Memorization Tip:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              radicalInfo['tip'] as String,
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                )
              : Text(
                  'Information for radical "$symbol" not found.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

