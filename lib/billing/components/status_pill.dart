import 'package:flutter/material.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      StatusTone.success => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
      StatusTone.warning => (const Color(0xFFFFEDD5), const Color(0xFF9A3412)),
      StatusTone.danger => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
      StatusTone.neutral => (const Color(0xFFF3F4F6), const Color(0xFF374151)),
      StatusTone.info => (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

enum StatusTone { success, warning, danger, neutral, info }
