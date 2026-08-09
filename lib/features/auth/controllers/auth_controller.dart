import 'package:flutter/material.dart';
import '../models/login_request_model.dart';
import '../models/logout_request_model.dart';
import '../models/register_request_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/auth_tokens_model.dart';
import '../repos/auth_repo.dart';

class AuthController extends ChangeNotifier {
  final AuthRepo _authRepo;

  AuthController({required AuthRepo authRepo}) : _authRepo = authRepo;

  String _email = '';
  String get email => _email;

  String _password = '';
  String get password => _password;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isObscurePassword = true;
  bool get isObscurePassword => _isObscurePassword;

  AuthTokensModel? _tokens;
  AuthTokensModel? get tokens => _tokens;

  bool get isLoggedIn => _tokens != null && _tokens!.access.isNotEmpty;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setEmail(String value) {
    _email = value.trim();
    _errorMessage = null;
  }

  void setPassword(String value) {
    _password = value;
    _errorMessage = null;
  }

  void togglePasswordVisibility() {
    _isObscurePassword = !_isObscurePassword;
    notifyListeners();
  }

  Future<bool> login() async {
    if (_email.isEmpty || _password.isEmpty) {
      _errorMessage = 'Email and password are required.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequestModel(email: _email, password: _password);
      _tokens = await _authRepo.login(request);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '$e'.replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(RegisterRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepo.register(request);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '$e'.replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> refreshToken({String? refreshTokenOverride}) async {
    final targetRefresh = refreshTokenOverride ?? _tokens?.refresh ?? '';
    if (targetRefresh.isEmpty) {
      _errorMessage = 'No refresh token available.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RefreshTokenRequestModel(refresh: targetRefresh);
      final newTokens = await _authRepo.refreshToken(request);
      _tokens = AuthTokensModel(
        access: newTokens.access,
        refresh: newTokens.refresh.isNotEmpty ? newTokens.refresh : targetRefresh,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '$e'.replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout({String? refreshTokenOverride}) async {
    final refreshToken = refreshTokenOverride ?? _tokens?.refresh ?? '';

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (refreshToken.isNotEmpty) {
        final request = LogoutRequestModel(refresh: refreshToken);
        await _authRepo.logout(request, accessToken: _tokens?.access);
      }
    } catch (e) {
      _errorMessage = '$e'.replaceAll('Exception: ', '');
    } finally {
      _tokens = null;
      _email = '';
      _password = '';
      _isLoading = false;
      notifyListeners();
    }

    return _errorMessage == null;
  }
}
