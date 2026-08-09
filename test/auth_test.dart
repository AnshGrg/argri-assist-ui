import 'package:flutter_test/flutter_test.dart';
import 'package:agri_assist/features/auth/models/login_request_model.dart';
import 'package:agri_assist/features/auth/models/logout_request_model.dart';
import 'package:agri_assist/features/auth/models/register_request_model.dart';
import 'package:agri_assist/features/auth/models/refresh_token_request_model.dart';
import 'package:agri_assist/features/auth/models/auth_tokens_model.dart';
import 'package:agri_assist/features/auth/repos/auth_repo.dart';
import 'package:agri_assist/features/auth/controllers/auth_controller.dart';

void main() {
  group('Auth feature tests', () {
    test('LoginRequestModel serialization and deserialization', () {
      final model = LoginRequestModel(email: 'user@example.com', password: 'password123');
      final json = model.toJson();

      expect(json['email'], 'user@example.com');
      expect(json['password'], 'password123');

      final fromJsonModel = LoginRequestModel.fromJson(json);
      expect(fromJsonModel.email, 'user@example.com');
      expect(fromJsonModel.password, 'password123');
    });

    test('LogoutRequestModel serialization and deserialization', () {
      final model = LogoutRequestModel(refresh: 'sample_refresh_token');
      final json = model.toJson();

      expect(json['refresh'], 'sample_refresh_token');

      final fromJsonModel = LogoutRequestModel.fromJson(json);
      expect(fromJsonModel.refresh, 'sample_refresh_token');
    });

    test('RegisterRequestModel serialization and deserialization', () {
      final model = RegisterRequestModel(
        username: 'newuser',
        email: 'newuser@example.com',
        firstName: 'New',
        lastName: 'User',
        phoneNumber: '+977 9811111111',
        city: 'Pokhara',
        password: 'Password123!',
        passwordConfirm: 'Password123!',
      );

      final json = model.toJson();
      expect(json['username'], 'newuser');
      expect(json['email'], 'newuser@example.com');
      expect(json['first_name'], 'New');
      expect(json['last_name'], 'User');
      expect(json['phone_number'], '+977 9811111111');
      expect(json['city'], 'Pokhara');
      expect(json['password'], 'Password123!');
      expect(json['password_confirm'], 'Password123!');
    });

    test('RefreshTokenRequestModel serialization and deserialization', () {
      final model = RefreshTokenRequestModel(refresh: 'refresh_token_xyz');
      final json = model.toJson();

      expect(json['refresh'], 'refresh_token_xyz');
      final fromJsonModel = RefreshTokenRequestModel.fromJson(json);
      expect(fromJsonModel.refresh, 'refresh_token_xyz');
    });

    test('AuthTokensModel serialization and deserialization', () {
      final json = {
        'access': 'access_token_val',
        'refresh': 'refresh_token_val',
      };
      final model = AuthTokensModel.fromJson(json);

      expect(model.access, 'access_token_val');
      expect(model.refresh, 'refresh_token_val');
      expect(model.toJson(), json);
    });

    test('MockAuthRepo registration success and password mismatch failure', () async {
      final repo = MockAuthRepo();

      final validReg = RegisterRequestModel(
        username: 'testuser',
        email: 'test@example.com',
        password: 'secretpassword',
        passwordConfirm: 'secretpassword',
      );
      await expectLater(repo.register(validReg), completes);

      final invalidReg = RegisterRequestModel(
        username: 'testuser',
        email: 'test@example.com',
        password: 'secretpassword',
        passwordConfirm: 'wrongpassword',
      );
      await expectLater(repo.register(invalidReg), throwsA(isA<Exception>()));
    });

    test('AuthController token refresh workflow', () async {
      final controller = AuthController(authRepo: MockAuthRepo());
      controller.setEmail('user@example.com');
      controller.setPassword('password');

      await controller.login();
      final oldAccess = controller.tokens?.access;
      expect(oldAccess != null, true);

      final refreshSuccess = await controller.refreshToken();
      expect(refreshSuccess, true);
      expect(controller.tokens?.access != oldAccess, true);
      expect(controller.isLoggedIn, true);
    });
  });
}
