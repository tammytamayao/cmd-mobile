import 'package:flutter/material.dart';

class MethodDropdown extends StatelessWidget {
  const MethodDropdown({
    super.key,
    required this.value,
    required this.onChange,
  });

  final String value;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    const options = ["GCASH", "CASH"]; // BANK_TRANSFER later

    String label(String v) {
      if (v == "GCASH") return "GCash";
      if (v == "BANK_TRANSFER") return "Bank Transfer";
      return "Cash";
    }

    return Container(
      height: 44, // ✅ consistent touch target (matches your buttons vibe)
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: options
              .map(
                (v) =>
                    DropdownMenuItem<String>(value: v, child: Text(label(v))),
              )
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChange(v);
          },
        ),
      ),
    );
  }
}
