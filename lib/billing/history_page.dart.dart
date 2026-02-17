import 'package:cmd_mobile/services/billing_history_service.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'components/segmented.dart';
import 'components/year_dropdown.dart';
import 'components/billings_tab.dart';
import 'components/payments_tab.dart';
import 'components/payment_details_modal.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.auth});
  final AuthService auth;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String tab = "bills"; // "bills" | "payments"
  late int year;

  bool loading = true;
  String? error;

  BillingHistoryResult? data;

  List<int> yearOptions = [];

  late final BillingHistoryService service;

  @override
  void initState() {
    super.initState();

    final nowY = DateTime.now().year;
    year = nowY;
    yearOptions = [nowY];

    final ApiClient api = widget.auth.api;
    service = BillingHistoryService(api: api);

    _init();
  }

  Future<void> _init() async {
    await _loadYears();
    await _load();
  }

  Future<void> _loadYears() async {
    final nowY = DateTime.now().year;

    try {
      // Requires: service.fetchBillingsYearRange() and service.fetchPaymentsYearRange()
      final results = await Future.wait([
        service.fetchBillingsYearRange(),
        service.fetchPaymentsYearRange(),
      ]);

      final bill = results[0];
      final pay = results[1];

      final minY = _minInt(bill.minYear ?? nowY, pay.minYear ?? nowY);
      final maxY = _maxInt(bill.maxYear ?? nowY, pay.maxYear ?? nowY);

      final years = (maxY >= minY)
          ? List.generate(maxY - minY + 1, (i) => maxY - i)
          : [nowY];

      if (!mounted) return;

      setState(() {
        yearOptions = years;
        // clamp selected year into available range
        if (year < minY || year > maxY) year = maxY;
      });
    } catch (_) {
      // fallback: current year only
      if (!mounted) return;
      setState(() {
        yearOptions = [nowY];
        year = nowY;
      });
    }
  }

  int _minInt(int a, int b) => a < b ? a : b;
  int _maxInt(int a, int b) => a > b ? a : b;

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await service.fetch(year: year);
      if (!mounted) return;
      setState(() => data = res);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget container(Widget child) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Segmented(
                options: const [
                  (label: "Billings", value: "bills"),
                  (label: "Payments", value: "payments"),
                ],
                value: tab,
                onChange: (v) => setState(() => tab = v),
              ),
              const Spacer(),
              YearDropdown(
                value: year,
                options: yearOptions,
                onChange: (y) {
                  setState(() => year = y);
                  _load();
                },
              ),
            ],
          ),
          container(
            loading
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(
                      child: Text(
                        "Loading...",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  )
                : (error != null)
                ? Padding(
                    padding: const EdgeInsets.all(18),
                    child: Center(
                      child: Text(
                        error!,
                        style: const TextStyle(color: Color(0xFFEF4444)),
                      ),
                    ),
                  )
                : (tab == "bills")
                ? BillingsTab(bills: data?.billings ?? [])
                : PaymentsTab(
                    payments: data?.payments ?? [],
                    // ✅ open modal by paymentId + auth (fetch signed receipt_url)
                    onViewPayment: (paymentId) => PaymentDetailsModal.show(
                      context,
                      paymentId: paymentId,
                      auth: widget.auth,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
