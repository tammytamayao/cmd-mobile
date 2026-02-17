class PaymentReceiptMeta {
  final String? filename;
  final int? size;
  final String? mimeType;
  final String? uploadedAt;

  PaymentReceiptMeta({
    this.filename,
    this.size,
    this.mimeType,
    this.uploadedAt,
  });

  factory PaymentReceiptMeta.fromJson(Map<String, dynamic> j) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return PaymentReceiptMeta(
      filename: j["filename"]?.toString(),
      size: toInt(j["size"]),
      mimeType: j["mime_type"]?.toString(),
      uploadedAt: j["uploaded_at"]?.toString(),
    );
  }
}

class Payment {
  final int id;
  final String status;
  final double amount;
  final String paymentDate;
  final String? paymentMethod;
  final String? referenceNumber;

  final String? invoiceNumber;

  // returned by show endpoint (signed)
  final String? receiptUrl;

  // billing period
  final String? billingPeriodStart;
  final String? billingPeriodEnd;

  // ✅ receipt meta
  final PaymentReceiptMeta? receipt;

  Payment({
    required this.id,
    required this.status,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.referenceNumber,
    this.invoiceNumber,
    this.receiptUrl,
    this.billingPeriodStart,
    this.billingPeriodEnd,
    this.receipt,
  });

  factory Payment.fromJson(Map<String, dynamic> j) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    final receiptJson = j["receipt"];
    return Payment(
      id: toInt(j["id"]),
      status: (j["status"] ?? "").toString(),
      amount: toDouble(j["amount"]),
      paymentDate: (j["payment_date"] ?? "").toString(),
      paymentMethod: j["payment_method"]?.toString(),
      referenceNumber: j["reference_number"]?.toString(),
      invoiceNumber: j["invoice_number"]?.toString(),
      receiptUrl: j["receipt_url"]?.toString(),
      billingPeriodStart: j["billing_period_start"]?.toString(),
      billingPeriodEnd: j["billing_period_end"]?.toString(),
      receipt: receiptJson is Map<String, dynamic>
          ? PaymentReceiptMeta.fromJson(receiptJson)
          : null,
    );
  }
}
