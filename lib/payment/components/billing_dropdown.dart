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

  bool _isUnpaid(Billing b) {
    final s = b.status.toLowerCase().trim();
    // adjust if your backend uses different status values
    return s != "paid" && s != "completed";
  }

  DateTime _parseDate(String v) => DateTime.tryParse(v) ?? DateTime(1970);

  @override
  Widget build(BuildContext context) {
    final items = openBillings.where(_isUnpaid).toList()
      ..sort((a, b) => _parseDate(b.dueDate).compareTo(_parseDate(a.dueDate)));

    // ✅ prevent DropdownButton crash if selected value isn't in items
    final safeValue = (value != null && items.any((b) => b.id == value))
        ? value
        : null;

    final hasItems = items.isNotEmpty;

    return Container(
      height: 42, // ✅ match MethodDropdown feel
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Color(0xFF6B7280),
          ),
          dropdownColor: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          hint: Text(
            hasItems ? "Select billing period" : "No open/overdue billings",
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          items: items.map((b) {
            final label =
                "${formatDate(b.startDate)} – ${formatDate(b.endDate)}";

            return DropdownMenuItem<int>(
              value: b.id,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            );
          }).toList(),
          onChanged: hasItems ? onChange : null,
        ),
      ),
    );
  }
}
