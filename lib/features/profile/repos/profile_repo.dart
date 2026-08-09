import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/user_profile_model.dart';
import '../models/user_profile_update_model.dart';

abstract class ProfileRepo {
  Future<UserProfileModel> getUserProfile({String? accessToken});
  Future<UserProfileModel> updateProfile(UserProfileUpdateModel request, {String? accessToken});
}

class HttpProfileRepo implements ProfileRepo {
  @override
  Future<UserProfileModel> getUserProfile({String? accessToken}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.profile),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return UserProfileModel.fromJson(decoded);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in to view your profile.');
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception(
        'Failed to fetch user profile from server.\nDetails: $e'
      );
    }
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileUpdateModel request, {String? accessToken}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.patch(
        Uri.parse(ApiEndpoints.profile),
        headers: headers,
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return UserProfileModel.fromJson(decoded);
      } else if (response.statusCode == 400) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('detail')) {
            throw Exception(decoded['detail']);
          }
          final buffer = StringBuffer();
          decoded.forEach((key, value) {
            buffer.writeln('$key: ${value is List ? value.join(', ') : value}');
          });
          throw Exception(buffer.toString().trim());
        }
        throw Exception('Validation Error. Please check your inputs.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in to update your profile.');
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }
      throw Exception(
        'Failed to update profile on backend server.\nDetails: $e'
      );
    }
  }
}

class MockProfileRepo implements ProfileRepo {
  UserProfileModel _mockProfile = UserProfileModel(
    id: 1,
    username: 'ramesh_kumar',
    email: 'ramesh.kumar@email.com',
    firstName: 'Ramesh',
    lastName: 'Kumar',
    isStaff: false,
    dateJoined: '2025-01-15T08:30:00Z',
    profile: UserProfileDetailsModel(
      phoneNumber: '+977 98765 43210',
      city: 'Pokhara',
      createdAt: '2025-01-15T08:30:00Z',
    ),
  );

  @override
  Future<UserProfileModel> getUserProfile({String? accessToken}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockProfile;
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileUpdateModel request, {String? accessToken}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _mockProfile = UserProfileModel(
      id: _mockProfile.id,
      username: _mockProfile.username,
      email: request.email ?? _mockProfile.email,
      firstName: request.firstName ?? _mockProfile.firstName,
      lastName: request.lastName ?? _mockProfile.lastName,
      isStaff: _mockProfile.isStaff,
      dateJoined: _mockProfile.dateJoined,
      profile: UserProfileDetailsModel(
        phoneNumber: request.phoneNumber ?? _mockProfile.profile?.phoneNumber,
        city: request.city ?? _mockProfile.profile?.city,
        createdAt: _mockProfile.profile?.createdAt,
      ),
    );

    return _mockProfile;
  }
}
