import 'package:flutter/material.dart';

class Segmented extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChange,
  });

  final List<({String label, String value})> options;
  final String value;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // gray-100
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((o) {
          final active = o.value == value;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton(
              onPressed: () => onChange(o.value),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 36),
                backgroundColor: active ? Colors.white : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                o.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: active
                      ? const Color(0xFF111827)
                      : const Color(0xFF374151),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
