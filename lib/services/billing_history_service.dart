import '../../services/api_client.dart';
import '../models/billing.dart';
import '../models/payment.dart';

class BillingHistoryResult {
  final List<Billing> billings;
  final List<Payment> payments;

  BillingHistoryResult({required this.billings, required this.payments});
}

class BillingHistoryService {
  final ApiClient api;
  BillingHistoryService({required this.api});

  Future<BillingHistoryResult> fetch({required int year}) async {
    // If your backend supports ?year=, this will work.
    // If not, it still works; you can filter client-side later.
    final b = await api.getJson("/api/v1/billings?year=$year", auth: true);
    final p = await api.getJson("/api/v1/payments?year=$year", auth: true);

    final billingsRaw = (b["billings"] ?? b["data"] ?? b) as dynamic;
    final paymentsRaw = (p["payments"] ?? p["data"] ?? p) as dynamic;

    final billings = _asListMap(billingsRaw).map(Billing.fromJson).toList();
    final payments = _asListMap(paymentsRaw).map(Payment.fromJson).toList();

    return BillingHistoryResult(billings: billings, payments: payments);
  }

  List<Map<String, dynamic>> _asListMap(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    if (raw is Map<String, dynamic>) {
      // fallback if API returns { billings: [...] } already handled above
      return [];
    }
    return [];
  }
}
