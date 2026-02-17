import 'package:intl/intl.dart';

String formatCurrency(num v) {
  final f = NumberFormat.currency(
    locale: "en_PH",
    symbol: "₱",
    decimalDigits: 2,
  );
  return f.format(v);
}

String formatDate(String? iso) {
  if (iso == null || iso.trim().isEmpty) return "N/A";
  try {
    final d = DateTime.parse(iso).toLocal();
    return DateFormat("MMM d, yyyy").format(d);
  } catch (_) {
    return "N/A";
  }
}
