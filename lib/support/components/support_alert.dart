import 'package:flutter/material.dart';

class SupportAlert extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  const SupportAlert({
    super.key,
    required this.text,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  const SupportAlert.error({
    super.key,
    required this.text,
  })  : bgColor = const Color(0xFFFEF2F2),
        borderColor = const Color(0xFFFECACA),
        textColor = const Color(0xFFB91C1C);

  const SupportAlert.success({
    super.key,
    required this.text,
  })  : bgColor = const Color(0xFFF0FDF4),
        borderColor = const Color(0xFFBBF7D0),
        textColor = const Color(0xFF15803D);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
