import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Legacy standalone helper for launching phone dialer
Future<void> makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}

/// Smart Bangladeshi Phone Number Normalizer & Validator.
///
/// Handles all accepted client formats:
/// - Standard 11-digit local: 01712345678
/// - Country code without plus: 8801712345678
/// - Country code with plus: +8801712345678
/// - Without leading zero: 1712345678
/// - Formatted with dash/space: 01712-345678, 01712 345678
/// - Bengali numerals: ০১৭১২৩৪৫৬৭৮, +৮৮০১৭১২৩৪৫৬৭৮
class PhoneUtils {
  PhoneUtils._();

  static const Map<String, String> _bengaliToEnglishDigits = {
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };

  /// Converts Bengali numerals (০-৯) to ASCII digits (0-9).
  static String convertBengaliDigits(String input) {
    var result = input;
    _bengaliToEnglishDigits.forEach((bn, en) {
      result = result.replaceAll(bn, en);
    });
    return result;
  }

  /// Strips formatting characters (spaces, dashes, parentheses, dots).
  static String sanitize(String input) {
    final converted = convertBengaliDigits(input.trim());
    return converted.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
  }

  /// Canonicalizes to 880 prefix E.164-style without plus: `8801XXXXXXXXX` (13 digits).
  ///
  /// Examples:
  /// - `01712345678` -> `8801712345678`
  /// - `+8801712345678` -> `8801712345678`
  /// - `8801712345678` -> `8801712345678`
  /// - `1712345678` -> `8801712345678`
  /// - `01712-345678` -> `8801712345678`
  /// - `০১৭১২৩৪৫৬৭৮` -> `8801712345678`
  static String toCanonical880(String raw) {
    var cleaned = sanitize(raw);
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    if (cleaned.startsWith('880')) {
      return cleaned;
    }
    if (cleaned.startsWith('01')) {
      return '88$cleaned';
    }
    if (cleaned.startsWith('1') && cleaned.length == 10) {
      return '880$cleaned';
    }
    return cleaned;
  }

  /// Converts any accepted format to local 11-digit representation: `01XXXXXXXXX`.
  ///
  /// Examples:
  /// - `8801712345678` -> `01712345678`
  /// - `+8801712345678` -> `01712345678`
  /// - `1712345678` -> `01712345678`
  /// - `01712-345678` -> `01712345678`
  /// - `০১৭১২৩৪৫৬৭৮` -> `01712345678`
  static String toLocal11Digit(String raw) {
    final canonical = toCanonical880(raw);
    if (canonical.startsWith('880') && canonical.length == 13) {
      return canonical.substring(2); // '01XXXXXXXXX'
    }
    if (canonical.startsWith('01') && canonical.length == 11) {
      return canonical;
    }
    return canonical;
  }

  /// Validates whether the number represents an active Bangladeshi mobile operator.
  /// Valid prefixes: 013, 014, 015, 016, 017, 018, 019.
  static bool isValidBdMobile(String raw) {
    final local = toLocal11Digit(raw);
    if (local.length != 11) return false;
    final regex = RegExp(r'^01[3-9]\d{8}$');
    return regex.hasMatch(local);
  }
}

/// A smart input formatter for Flutter TextFields that:
/// 1. Converts Bengali digits to English digits in real time.
/// 2. Strips dashes and spaces.
/// 3. Automatically removes '+88' or '88' if user pastes a country code.
/// 4. Limits the local input to 11 digits.
class SmartPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 1. Convert Bengali to English digits & sanitize
    var text = PhoneUtils.convertBengaliDigits(newValue.text);
    text = text.replaceAll(RegExp(r'[^\d+]'), '');

    // 2. If user pasted with +880 or 880, strip to local 01...
    if (text.startsWith('+880')) {
      text = '0${text.substring(4)}';
    } else if (text.startsWith('880')) {
      text = '0${text.substring(3)}';
    } else if (text.startsWith('+88')) {
      text = text.substring(3);
    } else if (text.startsWith('+')) {
      text = text.substring(1);
    }

    // 3. Keep only digits
    text = text.replaceAll(RegExp(r'[^\d]'), '');

    // 4. Limit to 11 digits
    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
