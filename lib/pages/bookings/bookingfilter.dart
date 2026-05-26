// lib/utils/booking_filter_helper.dart
import 'package:flutter/material.dart';

class BookingFilterResult {
  final DateTime startDate;
  final DateTime endDate;

  BookingFilterResult({required this.startDate, required this.endDate});
}

class BookingFilterHelper {
 
  static BookingFilterResult calculateRange(String filterType) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    DateTime startDate;
    DateTime endDate;

    switch (filterType) {
      case 'Tomorrow':
        startDate = todayStart.add(const Duration(days: 1));
        endDate = todayStart.add(const Duration(days: 2)).subtract(const Duration(microseconds: 1));
        break;

      case 'This Week':
        int currentWeekday = now.weekday;
        startDate = todayStart.subtract(Duration(days: currentWeekday - 1));
        endDate = startDate.add(const Duration(days: 7)).subtract(const Duration(microseconds: 1));
        break;

      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(microseconds: 1));
        break;

      case 'Quarter':
        int currentQuarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        startDate = DateTime(now.year, currentQuarterMonth, 1);
        endDate = DateTime(now.year, currentQuarterMonth + 3, 1).subtract(const Duration(microseconds: 1));
        break;

      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1).subtract(const Duration(microseconds: 1));
        break;

      case 'Today':
      default:
        startDate = todayStart;
        endDate = todayStart.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
        break;
    }

    return BookingFilterResult(startDate: startDate, endDate: endDate);
  }

  /// Handles showing the material date range picker UI cleanly
  static Future<BookingFilterResult?> showCustomRangePicker({
    required BuildContext context,
    DateTime? initialStart,
    DateTime? initialEnd,
  }) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: initialStart != null && initialEnd != null
          ? DateTimeRange(start: initialStart, end: initialEnd)
          : null,
      builder: (context, child) {
        // Theme customization to match your dark/green dashboard theme if desired
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00C853), // Green accents
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      return BookingFilterResult(
        startDate: pickedRange.start,
        endDate: DateTime(
          pickedRange.end.year,
          pickedRange.end.month,
          pickedRange.end.day,
          23,
          59,
          59,
          999,
        ),
      );
    }
    return null;
  }
}