import 'package:cmd_mobile/models/payment.dart';
import 'package:flutter/material.dart';
import '../../dashboard/formatters.dart';
import 'empty_state_tab.dart';
import 'status_pill.dart';

class PaymentsTab extends StatelessWidget {
  const PaymentsTab({
    super.key,
    required this.payments,
    required this.onViewPayment,
  });

  final List<Payment> payments;
  final void Function(Payment p) onViewPayment;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const EmptyStateTab(
        title: "No payments yet",
        description:
            "Once payment is made, it’ll appear here with its details.",
      );
    }

    return Column(
      children: payments.map((p) {
        final label = _paymentLabel(p.status);
        final tone = _paymentTone(p.status);

        final method = (p.paymentMethod ?? "-").trim();
        final ref = (p.referenceNumber ?? "-").trim();

        return Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), // ✅ compact
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: date + status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatDate(p.paymentDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    StatusPill(label: label, tone: tone),
                  ],
                ),

                const SizedBox(height: 8),

                // Row 2: amount + button (same row, compact)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatCurrency(p.amount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18, // ✅ not too huge
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _CompactOutlineButton(
                      onPressed: () => onViewPayment(p),
                      text: "View details",
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Row 3: meta (small)
                Text(
                  "$method • $ref",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _paymentLabel(String status) {
    final s = status.toLowerCase();
    if (s == "processing") return "Processing";
    if (s == "completed" || s == "paid") return "Completed";
    if (s == "rejected" || s == "failed") return "Rejected";
    return status;
  }

  StatusTone _paymentTone(String status) {
    final s = status.toLowerCase();
    if (s == "completed" || s == "paid") return StatusTone.success;
    if (s == "processing") return StatusTone.warning;
    if (s == "rejected" || s == "failed") return StatusTone.danger;
    return StatusTone.neutral;
  }
}

class _CompactOutlineButton extends StatelessWidget {
  const _CompactOutlineButton({required this.onPressed, required this.text});
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32, // ✅ compact button height
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: const BorderSide(color: Color(0xFF3B82F6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: const Color(0xFF2563EB),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
