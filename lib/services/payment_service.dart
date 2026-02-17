import '../models/payment.dart';
import 'api_client.dart';

class PaymentService {
  final ApiClient api;
  PaymentService({required this.api});

  Future<Payment> fetchById(int id) async {
    final res = await api.getJson("/api/v1/payments/$id", auth: true);

    final data = res["data"];
    if (data is! Map<String, dynamic>) {
      throw ApiException(500, "Invalid payment response.");
    }
    return Payment.fromJson(data);
  }
}
