/// Online payment methods supported by payment gateways
enum OnlinePaymentMethod {
  gcash,
  maya,
  credit_card,
  grab_pay,
  bank_transfer;

  /// Value sent to API (matches backend expectations)
  String get value => name;

  /// Display label for UI
  String get label => switch (this) {
        gcash => "GCash",
        maya => "Maya",
        credit_card => "Credit Card",
        grab_pay => "GrabPay",
        bank_transfer => "Bank Transfer",
      };
}

/// Response from POST /api/v1/checkouts
class CheckoutResponse {
  final String checkoutUrl;
  final String checkoutId;
  final String provider;
  final int paymentId;

  CheckoutResponse({
    required this.checkoutUrl,
    required this.checkoutId,
    required this.provider,
    required this.paymentId,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    // Handle both wrapped { data: {...} } and unwrapped responses
    final data = json["data"] as Map<String, dynamic>? ?? json;
    return CheckoutResponse(
      checkoutUrl: (data["checkout_url"] ?? "").toString(),
      checkoutId: (data["checkout_id"] ?? "").toString(),
      provider: (data["provider"] ?? "").toString(),
      paymentId: _toInt(data["payment_id"]),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

/// Payment verification status
enum CheckoutStatus {
  completed,
  processing,
  failed,
  unknown;

  static CheckoutStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case "completed":
        return CheckoutStatus.completed;
      case "processing":
        return CheckoutStatus.processing;
      case "failed":
        return CheckoutStatus.failed;
      default:
        return CheckoutStatus.unknown;
    }
  }

  bool get isCompleted => this == CheckoutStatus.completed;
  bool get isFailed => this == CheckoutStatus.failed;
  bool get isProcessing =>
      this == CheckoutStatus.processing || this == CheckoutStatus.unknown;
}

/// Response from GET /api/v1/checkouts/{id}/verify
class CheckoutVerifyResponse {
  final int paymentId;
  final CheckoutStatus status;
  final String gatewayStatus;
  final String provider;

  CheckoutVerifyResponse({
    required this.paymentId,
    required this.status,
    required this.gatewayStatus,
    required this.provider,
  });

  factory CheckoutVerifyResponse.fromJson(Map<String, dynamic> json) {
    // Handle both wrapped { data: {...} } and unwrapped responses
    final data = json["data"] as Map<String, dynamic>? ?? json;
    return CheckoutVerifyResponse(
      paymentId: _toInt(data["payment_id"]),
      status: CheckoutStatus.fromString((data["status"] ?? "").toString()),
      gatewayStatus: (data["gateway_status"] ?? "").toString(),
      provider: (data["provider"] ?? "").toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
