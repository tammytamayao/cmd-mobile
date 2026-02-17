class Billing {
  final int id;
  final String status;
  final double amount;
  final String startDate;
  final String endDate;
  final String dueDate;

  Billing({
    required this.id,
    required this.status,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
  });

  factory Billing.fromJson(Map<String, dynamic> j) {
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

    return Billing(
      id: toInt(j["id"]),
      status: (j["status"] ?? "").toString(),
      amount: toDouble(j["amount"]),
      startDate: (j["start_date"] ?? "").toString(),
      endDate: (j["end_date"] ?? "").toString(),
      dueDate: (j["due_date"] ?? "").toString(),
    );
  }
}
