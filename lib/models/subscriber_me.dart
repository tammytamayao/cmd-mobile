class SubscriberMe {
  final int id;
  final String zone;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? phoneNumber;
  final String? dateInstalled;

  final String? plan;
  final num? brate;
  final String? packageName;
  final int? packageSpeed;

  final String serialNumber;

  final double amountDue;
  final String? dueOn;

  final LatestBilling? latestBilling;

  SubscriberMe({
    required this.id,
    required this.zone,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.phoneNumber,
    required this.dateInstalled,
    required this.plan,
    required this.brate,
    required this.packageName,
    required this.packageSpeed,
    required this.serialNumber,
    required this.amountDue,
    required this.dueOn,
    required this.latestBilling,
  });

  factory SubscriberMe.fromJson(Map<String, dynamic> j) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return SubscriberMe(
      id: (j["id"] ?? 0) as int,
      zone: (j["zone"] ?? "").toString(),
      firstName: (j["first_name"] ?? "").toString(),
      lastName: (j["last_name"] ?? "").toString(),
      fullName: (j["full_name"] ?? "").toString(),
      phoneNumber: j["phone_number"]?.toString(),
      dateInstalled: j["date_installed"]?.toString(),
      plan: j["plan"]?.toString(),
      brate: j["brate"] is num
          ? (j["brate"] as num)
          : num.tryParse("${j["brate"]}"),
      packageName: j["package"]?.toString(),
      packageSpeed: toInt(j["package_speed"]),
      serialNumber: (j["serial_number"] ?? "").toString(),
      amountDue: toDouble(j["amount_due"]),
      dueOn: j["due_on"]?.toString(),
      latestBilling: j["latest_billing"] is Map<String, dynamic>
          ? LatestBilling.fromJson(j["latest_billing"] as Map<String, dynamic>)
          : null,
    );
  }
}

class LatestBilling {
  final int id;
  final String status;

  LatestBilling({required this.id, required this.status});

  factory LatestBilling.fromJson(Map<String, dynamic> j) {
    return LatestBilling(
      id: (j["id"] ?? 0) as int,
      status: (j["status"] ?? "").toString(),
    );
  }
}
