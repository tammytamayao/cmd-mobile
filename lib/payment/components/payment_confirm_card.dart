import 'dart:io';

import 'package:flutter/material.dart';

import 'payment_card_shell.dart';
import 'receipt_picker.dart';

class PaymentConfirmCard extends StatelessWidget {
  const PaymentConfirmCard({
    super.key,
    required this.receiptRequired,
    required this.receiptFile,
    required this.receiptError,
    required this.onPickReceipt,
    required this.onRemoveReceipt,
    required this.submitError,
    required this.submitting,
    required this.submitDisabled,
    required this.onSubmit,
  });

  final bool receiptRequired;
  final File? receiptFile;
  final String? receiptError;
  final VoidCallback onPickReceipt;
  final VoidCallback onRemoveReceipt;

  final String? submitError;
  final bool submitting;
  final bool submitDisabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return PaymentCardShell(
      title: "Confirm Your Payment",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            receiptRequired
                ? "Upload your gcash receipt to submit payment."
                : "Uploading a paper receipt for submission",
            style: const TextStyle(color: Color(0xFF6B7280), height: 1.35),
          ),
          const SizedBox(height: 12),

          ReceiptPicker(
            required: receiptRequired,
            file: receiptFile,
            error: receiptError,
            onPick: onPickReceipt,
            onRemove: onRemoveReceipt,
          ),

          if (submitError != null) ...[
            const SizedBox(height: 10),
            Text(
              submitError!,
              style: const TextStyle(color: Color(0xFFEF4444)),
            ),
          ],

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: submitDisabled ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                disabledBackgroundColor: const Color(0xFF93C5FD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                submitting ? "Submitting..." : "Submit Payment",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
