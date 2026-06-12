import 'package:flutter/material.dart';

/// BuildContext extensions for quick access to theme data
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isCompact => screenWidth < 900;
  bool get isMedium => screenWidth >= 900 && screenWidth < 1280;
  bool get isLarge => screenWidth >= 1280;
}

/// String extensions
extension StringX on String {
  /// Capitalize first letter
  String get capitalized =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  /// Convert camelCase or snake_case to Title Case
  String get toTitleCase {
    return replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    )
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.capitalized)
        .join(' ');
  }

  /// Mask phone number: "9876543210" → "98****3210"
  String get masked {
    if (length <= 4) return this;
    final visible = 4;
    return '${substring(0, 2)}${'*' * (length - visible)}${substring(length - 2)}';
  }
}

/// DateTime extensions
extension DateTimeX on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is this month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if date is within last N days
  bool isWithinDays(int days) {
    return DateTime.now().difference(this).inDays <= days;
  }

  /// Start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}

/// Num extensions
extension NumX on num {
  /// Clamp between 0 and 1
  double get clamp01 => clamp(0.0, 1.0).toDouble();
}
