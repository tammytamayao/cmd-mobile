import 'dart:io';

import 'package:cmd_mobile/models/billing.dart';
import 'package:cmd_mobile/models/checkout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/env.dart';
import '../dashboard/formatters.dart';
import '../models/subscriber_me.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/checkout_service.dart';
import '../services/payment_service.dart';

import 'components/payment_form_card.dart';
import 'components/payment_instructions_card.dart';
import 'components/payment_confirm_card.dart';
import 'components/payment_mode_toggle.dart';
import 'components/online_method_selector.dart';
import 'components/payment_status_card.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.auth});
  final AuthService auth;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with WidgetsBindingObserver {
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
  late final CheckoutService checkoutService;

  // Payment mode: "manual" (receipt upload) or "online" (gateway)
  String paymentMode = "online";

  // Online payment state
  OnlinePaymentMethod onlineMethod = OnlinePaymentMethod.gcash;
  bool creatingCheckout = false;
  String? checkoutError;
  CheckoutResponse? checkout;

  // Verification state
  bool verifying = false;
  CheckoutVerifyResponse? verifyResult;
  int _pollCount = 0;
  static const _maxPolls = 5;
  static const _pollIntervalMs = 3000;

  // Same constants as web
  static const String gcashBillerName = "CMD Cable Vision Inc";
  static const String bankName = "BPI";
  static const String bankAccountName = "CMD UnliFiberMax";
  static const String bankAccountNo = "1234 5678 90";

  @override
  void initState() {
    super.initState();
    paymentService = PaymentService(api: widget.auth.api);
    checkoutService = CheckoutService(api: widget.auth.api);
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When user returns to app after completing payment in browser/GCash app,
    // automatically start verification
    if (state == AppLifecycleState.resumed &&
        checkout != null &&
        !verifying &&
        verifyResult == null) {
      _startVerification();
    }
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

  /// Create checkout session and open payment gateway in browser
  Future<void> _createAndOpenCheckout() async {
    if (billingId == null) {
      setState(() => checkoutError = "Please select a billing period to pay.");
      return;
    }

    setState(() {
      creatingCheckout = true;
      checkoutError = null;
    });

    try {
      final result = await checkoutService.createCheckout(
        billingId: billingId!,
        paymentMethod: onlineMethod,
        successUrl: "${Env.webBaseUrl}/payment/success",
        cancelUrl: "${Env.webBaseUrl}/payment",
      );

      setState(() => checkout = result);

      // Open checkout URL in external browser
      final uri = Uri.parse(result.checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("Could not open payment page");
      }
    } on ApiException catch (e) {
      setState(() => checkoutError = e.message);
    } catch (e) {
      setState(() => checkoutError = e.toString());
    } finally {
      if (mounted) setState(() => creatingCheckout = false);
    }
  }

  /// Start polling verification endpoint
  Future<void> _startVerification() async {
    if (checkout == null) return;

    setState(() {
      verifying = true;
      _pollCount = 0;
      verifyResult = null;
    });

    await _pollVerification();
  }

  /// Poll verification endpoint with retry logic
  Future<void> _pollVerification() async {
    while (_pollCount < _maxPolls && mounted) {
      try {
        final result = await checkoutService.verifyCheckout(checkout!.checkoutId);

        if (!mounted) return;

        if (result.status == CheckoutStatus.completed ||
            result.status == CheckoutStatus.failed) {
          setState(() {
            verifyResult = result;
            verifying = false;
          });
          return;
        }

        // Still processing, continue polling
        _pollCount++;
        if (_pollCount < _maxPolls) {
          await Future.delayed(
            const Duration(milliseconds: _pollIntervalMs),
          );
        }
      } catch (e) {
        // Network error, continue polling
        _pollCount++;
        if (_pollCount < _maxPolls) {
          await Future.delayed(
            const Duration(milliseconds: _pollIntervalMs),
          );
        }
      }
    }

    // Max polls reached, show processing state
    if (mounted) {
      setState(() {
        verifying = false;
        verifyResult = CheckoutVerifyResponse(
          paymentId: checkout!.paymentId,
          status: CheckoutStatus.processing,
          gatewayStatus: "pending",
          provider: checkout!.provider,
        );
      });
    }
  }

  /// Reset checkout state to allow retrying
  void _resetCheckout() {
    setState(() {
      checkout = null;
      verifyResult = null;
      checkoutError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If we're in verification flow, show status view
    if (checkout != null && (verifying || verifyResult != null)) {
      return _buildStatusView();
    }

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

                // Mode toggle: Manual vs Online
                PaymentModeToggle(
                  mode: paymentMode,
                  onModeChange: (v) => setState(() => paymentMode = v),
                ),

                const SizedBox(height: 14),

                // Show different content based on mode
                if (paymentMode == "manual") ...[
                  // Manual payment flow (receipt upload)
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
                ] else ...[
                  // Online payment flow (gateway checkout)
                  _buildOnlinePaymentForm(selectedAmount),
                ],
              ],
            ),
    );
  }

  /// Build the online payment form
  Widget _buildOnlinePaymentForm(num amount) {
    return Column(
      children: [
        // Subscriber info card (reuse styling)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Full Name",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          me?.fullName ?? "Customer",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Plan",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${me?.packageName ?? "-"}${me?.plan ?? ""}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 12),
              const Text(
                "Billing Period",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 6),
              _buildBillingDropdown(),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Payment method selector
        OnlineMethodSelector(
          selectedMethod: onlineMethod,
          onMethodChange: (v) => setState(() => onlineMethod = v),
        ),

        const SizedBox(height: 14),

        // Amount and Pay Now button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      formatCurrency(amount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),

              if (checkoutError != null) ...[
                const SizedBox(height: 12),
                Text(
                  checkoutError!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: (creatingCheckout || billingId == null)
                      ? null
                      : _createAndOpenCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF93C5FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    creatingCheckout ? "Redirecting..." : "Pay Now",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build billing period dropdown for online payment
  Widget _buildBillingDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: billingId,
          isExpanded: true,
          hint: const Text("Select billing period"),
          items: openBillings.map((b) {
            final label = (b.startDate.isNotEmpty && b.endDate.isNotEmpty)
                ? "${formatDate(b.startDate)} – ${formatDate(b.endDate)}"
                : "Billing #${b.id}";
            return DropdownMenuItem(
              value: b.id,
              child: Text(label),
            );
          }).toList(),
          onChanged: (v) => setState(() => billingId = v),
        ),
      ),
    );
  }

  /// Build the verification status view
  Widget _buildStatusView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Payment Status",
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: PaymentStatusCard(
            status: verifyResult?.status,
            verifying: verifying,
            onRetry: _resetCheckout,
            onDone: () => Navigator.of(context).pop(),
          ),
        ),
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
