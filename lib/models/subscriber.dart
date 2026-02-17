class Subscriber {
  final int id;
  final String firstName;
  final String lastName;
  final String serialNumber;
  final String? plan;
  final num? brate;
  final bool requiresPasswordChange;

  Subscriber({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.serialNumber,
    this.plan,
    this.brate,
    required this.requiresPasswordChange,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) {
    return Subscriber(
      id: json["id"] as int,
      firstName: (json["first_name"] ?? "").toString(),
      lastName: (json["last_name"] ?? "").toString(),
      serialNumber: (json["serial_number"] ?? "").toString(),
      plan: json["plan"]?.toString(),
      brate: json["brate"] is num
          ? json["brate"] as num
          : num.tryParse("${json["brate"]}"),
      requiresPasswordChange:
          (json["requires_password_change"] ?? false) == true,
    );
  }
}
