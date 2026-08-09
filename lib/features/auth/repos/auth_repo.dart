import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/login_request_model.dart';
import '../models/logout_request_model.dart';
import '../models/register_request_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/auth_tokens_model.dart';

abstract class AuthRepo {
  Future<AuthTokensModel> login(LoginRequestModel request);
  Future<void> logout(LogoutRequestModel request, {String? accessToken});
  Future<void> register(RegisterRequestModel request);
  Future<AuthTokensModel> refreshToken(RefreshTokenRequestModel request);
}

class HttpAuthRepo implements AuthRepo {
  @override
  Future<AuthTokensModel> login(LoginRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthTokensModel.fromJson(decoded);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('detail')) {
            throw Exception(decoded['detail']);
          } else if (decoded.containsKey('non_field_errors')) {
            final errors = decoded['non_field_errors'] as List;
            throw Exception(errors.join(', '));
          } else {
            // Field specific errors
            final buffer = StringBuffer();
            decoded.forEach((key, value) {
              buffer.writeln('$key: ${value is List ? value.join(', ') : value}');
            });
            throw Exception(buffer.toString().trim());
          }
        }
        throw Exception('Invalid email or password.');
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception(
        'Failed to connect to backend server. Please verify if the API is running locally.\nDetails: $e'
      );
    }
  }

  @override
  Future<void> logout(LogoutRequestModel request, {String? accessToken}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.logout),
        headers: headers,
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid Refresh Token');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception(
        'Failed to connect to backend server during logout.\nDetails: $e'
      );
    }
  }

  @override
  Future<void> register(RegisterRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
      } else if (response.statusCode == 400) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('detail')) {
            throw Exception(decoded['detail']);
          } else if (decoded.containsKey('non_field_errors')) {
            final errors = decoded['non_field_errors'] as List;
            throw Exception(errors.join(', '));
          } else {
            final buffer = StringBuffer();
            decoded.forEach((key, value) {
              buffer.writeln('$key: ${value is List ? value.join(', ') : value}');
            });
            throw Exception(buffer.toString().trim());
          }
        }
        throw Exception('Validation error during registration.');
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception(
        'Failed to connect to backend server during registration.\nDetails: $e'
      );
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(RefreshTokenRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthTokensModel.fromJson(decoded);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('detail')) {
          throw Exception(decoded['detail']);
        }
        throw Exception('Invalid or expired refresh token.');
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception(
        'Failed to connect to backend server during token refresh.\nDetails: $e'
      );
    }
  }
}

class MockAuthRepo implements AuthRepo {
  @override
  Future<AuthTokensModel> login(LoginRequestModel request) async {
    await Future.delayed(const Duration(seconds: 1));

    if (request.email.isNotEmpty && request.password.isNotEmpty) {
      return AuthTokensModel(
        access: 'mock_jwt_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refresh: 'mock_jwt_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      );
    } else {
      throw Exception('Invalid credentials provided.');
    }
  }

  @override
  Future<void> logout(LogoutRequestModel request, {String? accessToken}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (request.refresh.isEmpty) {
      throw Exception('Invalid Refresh Token');
    }
  }

  @override
  Future<void> register(RegisterRequestModel request) async {
    await Future.delayed(const Duration(seconds: 1));
    if (request.password != request.passwordConfirm) {
      throw Exception('Passwords do not match.');
    }
    if (request.username.isEmpty || request.email.isEmpty || request.password.isEmpty) {
      throw Exception('Required fields cannot be empty.');
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(RefreshTokenRequestModel request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (request.refresh.isEmpty) {
      throw Exception('Invalid or expired refresh token.');
    }
    return AuthTokensModel(
      access: 'refreshed_mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refresh: request.refresh,
    );
  }
}
