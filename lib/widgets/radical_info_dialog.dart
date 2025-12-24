import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'compound_radical_breakdown.dart';

class RadicalInfoDialog extends StatelessWidget {
  final String symbol;
  final Map<String, dynamic>? _radicalInfo;
  final Map<String, dynamic>? _compoundInfo;

  const RadicalInfoDialog._({
    required this.symbol,
    required Map<String, dynamic>? radicalInfo,
    required Map<String, dynamic>? compoundInfo,
  }) : _radicalInfo = radicalInfo,
       _compoundInfo = compoundInfo;

  static Future<void> show(BuildContext context, String symbol) async {
    final radicalInfo = await _loadRadicalInfo(symbol);
    final compoundInfo = await _loadCompoundRadicalInfo(symbol);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => RadicalInfoDialog._(
        symbol: symbol,
        radicalInfo: radicalInfo,
        compoundInfo: compoundInfo,
      ),
    );
  }

  static Future<Map<String, dynamic>?> _loadRadicalInfo(String symbol) async {
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

  static Future<Map<String, dynamic>?> _loadCompoundRadicalInfo(String symbol) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/radicals/compound_radicals.json');
      final Map<String, dynamic> compoundData = json.decode(jsonString);
      final List<dynamic> compoundRadicals = compoundData['compound_radicals'] as List<dynamic>;

      for (var compound in compoundRadicals) {
        if (compound['radical'] == symbol) {
          return compound as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Error loading compound radical info: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final radical = _radicalInfo;
    final compound = _compoundInfo;
    
    return AlertDialog(
      title: Row(
        children: [
          Text(
            symbol,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          if (radical != null)
            Text(
              radical['pinyin'] ?? '',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
      content: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: radical != null || compound != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (radical != null) ...[
                        if (radical['english_description'] != null) ...[
                          SelectableText(
                            radical['english_description'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (radical['origin'] != null) ...[
                          SelectableText(
                            'Origin:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            radical['origin'] as String,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (radical['tip'] != null) ...[
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
                                    Icon(
                                      Icons.lightbulb_outline,
                                      size: 18,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 6),
                                    SelectableText(
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
                                SelectableText(
                                  radical['tip'] as String,
                                  style: const TextStyle(fontSize: 14, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                      if (compound != null) ...[
                        CompoundRadicalBreakdown(compoundInfo: compound),
                      ],
                    ],
                  )
                : SelectableText(
                    'Information for radical "$symbol" not found.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

