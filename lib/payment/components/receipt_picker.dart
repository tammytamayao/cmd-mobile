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

  String _filename(File f) {
    final p = f.path;
    final parts = p.split(Platform.pathSeparator);
    return parts.isNotEmpty ? parts.last : p;
  }

  IconData _iconForFile(File f) {
    final name = _filename(f).toLowerCase();
    if (name.endsWith(".pdf")) return Icons.picture_as_pdf_rounded;
    if (name.endsWith(".png") ||
        name.endsWith(".jpg") ||
        name.endsWith(".jpeg")) {
      return Icons.image_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: error != null
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Row(
            children: [
              Text(
                required ? "Receipt (required)" : "Receipt (optional)",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              if (hasFile)
                TextButton(
                  onPressed: onRemove,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  child: const Text(
                    "Remove",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: const Text(
                    "Upload",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // body
          if (!hasFile) ...[
            const Text(
              "Accepted: JPG, PNG, PDF",
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.attach_file_rounded, size: 18),
                label: const Text(
                  "Choose file",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF111827),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Icon(_iconForFile(file!), color: const Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _filename(file!),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (error != null) ...[
            const SizedBox(height: 10),
            Text(
              error!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
