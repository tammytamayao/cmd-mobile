import 'package:flutter/material.dart';

import 'payment_card_shell.dart';
import 'gcash_instructions.dart';

class PaymentInstructionsCard extends StatelessWidget {
  const PaymentInstructionsCard({
    super.key,
    required this.paymentMethod,
    required this.amount,
    required this.reference,
    required this.selectedPeriodLabel,
  });

  final String paymentMethod;
  final num amount;
  final String reference;
  final String selectedPeriodLabel;

  @override
  Widget build(BuildContext context) {
    final title = paymentMethod == "GCASH"
        ? "Pay via GCash Bills"
        : "Cash Payment Instructions";

    return PaymentCardShell(
      title: title,
      child: paymentMethod == "GCASH"
          ? GcashInstructions(amount: amount, reference: reference)
          : const Text(
              "Please pay at our office or to an authorized collector. Keep the receipt and upload a photo here to speed up verification.",
              style: TextStyle(
                color: Color(0xFF374151),
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}
