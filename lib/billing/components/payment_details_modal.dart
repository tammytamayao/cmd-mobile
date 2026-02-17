import 'package:cmd_mobile/models/payment.dart';
import 'package:flutter/material.dart';
import '../../dashboard/formatters.dart';
import 'status_pill.dart';

class PaymentDetailsModal {
  static Future<void> show(BuildContext context, Payment p) {
    final label = _statusLabel(p.status);
    final tone = _tone(p.status);

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title bar
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Payment Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: "Close",
                  ),
                ],
              ),
              const Divider(height: 1),

              const SizedBox(height: 12),

              if (p.billingPeriodStart != null)
                _row(
                  "Billing Period",
                  "${formatDate(p.billingPeriodStart)} – ${p.billingPeriodEnd != null ? formatDate(p.billingPeriodEnd) : "-"}",
                ),

              _row("Payment Date", formatDate(p.paymentDate)),
              _row("Amount", formatCurrency(p.amount), strong: true),
              _row("Payment Method", p.paymentMethod ?? "-"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Status",
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  StatusPill(label: label, tone: tone),
                ],
              ),
              const SizedBox(height: 8),
              _row("Reference No.", p.referenceNumber ?? "-"),
              _row("Invoice No.", p.invoiceNumber ?? "-"),

              if (p.receiptUrl != null && p.receiptUrl!.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Receipt",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                // For now we show a link-like button (image preview can be added later)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // Later: open url_launcher to view receipt
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("TODO: Open receipt URL")),
                      );
                    },
                    child: const Text("Open receipt"),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      "Close",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _row(String k, String v, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: Color(0xFF6B7280))),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    final s = status.toLowerCase();
    if (s == "processing") return "Processing";
    if (s == "completed" || s == "paid") return "Completed";
    if (s == "rejected" || s == "failed") return "Rejected";
    return status;
  }

  static StatusTone _tone(String status) {
    final s = status.toLowerCase();
    if (s == "completed" || s == "paid") return StatusTone.success;
    if (s == "processing") return StatusTone.warning;
    if (s == "rejected" || s == "failed") return StatusTone.danger;
    return StatusTone.neutral;
  }
}
