import 'package:flutter/material.dart';
import '../../models/checkout.dart';

/// Card displaying payment verification status
class PaymentStatusCard extends StatelessWidget {
  const PaymentStatusCard({
    super.key,
    required this.status,
    required this.verifying,
    this.errorMessage,
    required this.onRetry,
    required this.onDone,
  });

  final CheckoutStatus? status;
  final bool verifying;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          const SizedBox(height: 16),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 24),
          _buildAction(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (verifying) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),
        ),
      );
    }

    if (status == CheckoutStatus.completed) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 32,
          color: Color(0xFF16A34A),
        ),
      );
    }

    if (status == CheckoutStatus.failed) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 32,
          color: Color(0xFFDC2626),
        ),
      );
    }

    // Processing or unknown
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Icon(
        Icons.schedule_rounded,
        size: 32,
        color: Color(0xFFD97706),
      ),
    );
  }

  Widget _buildTitle() {
    String title;
    Color color;

    if (verifying) {
      title = "Verifying Payment...";
      color = const Color(0xFF111827);
    } else if (status == CheckoutStatus.completed) {
      title = "Payment Successful!";
      color = const Color(0xFF16A34A);
    } else if (status == CheckoutStatus.failed) {
      title = "Payment Failed";
      color = const Color(0xFFDC2626);
    } else {
      title = "Payment Processing";
      color = const Color(0xFFD97706);
    }

    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Widget _buildSubtitle() {
    String subtitle;

    if (verifying) {
      subtitle = "Please wait while we confirm your transaction.";
    } else if (status == CheckoutStatus.completed) {
      subtitle = "Your payment has been received. Thank you!";
    } else if (status == CheckoutStatus.failed) {
      subtitle = errorMessage ??
          "Please try again or use a different payment method.";
    } else {
      subtitle =
          "This may take a few minutes. Check your billing history for the final status.";
    }

    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildAction() {
    if (verifying) {
      return const SizedBox.shrink();
    }

    if (status == CheckoutStatus.failed) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Try Again",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onDone,
        style: ElevatedButton.styleFrom(
          backgroundColor: status == CheckoutStatus.completed
              ? const Color(0xFF16A34A)
              : const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          status == CheckoutStatus.completed ? "View Billing" : "Done",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
