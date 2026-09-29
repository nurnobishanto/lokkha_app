import 'package:lokkha/shared/models/user.dart';

class AuthResponseModel {
  final bool status;
  final String? message;
  final String? token;
  final String? tokenType;
  final User? user;
  final bool havePackage;
  final bool profileCompleted;
  final bool isRegistered;
  final Map<String, dynamic>? rawData;

  AuthResponseModel({
    required this.status,
    this.message,
    this.token,
    this.tokenType = 'Bearer',
    this.user,
    this.havePackage = false,
    this.profileCompleted = true,
    this.isRegistered = true,
    this.rawData,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] == true || json['status'] == 1 || json['success'] == true;
    
    String? message;
    if (json['message'] is String) {
      message = json['message'] as String;
    } else if (json['msg'] is String) {
      message = json['msg'] as String;
    } else if (json['message'] is Map) {
      final msgMap = json['message'] as Map;
      if (msgMap.values.isNotEmpty) {
        final firstVal = msgMap.values.first;
        if (firstVal is List && firstVal.isNotEmpty) {
          message = firstVal.first.toString();
        } else {
          message = firstVal.toString();
        }
      }
    } else if (json['errors'] is Map) {
      final errMap = json['errors'] as Map;
      if (errMap.values.isNotEmpty) {
        final firstVal = errMap.values.first;
        if (firstVal is List && firstVal.isNotEmpty) {
          message = firstVal.first.toString();
        } else {
          message = firstVal.toString();
        }
      }
    }

    // Flexible extraction for token (supports V1 'data.token' and legacy 'token')
    String? token;
    if (json['token'] != null) {
      token = json['token'].toString();
    } else if (json['data'] is Map && json['data']['token'] != null) {
      token = json['data']['token'].toString();
    } else if (json['jwt_token'] != null) {
      token = json['jwt_token'].toString();
    }

    final tokenType = (json['data'] is Map && json['data']['token_type'] != null)
        ? json['data']['token_type'].toString()
        : 'Bearer';

    // Flexible extraction for User
    User? user;
    if (json['data'] is Map && json['data']['user'] is Map) {
      user = User.fromJson(json['data']['user'] as Map<String, dynamic>);
    } else if (json['user'] is Map) {
      user = User.fromJson(json['user'] as Map<String, dynamic>);
    } else if (json['data'] is Map && json['data']['id'] != null) {
      user = User.fromJson(json['data'] as Map<String, dynamic>);
    }

    // Flexible extraction for havePackage
    bool havePackage = false;
    if (json['havePackage'] != null) {
      havePackage = json['havePackage'] == true || json['havePackage'] == 1;
    } else if (json['have_package'] != null) {
      havePackage = json['have_package'] == true || json['have_package'] == 1;
    } else if (json['data'] is Map && json['data']['have_package'] != null) {
      havePackage = json['data']['have_package'] == true || json['data']['have_package'] == 1;
    } else if (json['data'] is Map && json['data']['user'] is Map && json['data']['user']['have_package'] != null) {
      havePackage = json['data']['user']['have_package'] == true || json['data']['user']['have_package'] == 1;
    }

    // Flexible extraction for profileCompleted
    bool profileCompleted = true;
    if (json['profile_completed'] != null) {
      profileCompleted = json['profile_completed'] == true || json['profile_completed'] == 1;
    } else if (json['data'] is Map && json['data']['profile_completed'] != null) {
      profileCompleted = json['data']['profile_completed'] == true || json['data']['profile_completed'] == 1;
    }

    // Flexible extraction for isRegistered (from check-phone endpoint)
    bool isRegistered = true;
    if (json['registered'] != null) {
      isRegistered = json['registered'] == true || json['registered'] == 1;
    } else if (json['is_registered'] != null) {
      isRegistered = json['is_registered'] == true || json['is_registered'] == 1;
    } else if (json['data'] is Map && json['data']['registered'] != null) {
      isRegistered = json['data']['registered'] == true || json['data']['registered'] == 1;
    } else if (json['data'] is Map && json['data']['is_registered'] != null) {
      isRegistered = json['data']['is_registered'] == true || json['data']['is_registered'] == 1;
    }

    return AuthResponseModel(
      status: status,
      message: message,
      token: token,
      tokenType: tokenType,
      user: user,
      havePackage: havePackage,
      profileCompleted: profileCompleted,
      isRegistered: isRegistered,
      rawData: json,
    );
  }
}
