import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/features/auth/auth.dart';

class _MockV1AuthRepository implements AuthRepository {
  String? lastForgotPhone;
  String? lastResetPhone;
  String? lastResetOtp;
  String? lastResetPassword;
  String? lastResetConfirmPassword;

  bool shouldSucceed = true;

  @override
  Future<AuthResponseModel> forgotPassword(String phone) async {
    lastForgotPhone = phone;
    if (shouldSucceed) {
      return AuthResponseModel(
        status: true,
        message: 'Password reset OTP sent successfully to your mobile number.',
        canonicalPhone: '88$phone',
        otp: '452821',
        expiresIn: 300,
      );
    }
    return AuthResponseModel(
      status: false,
      message: 'No account found with this phone number.',
    );
  }

  @override
  Future<AuthResponseModel> resetPassword({
    required String phone,
    required String otp,
    required String password,
    String? passwordConfirmation,
    String? deviceName,
    String? platform,
  }) async {
    lastResetPhone = phone;
    lastResetOtp = otp;
    lastResetPassword = password;
    lastResetConfirmPassword = passwordConfirmation;

    if (shouldSucceed) {
      return AuthResponseModel(
        status: true,
        message: 'Password reset successfully. You are now logged in with your new password.',
        token: 'test_fresh_jwt_token',
        profileCompleted: true,
      );
    }
    return AuthResponseModel(
      status: false,
      message: 'Invalid or expired OTP. Please request a new OTP.',
    );
  }

  @override
  Future<AuthResponseModel> checkPhone(String phone) async =>
      AuthResponseModel(status: true);

  @override
  Future<AuthResponseModel> sendOtp(String phone, {String type = 'Login'}) async =>
      AuthResponseModel(status: true, expiresIn: 300);

  @override
  Future<AuthResponseModel> verifyOtp({required String phone, required String otp}) async =>
      AuthResponseModel(status: true);

  @override
  Future<AuthResponseModel> login({
    required String phone,
    String? type,
    String? password,
    String? otp,
    String? deviceName,
    String? platform,
  }) async =>
      AuthResponseModel(status: true);

  @override
  Future<AuthResponseModel> register({
    required String phone,
    required String otp,
    String? referralCode,
    String? deviceName,
  }) async =>
      AuthResponseModel(status: true);

