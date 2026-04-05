import 'package:flutter/material.dart';
import '../../models/checkout.dart';

/// Grid of buttons for selecting online payment method
class OnlineMethodSelector extends StatelessWidget {
  const OnlineMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChange,
  });

  final OnlinePaymentMethod selectedMethod;
  final ValueChanged<OnlinePaymentMethod> onMethodChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Payment Method",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: OnlinePaymentMethod.values.map((method) {
              final isActive = method == selectedMethod;
              return _MethodButton(
                label: method.label,
                isActive: isActive,
                onTap: () => onMethodChange(method),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  const _MethodButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}
