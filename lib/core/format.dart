import 'package:intl/intl.dart';

/// Formats an amount as PKR currency, e.g. `PKR 12,345.67`.
String money(num v, {bool withSymbol = true, bool signed = false}) {
  final NumberFormat f = NumberFormat('#,##0.00');
  final String s = f.format(v.abs());
  final String pre = signed ? (v >= 0 ? '+' : '-') : (v < 0 ? '-' : '');
  return withSymbol ? 'PKR $pre$s' : '$pre$s';
}

/// Masks an account/IBAN number, e.g. `•••• 4521`.
String maskAccount(String number) {
  if (number.length <= 4) return number;
  return '•••• ${number.substring(number.length - 4)}';
}

String fullDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);
String time12(DateTime d) => DateFormat('hh:mm a').format(d);
String dateTime(DateTime d) => '${DateFormat('dd MMM yyyy, hh:mm a').format(d)}';

/// Friendly day label: Today / Yesterday / dd MMM yyyy.
String dayLabel(DateTime d) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime that = DateTime(d.year, d.month, d.day);
  final int diff = today.difference(that).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat('dd MMM yyyy').format(d);
}

String greeting() {
  final int h = DateTime.now().hour;
  if (h < 12) return 'Good Morning';
  if (h < 17) return 'Good Afternoon';
  return 'Good Evening';
}
