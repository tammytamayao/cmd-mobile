import 'dart:io';

import 'package:flutter/material.dart';

class ReceiptPicker extends StatelessWidget {
  const ReceiptPicker({
    super.key,
    required this.required,
    required this.file,
    required this.error,
    required this.onPick,
    required this.onRemove,
  });

  final bool required;
  final File? file;
  final String? error;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Receipt",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              if (file != null)
                TextButton(onPressed: onRemove, child: const Text("Remove"))
              else
                TextButton(onPressed: onPick, child: const Text("Upload")),
            ],
          ),
          const SizedBox(height: 6),
          if (file == null)
            const Text(
              "Accepted: JPG, PNG, PDF",
              style: TextStyle(color: Color(0xFF6B7280)),
            )
          else
            Text(
              file!.path.split("/").last,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(error!, style: const TextStyle(color: Color(0xFFEF4444))),
          ],
        ],
      ),
    );
  }
}
