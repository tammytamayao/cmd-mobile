import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool show;
  final VoidCallback onToggleShow;

  const PasswordField({
    super.key,
    required this.controller,
    required this.show,
    required this.onToggleShow,
  });

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: "Enter your password",
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
      suffixIcon: IconButton(
        tooltip: show ? "Hide password" : "Show password",
        onPressed: onToggleShow,
        icon: Icon(show ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !show,
          textInputAction: TextInputAction.done,
          decoration: _decoration(),
        ),
      ],
    );
  }
}
