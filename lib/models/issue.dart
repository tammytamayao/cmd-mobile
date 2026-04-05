class IssuePriority {
  static const String high = 'high';
  static const String medium = 'medium';
  static const String low = 'low';

  static const List<String> values = [high, medium, low];
}

class IssueType {
  static const String cable = 'cable';
  static const String wifi = 'wifi';
  static const String payment = 'payment';
  static const String billings = 'billings';
  static const String others = 'others';

  static const List<String> values = [
    cable,
    wifi,
    payment,
    billings,
    others,
  ];
}

String formatIssueOptionLabel(String value) {
  switch (value) {
    case 'wifi':
      return 'WiFi';
    case 'billings':
      return 'Billings';
    default:
      if (value.isEmpty) return value;
      return value[0].toUpperCase() + value.substring(1);
  }
}

class IssueModel {
  final int id;
  final String title;
  final String message;
  final String issueType;
  final String priority;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  const IssueModel({
    required this.id,
    required this.title,
    required this.message,
    required this.issueType,
    required this.priority,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      issueType: (json['issue_type'] ?? '').toString(),
      priority: (json['priority'] ?? '').toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class CreateIssuePayload {
  final String title;
  final String message;
  final String issueType;
  final String priority;

  const CreateIssuePayload({
    required this.title,
    required this.message,
    required this.issueType,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'issue_type': issueType,
      'priority': priority,
    };
  }
}