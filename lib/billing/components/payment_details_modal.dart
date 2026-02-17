import 'package:cmd_mobile/models/payment.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../dashboard/formatters.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';
import 'status_pill.dart';

class PaymentDetailsModal {
  static Future<void> show(
    BuildContext context, {
    required int paymentId,
    required AuthService auth,
  }) {
    final service = PaymentService(api: auth.api);

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          _PaymentDetailsDialog(service: service, paymentId: paymentId),
    );
  }
}

class _PaymentDetailsDialog extends StatefulWidget {
  const _PaymentDetailsDialog({required this.service, required this.paymentId});

  final PaymentService service;
  final int paymentId;

  @override
  State<_PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends State<_PaymentDetailsDialog> {
  bool loading = true;
  String? error;
  Payment? payment;

  // Tweak this once to keep all rows aligned nicely
  static const double _labelWidth = 130;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
      payment = null;
    });

    try {
      final p = await widget.service.fetchById(widget.paymentId);
      if (!mounted) return;
      setState(() => payment = p);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // cap modal height but don't force it to fill
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // <-- key: don't stretch when content is short
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 10, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Payment Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Body (scrollable when needed)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: _body(),
              ),
            ),

            // Footer (right aligned close, like web)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (loading) {
      return const Center(
        child: Text(
          "Loading payment...",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Color(0xFFEF4444))),
      );
    }

    final p = payment;
    if (p == null) {
      return const Center(
        child: Text(
          "No payment selected.",
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    final label = _statusLabel(p.status);
    final tone = _tone(p.status);

    final receiptUrl = (p.receiptUrl ?? "").trim();
    final mime = (p.receipt?.mimeType ?? "").toLowerCase();
    final isImage = mime.startsWith("image/");

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Billing period (optional)
          if ((p.billingPeriodStart ?? "").isNotEmpty) ...[
            _rowText(
              "Billing Period",
              "${formatDate(p.billingPeriodStart)} – ${(p.billingPeriodEnd ?? "").isNotEmpty ? formatDate(p.billingPeriodEnd) : "-"}",
              maxLines: 2,
            ),
            const SizedBox(height: 8),
          ],

          _rowText("Payment Date", formatDate(p.paymentDate), strong: true),
          _rowText("Amount", formatCurrency(p.amount), strong: true),
          _rowText("Payment Method", p.paymentMethod ?? "-", strong: true),

          // Status aligned with the same value column
          _rowWidget("Status", StatusPill(label: label, tone: tone)),

          _rowText("Reference No.", p.referenceNumber ?? "-"),
          _rowText("Invoice No.", p.invoiceNumber ?? "-"),

          // Receipt section
          if (receiptUrl.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              "Receipt",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            if (isImage)
              _ReceiptImage(url: receiptUrl)
            else
              _ReceiptLink(url: receiptUrl),
            if ((p.receipt?.filename ?? "").isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _fileMetaLine(p.receipt!),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _rowText(String k, String v, {bool strong = false, int maxLines = 3}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(
              k,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                v,
                textAlign: TextAlign.right,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF111827),
                  fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWidget(String k, Widget value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(
              k,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: value),
          ),
        ],
      ),
    );
  }

  static String _fileMetaLine(PaymentReceiptMeta r) {
    final parts = <String>[];
    if ((r.filename ?? "").isNotEmpty) parts.add(r.filename!);
    if ((r.size ?? 0) > 0) {
      final kb = (r.size! / 1024.0);
      parts.add("${kb.toStringAsFixed(1)} KB");
    }
    return parts.join(" • ");
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

class _ReceiptImage extends StatelessWidget {
  const _ReceiptImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF9FAFB),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 320),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                "Failed to load receipt image.",
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptLink extends StatelessWidget {
  const _ReceiptLink({required this.url});
  final String url;

  Future<void> _open() async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _open,
        icon: const Icon(Icons.open_in_new, size: 18),
        label: const Text(
          "Open receipt",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF2563EB),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
