import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/env.dart';
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

  /// Create a payment with optional receipt upload (multipart/form-data).
  ///
  /// Mirrors the web FormData keys:
  /// subscriber_id, billing_id, full_name, plan_name, package_name,
  /// amount, billing_period, payment_method, (optional) payee_name, gcash_reference,
  /// (optional) bank_name, account_name, account_no, (optional) receipt
  Future<void> createPayment({
    required int subscriberId,
    required int billingId,
    required String fullName,
    required String planName,
    required String packageName,
    required num amount,
    required String billingPeriod,
    required String paymentMethod, // "GCASH" | "CASH" | "BANK_TRANSFER"
    String? payeeName,
    String? gcashReference,
    String? bankName,
    String? accountName,
    String? accountNo,
    File? receiptFile,
  }) async {
    final token = await api.tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      throw ApiException(401, "Missing auth token.");
    }

    final uri = Uri.parse("${Env.apiBaseUrl}/api/v1/payments");
    final req = http.MultipartRequest("POST", uri);

    req.headers["Authorization"] = "Bearer $token";
    req.headers["Accept"] = "application/json";

    // Required fields
    req.fields["subscriber_id"] = "$subscriberId";
    req.fields["billing_id"] = "$billingId";
    req.fields["full_name"] = fullName;
    req.fields["plan_name"] = planName;
    req.fields["package_name"] = packageName;
    req.fields["amount"] = "$amount";
    req.fields["billing_period"] = billingPeriod;
    req.fields["payment_method"] = paymentMethod;

    // Optional method-specific fields
    if (paymentMethod == "GCASH") {
      if (payeeName != null && payeeName.trim().isNotEmpty) {
        req.fields["payee_name"] = payeeName.trim();
      }
      if (gcashReference != null && gcashReference.trim().isNotEmpty) {
        req.fields["gcash_reference"] = gcashReference.trim();
      }
    }

    if (paymentMethod == "BANK_TRANSFER") {
      if (bankName != null && bankName.trim().isNotEmpty) {
        req.fields["bank_name"] = bankName.trim();
      }
      if (accountName != null && accountName.trim().isNotEmpty) {
        req.fields["account_name"] = accountName.trim();
      }
      if (accountNo != null && accountNo.trim().isNotEmpty) {
        req.fields["account_no"] = accountNo.trim();
      }
    }

    // Optional receipt upload
    if (receiptFile != null) {
      final filePart = await http.MultipartFile.fromPath(
        "receipt",
        receiptFile.path,
      );
      req.files.add(filePart);
    }

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();

    Map<String, dynamic> data = {};
    if (body.isNotEmpty) {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) data = decoded;
    }

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) return;

    final msg = (data["error"] ?? data["message"] ?? "Request failed")
        .toString();
    throw ApiException(streamed.statusCode, msg);
  }
}
