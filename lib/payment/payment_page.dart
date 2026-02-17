import 'dart:io';

import 'package:cmd_mobile/models/billing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../dashboard/formatters.dart';
import '../models/subscriber_me.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/payment_service.dart';

import 'components/payment_form_card.dart';
import 'components/payment_instructions_card.dart';
import 'components/payment_confirm_card.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.auth});
  final AuthService auth;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  SubscriberMe? me;
  List<Billing> openBillings = [];

  bool loading = true;
  String? error;

  int? billingId;
  String paymentMethod = "GCASH"; // GCASH | CASH (BANK_TRANSFER later)

  File? receiptFile;
  String? receiptError;

  bool submitting = false;
  String? submitError;

  late final PaymentService paymentService;

  // Same constants as web
  static const String gcashBillerName = "CMD Cable Vision Inc";
  static const String bankName = "BPI";
  static const String bankAccountName = "CMD UnliFiberMax";
  static const String bankAccountNo = "1234 5678 90";

  @override
  void initState() {
    super.initState();
    paymentService = PaymentService(api: widget.auth.api);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
      submitError = null;
      receiptError = null;
    });

    try {
      final meJson = await widget.auth.me();
      final meParsed = SubscriberMe.fromJson(meJson);

      final res = await widget.auth.api.getJson(
        "/api/v1/billings?status=open",
        auth: true,
      );

      final raw = (res["billings"] ?? res["data"] ?? res) as dynamic;

      final List<Billing> list = _asListMap(
        raw,
      ).map((m) => Billing.fromJson(m)).toList(growable: false);

      setState(() {
        me = meParsed;
        openBillings = list;

        if (billingId == null && openBillings.isNotEmpty) {
          billingId = openBillings.first.id;
        }
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> _asListMap(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Billing? get selectedBilling {
    final id = billingId;
    if (id == null) return null;
    try {
      return openBillings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  bool get receiptRequired =>
      paymentMethod == "GCASH" || paymentMethod == "BANK_TRANSFER";

  bool get submitDisabled =>
      submitting ||
      billingId == null ||
      (receiptRequired && receiptFile == null);

  Future<void> _pickReceipt() async {
    setState(() {
      receiptError = null;
      submitError = null;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["jpg", "jpeg", "png", "pdf"],
      withData: false,
    );

    if (result == null) return;
    final path = result.files.single.path;
    if (path == null || path.isEmpty) return;

    setState(() => receiptFile = File(path));
  }

  void _removeReceipt() => setState(() => receiptFile = null);

  Future<void> _submit() async {
    final user = me;
    if (user == null) return;

    setState(() {
      submitError = null;
      receiptError = null;
    });

    if (billingId == null) {
      setState(() => submitError = "Please select a billing period to pay.");
      return;
    }
    if (receiptRequired && receiptFile == null) {
      setState(
        () => receiptError =
            "Please upload your payment receipt before submitting.",
      );
      return;
    }

    final b = selectedBilling;
    final amount = (b?.amount ?? user.brate ?? 0);

    final periodLabel =
        (b != null && b.startDate.isNotEmpty && b.endDate.isNotEmpty)
        ? "${formatDate(b.startDate)} – ${formatDate(b.endDate)}"
        : "—";

    final reference = (user.serialNumber).toString();
    final fullName = (user.fullName).toString();

    setState(() {
      submitting = true;
      submitError = null;
    });

    try {
      await paymentService.createPayment(
        subscriberId: user.id, // ✅ non-nullable now
        billingId: billingId!, // ✅ validated above
        fullName: fullName,
        planName: user.plan ?? "-",
        packageName: user.packageName ?? "-",
        amount: amount,
        billingPeriod: periodLabel,
        paymentMethod: paymentMethod,
        payeeName: paymentMethod == "GCASH" ? gcashBillerName : null,
        gcashReference: paymentMethod == "GCASH" ? reference : null,
        bankName: paymentMethod == "BANK_TRANSFER" ? bankName : null,
        accountName: paymentMethod == "BANK_TRANSFER" ? bankAccountName : null,
        accountNo: paymentMethod == "BANK_TRANSFER" ? bankAccountNo : null,
        receiptFile: receiptFile,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment submitted for verification. Thank you!"),
        ),
      );

      setState(() => receiptFile = null);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(
        () => submitError = e is ApiException ? e.message : e.toString(),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = selectedBilling;
    final selectedAmount = (selected?.amount ?? me?.brate ?? 0);

    final selectedPeriodLabel =
        (selected != null &&
            selected.startDate.isNotEmpty &&
            selected.endDate.isNotEmpty)
        ? "${formatDate(selected.startDate)} – ${formatDate(selected.endDate)}"
        : "—";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Complete Your Payment",
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: loading
          ? const _CenterLoading()
          : (error != null)
          ? _ErrorState(message: error!, onRetry: _load)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const SizedBox(height: 2),

                PaymentFormCard(
                  fullName: me?.fullName ?? "Customer",
                  planName: "${me?.packageName ?? "-"}${me?.plan ?? ""}",
                  totalAmount: selectedAmount,
                  openBillings: openBillings,
                  billingId: billingId,
                  onBillingChange: (v) => setState(() => billingId = v),
                  paymentMethod: paymentMethod,
                  onPaymentMethodChange: (v) {
                    setState(() {
                      paymentMethod = v;
                      if (!receiptRequired) receiptError = null;
                    });
                  },
                ),

                const SizedBox(height: 14),

                PaymentInstructionsCard(
                  paymentMethod: paymentMethod,
                  amount: selectedAmount,
                  reference: me?.serialNumber ?? "-",
                  selectedPeriodLabel: selectedPeriodLabel,
                ),

                const SizedBox(height: 14),

                PaymentConfirmCard(
                  receiptRequired: receiptRequired,
                  receiptFile: receiptFile,
                  receiptError: receiptError,
                  onPickReceipt: _pickReceipt,
                  onRemoveReceipt: _removeReceipt,
                  submitError: submitError,
                  submitting: submitting,
                  submitDisabled: submitDisabled,
                  onSubmit: _submit,
                ),
              ],
            ),
    );
  }
}

class _CenterLoading extends StatelessWidget {
  const _CenterLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Loading...", style: TextStyle(color: Color(0xFF6B7280))),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(color: Color(0xFFEF4444))),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}
