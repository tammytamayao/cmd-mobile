import '../models/checkout.dart';
import 'api_client.dart';

/// Service for online payment checkout operations
class CheckoutService {
  final ApiClient api;

  CheckoutService({required this.api});

  /// Create a checkout session for online payment
  ///
  /// Returns a [CheckoutResponse] containing the checkout URL to redirect the user to.
  Future<CheckoutResponse> createCheckout({
    required int billingId,
    required OnlinePaymentMethod paymentMethod,
    required String successUrl,
    required String cancelUrl,
  }) async {
    final res = await api.postJson(
      "/api/v1/checkouts",
      body: {
        "billing_id": billingId,
        "payment_method": paymentMethod.value,
        "success_url": successUrl,
        "cancel_url": cancelUrl,
      },
      auth: true,
    );
    return CheckoutResponse.fromJson(res);
  }

  /// Verify the status of a checkout session
  ///
  /// Call this after the user returns from the payment gateway to check
  /// if the payment was successful.
  Future<CheckoutVerifyResponse> verifyCheckout(String checkoutId) async {
    final res = await api.getJson(
      "/api/v1/checkouts/$checkoutId/verify",
      auth: true,
    );
    return CheckoutVerifyResponse.fromJson(res);
  }
}
