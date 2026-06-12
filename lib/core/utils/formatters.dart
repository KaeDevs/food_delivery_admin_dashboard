import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// Currency: ₹1,23,456.78
  static String currency(double amount) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);

  /// Compact: ₹1.2L, ₹45K
  static String currencyCompact(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return currency(amount);
  }

  /// Percent: 94.3%
  static String percent(double value) =>
      '${(value * 100).toStringAsFixed(1)}%';

  /// Relative time: "2h ago", "just now"
  static String relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(dt);
  }

  /// Date: "12 Jun 2026"
  static String date(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);

  /// Short date: "12 Jun"
  static String dateShort(DateTime dt) => DateFormat('dd MMM').format(dt);

  /// Time: "14:32"
  static String time(DateTime dt) => DateFormat('HH:mm').format(dt);

  /// DateTime: "12 Jun 2026, 14:32"
  static String dateTime(DateTime dt) =>
      DateFormat('dd MMM yyyy, HH:mm').format(dt);

  /// Number with commas: 1,234,567
  static String number(int value) =>
      NumberFormat('#,##,###', 'en_IN').format(value);

  /// Ratio: "1.5x"
  static String ratio(double value) => '${value.toStringAsFixed(1)}x';
}
