import 'package:flutter/material.dart';

class IdentityField extends StatelessWidget {
  final TextEditingController serialController;

  const IdentityField({super.key, required this.serialController});

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: "e.g. 105959-210",
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)), // gray-300
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6)), // blue-500
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Subscriber Number",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: serialController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          enableSuggestions: false,
          decoration: _decoration(),
        ),
      ],
    );
  }
}