  @override
  Future<AuthResponseModel> forgetPassword({
    required String phone,
    required String otp,
    required String password,
    String? passwordConfirmation,
  }) =>
      resetPassword(
        phone: phone,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

  @override
  Future<AuthResponseModel?> getCurrentUser() async => null;

  @override
  Future<bool> logout() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V1 Forgot Password Endpoints & Model Integration', () {
    test('Endpoints contains valid V1 forgot and reset password routes', () {
      expect(Endpoints.forgotPassword, '/api/v1/auth/forgot-password');
      expect(Endpoints.resetPassword, '/api/v1/auth/reset-password');
      expect(Endpoints.forgetPassword, Endpoints.forgotPassword);
      expect(Endpoints.v1AuthForgotPassword, '/api/v1/auth/forgot-password');
      expect(Endpoints.v1AuthResetPassword, '/api/v1/auth/reset-password');
    });

    test('AuthResponseModel correctly parses 200 OK forgot-password response', () {
      final jsonResponse = {
        "success": true,
        "message": "Password reset OTP sent successfully to your mobile number.",
        "data": {
          "phone": "8801712345678",
          "type": "ForgotPassword",
          "otp": "452821",
          "expires_in": 300
        }
      };

      final model = AuthResponseModel.fromJson(jsonResponse);

      expect(model.status, isTrue);
      expect(model.message, 'Password reset OTP sent successfully to your mobile number.');
      expect(model.canonicalPhone, '8801712345678');
      expect(model.otp, '452821');
      expect(model.expiresIn, 300);
    });

    test('AuthResponseModel correctly parses 404 Not Found forgot-password error', () {
      final jsonResponse = {
        "success": false,
        "message": "No account found with this phone number.",
        "errors": {
          "phone": [
            "Account does not exist."
          ]
        }
      };

      final model = AuthResponseModel.fromJson(jsonResponse);

      expect(model.status, isFalse);
      expect(model.message, 'No account found with this phone number.');
    });

    test('AuthResponseModel correctly parses 200 OK reset-password response with user and token', () {
      final jsonResponse = {
        "success": true,
        "message": "Password reset successfully. You are now logged in with your new password.",
        "data": {
          "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
          "token_type": "bearer",
          "profile_completed": true,
          "user": {
            "id": 42,
            "user_id": "260900042",
            "name": "Arif Ahmed",
            "phone": "8801712345678",
            "email": "arif@gmail.com",
            "photo_url": "https://lokkha.com/uploads/profile/user_66ed.jpg",
            "gender": "male",
            "referral_code": "LK9A8B7C",
            "reward_points": 140,
            "is_subscribed": true
          }
        }
      };

      final model = AuthResponseModel.fromJson(jsonResponse);

      expect(model.status, isTrue);
      expect(model.token, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
      expect(model.tokenType, 'bearer');
      expect(model.profileCompleted, isTrue);
      expect(model.user, isNotNull);
      expect(model.user?.id, 42);
      expect(model.user?.name, 'Arif Ahmed');
      expect(model.user?.phone, '8801712345678');
      expect(model.user?.email, 'arif@gmail.com');
      expect(model.user?.isSubscribed, isTrue);
    });

    test('AuthResponseModel correctly parses 422 Invalid / Expired OTP reset-password response', () {
      final jsonResponse = {
        "success": false,
        "message": "Invalid or expired OTP. Please request a new OTP.",
        "errors": {
          "otp": [
            "The OTP code is invalid or has expired."
          ]
        }
      };

      final model = AuthResponseModel.fromJson(jsonResponse);

      expect(model.status, isFalse);
      expect(model.message, 'Invalid or expired OTP. Please request a new OTP.');
    });

    test('AuthResponseModel extracts detailed message from errors when message is generic', () {
      final jsonResponse = {
        "success": false,
        "message": "Validation Error",
        "errors": {
          "phone": [
            "The phone number field is required."
          ]
        }
      };

      final model = AuthResponseModel.fromJson(jsonResponse);

      expect(model.status, isFalse);
      expect(model.message, 'The phone number field is required.');
    });
  });

  group('V1 Clean Architecture UseCases', () {
    test('ForgotPasswordUseCase invokes repository.forgotPassword with normalized phone', () async {
      final mockRepo = _MockV1AuthRepository();
      final useCase = ForgotPasswordUseCase(mockRepo);

      final res = await useCase('01712345678');

      expect(res.status, isTrue);
      expect(mockRepo.lastForgotPhone, '01712345678');
      expect(res.otp, '452821');
      expect(res.expiresIn, 300);
    });

    test('ResetPasswordUseCase invokes repository.resetPassword with payload', () async {
      final mockRepo = _MockV1AuthRepository();
      final useCase = ResetPasswordUseCase(mockRepo);

      final res = await useCase(
        phone: '01712345678',
        otp: '452821',
        password: 'NewSecretPassword123',
        passwordConfirmation: 'NewSecretPassword123',
        deviceName: 'Google Pixel 8',
        platform: 'android',
      );

      expect(res.status, isTrue);
      expect(mockRepo.lastResetPhone, '01712345678');
      expect(mockRepo.lastResetOtp, '452821');
      expect(mockRepo.lastResetPassword, 'NewSecretPassword123');
      expect(mockRepo.lastResetConfirmPassword, 'NewSecretPassword123');
      expect(res.token, 'test_fresh_jwt_token');
    });

    test('ForgetPasswordUseCase backward-compatibility delegates correctly', () async {
      final mockRepo = _MockV1AuthRepository();
      final useCase = ForgetPasswordUseCase(mockRepo);

      final res = await useCase(
        phone: '01712345678',
        otp: '452821',
        password: 'NewSecretPassword123',
        passwordConfirmation: 'NewSecretPassword123',
      );

      expect(res.status, isTrue);
      expect(mockRepo.lastResetPhone, '01712345678');
      expect(mockRepo.lastResetOtp, '452821');
    });
  });
}
