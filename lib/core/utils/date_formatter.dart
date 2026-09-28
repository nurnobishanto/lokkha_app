// lib/app/utils/date_formatter.dart

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._(); // Private constructor to prevent instance creation

  /// Format a DateTime to 'dd/MM/yyyy'
  static String formatToDMY(DateTime? date) {
    if (date == null) return ''; // or 'N/A'
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format a DateTime? to 'd MMM yyyy' e.g. 20 Sept 2025
  static String formatToReadable(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format a DateTime to 'yyyy-MM-dd'
  static String formatToYMD(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format a DateTime to 'dd-MM-yyyy HH:mm'
  static String formatToDateTime(DateTime date) {
    return DateFormat('dd-MM-yyyy HH:mm').format(date);
  }

  /// Format a DateTime to 'hh:mm a' (12-hour format with AM/PM)
  static String formatToTime12Hour(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  /// Format a DateTime to 'HH:mm' (24-hour format)
  static String formatToTime24Hour(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Parse a date string to DateTime
  static DateTime? parseDate(String dateString,
      {String pattern = 'yyyy-MM-dd'}) {
    try {
      return DateFormat(pattern).parse(dateString);
    } catch (e) {
      return null;
    }
  }

// Custom date and time format: 22, Jan, 2024 02:30 PM
  static String formatJobDeadline(DateTime? dateTime) {
    dateTime ??= DateTime.now();

    final String time = DateFormat("hh:mm a").format(dateTime);

    if (time == "12:00 AM") {
      return DateFormat("dd, MMM, yyyy").format(dateTime);
    } else {
      return DateFormat("dd, MMM, yyyy hh:mm a").format(dateTime);
    }
  }

  /// Format a date to Bengali locale
  static String formatToBengaliDate(DateTime date) {
    return DateFormat.yMMMMd('bn').format(date);
  }

  /// Format a date to Bengali time
  static String formatToBengaliTime(DateTime date) {
    return DateFormat.jm('bn').format(date);
  }

  /// Get current date formatted as 'dd/MM/yyyy'
  static String currentDateDMY() {
    return formatToDMY(DateTime.now());
  }

  /// Get current time formatted as 'hh:mm a'
  static String currentTime12Hour() {
    return formatToTime12Hour(DateTime.now());
  }

  /// Convert UTC DateTime to Local Time
  static DateTime convertUtcToLocal(DateTime utcDate) {
    return utcDate.toLocal();
  }

  /// Convert Local DateTime to UTC Time
  static DateTime convertLocalToUtc(DateTime localDate) {
    return localDate.toUtc();
  }
}
