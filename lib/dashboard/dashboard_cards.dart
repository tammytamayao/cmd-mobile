import 'package:flutter/material.dart';
import 'formatters.dart';

class CardShell extends StatelessWidget {
  const CardShell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class FieldRow extends StatelessWidget {
  const FieldRow({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountDetailsCard extends StatelessWidget {
  const AccountDetailsCard({
    super.key,
    required this.fullName,
    required this.serialNumber,
    required this.zone,
  });

  final String fullName;
  final String serialNumber;
  final String zone;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Account Details",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          FieldRow(label: "Subscriber Name", value: fullName),
          FieldRow(label: "Subscriber ID", value: serialNumber),
          FieldRow(label: "Address", value: zone),
        ],
      ),
    );
  }
}

class AmountDueCard extends StatelessWidget {
  const AmountDueCard({
    super.key,
    required this.amountDue,
    required this.dueOn,
    required this.billingStatus,
    required this.onMakePayment,
  });

  final double amountDue;
  final String? dueOn;
  final String? billingStatus;
  final VoidCallback onMakePayment;

  @override
  Widget build(BuildContext context) {
    final dueDate = formatDate(dueOn);
    final showDue = dueDate != "N/A" && billingStatus != "paid";

    return CardShell(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Amount Due",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(amountDue),
            style: const TextStyle(
              fontSize: 44,
              height: 1.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          if (showDue) ...[
            const SizedBox(height: 10),
            Text(
              "Due by $dueDate",
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFEA580C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onMakePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Make a Payment",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentPlanCard extends StatelessWidget {
  const CurrentPlanCard({
    super.key,
    required this.packageName,
    required this.plan,
    required this.packageSpeed,
    required this.monthlyRate,
    required this.installedOn,
  });

  final String packageName;
  final String plan;
  final int packageSpeed;
  final num monthlyRate;
  final String? installedOn;

  @override
  Widget build(BuildContext context) {
    final installed = formatDate(installedOn);
    final showInstalled = installed != "N/A";

    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Current Plan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          FieldRow(label: "Package Plan", value: "$packageName$plan"),
          FieldRow(label: "Speed", value: "Up to $packageSpeed Mbps"),
          FieldRow(label: "Monthly Rate", value: formatCurrency(monthlyRate)),
          if (showInstalled) FieldRow(label: "Installed On", value: installed),
        ],
      ),
    );
  }
}
