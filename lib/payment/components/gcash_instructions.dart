import 'package:flutter/material.dart';

import '../../dashboard/formatters.dart';

class GcashInstructions extends StatelessWidget {
  const GcashInstructions({
    super.key,
    required this.amount,
    required this.reference,
  });

  final num amount;
  final String reference;

  @override
  Widget build(BuildContext context) {
    const biller = "CMD Cable Vision Inc";

    Widget step(int n, String text) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              "$n",
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF111827),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        step(1, "Login to your GCash account."),
        const SizedBox(height: 10),
        step(2, "Tap Bills."),
        const SizedBox(height: 10),
        step(3, "Search for $biller and tap it."),
        const SizedBox(height: 10),
        step(4, "Fill out the required fields then press Next."),
        const SizedBox(height: 10),
        step(5, "Confirm payment then Download Image Receipt."),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _infoRow("Biller", biller),
              const SizedBox(height: 8),
              _infoRow("Subscriber/Account No.", reference, mono: true),
              const SizedBox(height: 8),
              _infoRow("Amount", formatCurrency(amount)),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _infoRow(String k, String v, {bool mono = false}) {
    return Row(
      children: [
        Text(k, style: const TextStyle(color: Color(0xFF6B7280))),
        const Spacer(),
        Text(
          v,
          style: TextStyle(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontFamily: mono ? "monospace" : null,
          ),
        ),
      ],
    );
  }
}
