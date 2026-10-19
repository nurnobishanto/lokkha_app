import 'package:lokkha/core/utils/phone_utils.dart';

/// Extension to convert numbers and text between English and Bengali numerals.
extension BengaliNumberExtension on Object? {
  /// Converts English ASCII digits (0-9) to Bengali numerals (০-৯).
  ///
  /// Examples:
  /// - `100.toBnDigits()` -> `"১০০"`
  /// - `"Score: 85%".toBnDigits()` -> `"Score: ৮৫%"`
  String toBnDigits() {
    if (this == null) return '';
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var result = toString();
    for (int i = 0; i < en.length; i++) {
      result = result.replaceAll(en[i], bn[i]);
    }
    return result;
  }

  /// Converts Bengali digits (০-৯) to English digits (0-9).
  String toEnDigits() {
    if (this == null) return '';
    return PhoneUtils.convertBengaliDigits(toString());
  }
}

/// Helpful utility extensions on String.
extension StringExtension on String? {
  /// Checks whether the string is null, empty or only whitespace.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Checks whether the string has valid content.
  bool get isNotNullNorBlank => !isNullOrBlank;

  /// Validates Bangladeshi mobile phone number.
  bool get isValidBdMobile => this != null && PhoneUtils.isValidBdMobile(this!);

  /// Capitalizes first letter of the string.
  String get capitalizeFirst {
    if (this == null || this!.isEmpty) return '';
    return this![0].toUpperCase() + this!.substring(1);
  }

  /// Strips HTML tags from strings.
  String get stripHtml {
    if (this == null) return '';
    return this!.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
