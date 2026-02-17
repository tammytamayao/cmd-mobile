import 'package:cmd_mobile/models/billing.dart';
import 'package:flutter/material.dart';

import '../../dashboard/formatters.dart';
import 'payment_card_shell.dart';
import 'billing_dropdown.dart';
import 'method_dropdown.dart';

class PaymentFormCard extends StatelessWidget {
  const PaymentFormCard({
    super.key,
    required this.fullName,
    required this.planName,
    required this.totalAmount,
    required this.openBillings,
    required this.billingId,
    required this.onBillingChange,
    required this.paymentMethod,
    required this.onPaymentMethodChange,
  });

  final String fullName;
  final String planName;
  final num totalAmount;

  final List<Billing> openBillings;
  final int? billingId;
  final ValueChanged<int?> onBillingChange;

  final String paymentMethod;
  final ValueChanged<String> onPaymentMethodChange;

  @override
  Widget build(BuildContext context) {
    return PaymentCardShell(
      title: "Payment Form",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv("Full Name", fullName),
          const SizedBox(height: 10),
          _kv("Plan Name", planName),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          Row(
            children: [
              const Text(
                "Total Amount Due",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                formatCurrency(totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            "Billing Period",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          BillingDropdown(
            openBillings: openBillings,
            value: billingId,
            onChange: onBillingChange,
          ),

          const SizedBox(height: 14),

          const Text(
            "Payment Method",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          MethodDropdown(value: paymentMethod, onChange: onPaymentMethodChange),

          const SizedBox(height: 14),

          if (paymentMethod == "CASH")
            _note(
              bg: const Color(0xFFFFFBEB),
              border: const Color(0xFFFDE68A),
              text:
                  "You selected Cash. Please pay at our office or to an authorized person.",
              textColor: const Color(0xFF92400E),
            )
          else
            _note(
              bg: const Color(0xFFEFF6FF),
              border: const Color(0xFFBFDBFE),
              text:
                  "You selected GCash Bills Pay. Uploading a screenshot is required.",
              textColor: const Color(0xFF1D4ED8),
            ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          k,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
        ),
        const SizedBox(height: 4),
        Text(
          v,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _note({
    required Color bg,
    required Color border,
    required String text,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
