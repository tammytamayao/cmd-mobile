import 'package:cmd_mobile/models/billing.dart';
import 'package:flutter/material.dart';

import '../../dashboard/formatters.dart';

class BillingDropdown extends StatelessWidget {
  const BillingDropdown({
    super.key,
    required this.openBillings,
    required this.value,
    required this.onChange,
  });

  final List<Billing> openBillings;
  final int? value;
  final ValueChanged<int?> onChange;

  @override
  Widget build(BuildContext context) {
    final List<Billing> items = openBillings.whereType<Billing>().toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          hint: Text(
            items.isEmpty
                ? "No open/overdue billings"
                : "Select billing period",
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          items: items.map((b) {
            final label =
                "${formatDate(b.startDate)} – ${formatDate(b.endDate)}";
            return DropdownMenuItem<int>(
              value: b.id,
              child: Text(label, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: items.isEmpty ? null : onChange,
        ),
      ),
    );
  }
}
