import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/utils/phone_utils.dart';
import 'package:lokkha/features/auth/data/models/auth_response_model.dart';

void main() {
  group('Smart Phone Number Normalization (880) Tests', () {
    test('Canonicalizes standard 11-digit local number (01712345678)', () {
      expect(PhoneUtils.toCanonical880('01712345678'), '8801712345678');
      expect(PhoneUtils.toLocal11Digit('01712345678'), '01712345678');
      expect(PhoneUtils.isValidBdMobile('01712345678'), isTrue);
    });

    test('Canonicalizes number with country code without plus (8801712345678)', () {
      expect(PhoneUtils.toCanonical880('8801712345678'), '8801712345678');
      expect(PhoneUtils.toLocal11Digit('8801712345678'), '01712345678');
      expect(PhoneUtils.isValidBdMobile('8801712345678'), isTrue);
    });

    test('Canonicalizes number with plus prefix (+8801712345678)', () {
      expect(PhoneUtils.toCanonical880('+8801712345678'), '8801712345678');
      expect(PhoneUtils.toLocal11Digit('+8801712345678'), '01712345678');
      expect(PhoneUtils.isValidBdMobile('+8801712345678'), isTrue);
    });

    test('Canonicalizes number without leading zero (1712345678)', () {
      expect(PhoneUtils.toCanonical880('1712345678'), '8801712345678');
      expect(PhoneUtils.toLocal11Digit('1712345678'), '01712345678');
      expect(PhoneUtils.isValidBdMobile('1712345678'), isTrue);
    });

    test('Canonicalizes formatted number with dash (01712-345678)', () {
      expect(PhoneUtils.toCanonical880('01712-345678'), '8801712345678');
      expect(PhoneUtils.toLocal11Digit('01712-345678'), '01712345678');
      expect(PhoneUtils.isValidBdMobile('01712-345678'), isTrue);
    });

    test('Canonicalizes number with Bengali numerals (০১৭১২৩৪৫৬৭৮)', () {
      expect(PhoneUtils.toCanonical880('০১৭১২৩৪৫৬৭৮'), '8801712345678');
      expect(PhoneUtils.toLocal11Digit('০১৭১২৩৪৫৬৭৮'), '01712345678');
      expect(PhoneUtils.isValidBdMobile('০১৭১২৩৪৫৬৭৮'), isTrue);
    });

    test('Validates all valid BD operators (013, 014, 015, 016, 017, 018, 019)', () {
      final operators = ['013', '014', '015', '016', '017', '018', '019'];
      for (final prefix in operators) {
        final phone = '${prefix}12345678';
        expect(PhoneUtils.isValidBdMobile(phone), isTrue, reason: '$phone should be valid');
      }
    });

    test('Rejects invalid numbers (invalid operator, short length, non-BD)', () {
      expect(PhoneUtils.isValidBdMobile('01212345678'), isFalse); // invalid operator 012
      expect(PhoneUtils.isValidBdMobile('01012345678'), isFalse); // invalid operator 010
      expect(PhoneUtils.isValidBdMobile('01712345'), isFalse); // too short
      expect(PhoneUtils.isValidBdMobile(''), isFalse);
    });

    test('SmartPhoneInputFormatter converts Bengali digits and cleans input', () {
      final formatter = SmartPhoneInputFormatter();

      // Typing Bengali digits
      final result1 = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '০১৭১২৩৪৫৬৭৮'),
      );
      expect(result1.text, '01712345678');

      // Pasting +8801712345678
      final result2 = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '+8801712345678'),
      );
      expect(result2.text, '01712345678');

      // Pasting 01712-345678
      final result3 = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '01712-345678'),
      );
      expect(result3.text, '01712345678');
    });
  });

  group('Check Phone API Model & Endpoint Tests', () {
    test('Endpoints is configured for /api/v1/auth/check-phone', () {
      expect(Endpoints.checkPhone, '/api/v1/auth/check-phone');
    });

    test('AuthResponseModel correctly parses registered user response', () {
      final json = {
        "success": true,
        "message": "User found. Please enter password or request OTP to login.",
        "data": {
          "phone": "8801712345678",
          "is_registered": true,
          "auth_method": "password",
          "suggested_step": "login"
        }
      };

      final model = AuthResponseModel.fromJson(json);
      expect(model.status, isTrue);
      expect(model.isRegistered, isTrue);
      expect(model.authMethod, 'password');
      expect(model.suggestedStep, 'login');
      expect(model.canonicalPhone, '8801712345678');
    });

    test('AuthResponseModel correctly parses unregistered user response', () {
      final json = {
        "success": true,
        "message": "Phone not registered. Please verify with OTP to register.",
        "data": {
          "phone": "8801999999999",
          "is_registered": false,
          "auth_method": "otp",
          "suggested_step": "register"
        }
      };

      final model = AuthResponseModel.fromJson(json);
      expect(model.status, isTrue);
      expect(model.isRegistered, isFalse);
      expect(model.authMethod, 'otp');
      expect(model.suggestedStep, 'register');
      expect(model.canonicalPhone, '8801999999999');
    });
  });
}
