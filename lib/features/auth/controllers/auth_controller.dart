import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/login_request_model.dart';
import '../models/logout_request_model.dart';
import '../models/register_request_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/auth_tokens_model.dart';
import '../repos/auth_repo.dart';
import '../../../core/services/token_storage.dart';

class AuthController extends ChangeNotifier {
  final AuthRepo _authRepo;

  AuthController({required AuthRepo authRepo}) : _authRepo = authRepo {
    // Load persisted tokens synchronously/asynchronously on construction
    _loadPersistedTokens();
  }

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

  /// Load tokens saved from a previous session.
  Future<void> _loadPersistedTokens() async {
    final saved = await TokenStorage.loadTokens();
    if (saved != null) {
      _tokens = saved;
      notifyListeners();
    }
  }

  /// Check saved access token expiration via JwtDecoder.
  /// If expired, call refresh token endpoint. If refresh token is also expired or fails, clear session.
  Future<bool> checkAndValidateSavedSession() async {
    final saved = await TokenStorage.loadTokens();
    if (saved == null || saved.access.isEmpty) {
      _tokens = null;
      notifyListeners();
      return false;
    }

    _tokens = saved;

    // Check if access token is expired using JwtDecoder
    bool accessExpired = false;
    try {
      accessExpired = JwtDecoder.isExpired(saved.access);
    } catch (_) {
      // If token is opaque or cannot be parsed by JwtDecoder, treat as NOT expired locally
      // and rely on backend 401/403 responses
      accessExpired = false;
    }

    if (accessExpired) {
      // Access token is expired -> attempt to refresh token
      if (saved.refresh.isNotEmpty) {
        bool refreshExpired = false;
        try {
          refreshExpired = JwtDecoder.isExpired(saved.refresh);
        } catch (_) {
          refreshExpired = false;
        }

        if (!refreshExpired) {
          final refreshed = await refreshToken(refreshTokenOverride: saved.refresh);
          if (refreshed && _tokens != null && _tokens!.access.isNotEmpty) {
            return true;
          }
        }
      }

      // Refresh token expired or refresh API failed -> clear session & redirect to login
      await TokenStorage.clearTokens();
      _tokens = null;
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }

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
      await TokenStorage.saveTokens(_tokens!);
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
        username: newTokens.username ?? _tokens?.username,
        email: newTokens.email ?? _tokens?.email,
        userId: newTokens.userId ?? _tokens?.userId,
      );
      await TokenStorage.saveTokens(_tokens!);
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
      await TokenStorage.clearTokens();
      _isLoading = false;
      notifyListeners();
    }

    return _errorMessage == null;
  }
}
