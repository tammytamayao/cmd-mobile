import 'package:cmd_mobile/models/billing.dart';
import 'package:flutter/material.dart';
import '../../dashboard/formatters.dart';
import 'empty_state_tab.dart';
import 'status_pill.dart';

class BillingsTab extends StatelessWidget {
  const BillingsTab({super.key, required this.bills});

  final List<Billing> bills;

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return const EmptyStateTab(
        title: "No billings yet",
        description:
            "When billing periods are generated, it’ll be displayed here.",
      );
    }

    final today = DateTime.now();

    final List<Widget> items = [];

    for (final b in bills) {
      final due = DateTime.tryParse(b.dueDate);
      final paid = _normalizeBillingStatus(b.status) == "paid";
      final overdue = !paid && (due != null) && due.isBefore(today);

      final label = paid ? "Paid" : (overdue ? "Overdue" : "Unpaid");
      final tone = paid
          ? StatusTone.success
          : overdue
          ? StatusTone.danger
          : StatusTone.warning;

      items.add(
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: Text(
              "${formatDate(b.startDate)} – ${formatDate(b.endDate)}",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "Due: ${formatDate(b.dueDate)}",
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            trailing: StatusPill(label: label, tone: tone),
          ),
        ),
      );
    }

    items.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Tip: Pull down to refresh",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ),
    );

    return Column(children: items);
  }

  String _normalizeBillingStatus(String s) {
    final v = s.toLowerCase().trim();
    if (v == "paid") return "paid";
    return "unpaid";
  }
}
