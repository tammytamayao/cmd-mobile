import 'package:cmd_mobile/services/billing_history_service.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'components/segmented.dart';
import 'components/year_dropdown.dart';
import 'components/billings_tab.dart';
import 'components/payments_tab.dart';
import 'components/payment_details_modal.dart';

class BillingHistoryPage extends StatefulWidget {
  const BillingHistoryPage({super.key, required this.auth});
  final AuthService auth;

  @override
  State<BillingHistoryPage> createState() => _BillingHistoryPageState();
}

class _BillingHistoryPageState extends State<BillingHistoryPage> {
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
    year = DateTime.now().year;
    yearOptions = List.generate(6, (i) => DateTime.now().year - i);

    final ApiClient api = widget.auth.api;
    service = BillingHistoryService(api: api);

    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await service.fetch(year: year);
      setState(() => data = res);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _makePayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("TODO: Navigate to payment page")),
    );
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
              color: Colors.black.withOpacity(0.04),
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
                onChange: (v) {
                  setState(() => tab = v);
                },
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
                    // ✅ updated: open modal by paymentId + auth (fetch signed receipt_url)
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
