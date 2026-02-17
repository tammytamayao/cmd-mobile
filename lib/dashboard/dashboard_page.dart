import 'package:cmd_mobile/payment/payment_page.dart';
import 'package:flutter/material.dart';
import '../models/subscriber_me.dart';
import '../services/auth_service.dart';
import 'dashboard_cards.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.auth});
  final AuthService auth;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  SubscriberMe? me;
  bool loading = true;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      final data = await widget.auth.me();
      setState(() => me = SubscriberMe.fromJson(data));
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This padding matches your web main area vibe
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (loading) return const _LoadingCard();

    if (err != null) {
      return Column(
        children: [
          Text(err!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, child: const Text("Retry")),
        ],
      );
    }

    if (me == null) return const Text("No data");

    final u = me!;
    return Column(
      children: [
        AccountDetailsCard(
          fullName: u.fullName,
          serialNumber: u.serialNumber,
          zone: u.zone,
        ),
        const SizedBox(height: 16),
        AmountDueCard(
          amountDue: u.amountDue,
          dueOn: u.dueOn,
          billingStatus: u.latestBilling?.status,
          onMakePayment: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PaymentPage(auth: widget.auth)),
            );
          },
        ),
        const SizedBox(height: 16),
        CurrentPlanCard(
          packageName: (u.packageName ?? ""),
          plan: (u.plan ?? ""),
          packageSpeed: (u.packageSpeed ?? 0),
          monthlyRate: (u.brate ?? 0),
          installedOn: u.dateInstalled,
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text("Loading..."),
        ],
      ),
    );
  }
}
