import 'package:flutter/material.dart';

class SessionHeader extends StatelessWidget {
  final int sessionWordCount;
  final bool isReviewing;

  const SessionHeader({
    super.key,
    required this.sessionWordCount,
    required this.isReviewing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Words this session: $sessionWordCount',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade700,
          ),
        ),
        if (isReviewing) ...[
          const SizedBox(height: 16),
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
        ],
      ],
    );
  }
}

