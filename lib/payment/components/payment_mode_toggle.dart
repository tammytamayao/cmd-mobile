import 'package:flutter/material.dart';

/// Toggle between manual (receipt upload) and online (gateway) payment modes
class PaymentModeToggle extends StatelessWidget {
  const PaymentModeToggle({
    super.key,
    required this.mode,
    required this.onModeChange,
  });

  /// Current mode: "manual" or "online"
  final String mode;

  /// Callback when mode changes
  final ValueChanged<String> onModeChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildOption(
            label: "Upload Receipt",
            subtitle: "GCash Bills Pay, Cash",
            value: "manual",
            isActive: mode == "manual",
          ),
          const SizedBox(width: 4),
          _buildOption(
            label: "Pay Online",
            subtitle: "GCash, Maya, Card",
            value: "online",
            isActive: mode == "online",
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required String subtitle,
    required String value,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChange(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: const Color(0xFF2563EB), width: 2)
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
