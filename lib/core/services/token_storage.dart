import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/models/auth_tokens_model.dart';
import '../../features/predict/controllers/predict_controller.dart';

class TokenStorage {
  static const _key = 'auth_tokens';
  static const _cityKey = 'user_selected_city';

  static Future<void> saveTokens(AuthTokensModel tokens) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(tokens.toJson()));
    } catch (e) {
      // missing error
    }
  }

  static Future<AuthTokensModel?> loadTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final tokens = AuthTokensModel.fromJson(json);
      if (tokens.access.isEmpty) return null;
      return tokens;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }

  static Future<void> saveSelectedCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cityKey, city);
    } catch (_) {}
  }

  static Future<LocationOption> loadSelectedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cityName = prefs.getString(_cityKey);
      if (cityName != null && cityName.isNotEmpty) {
        final found = PredictController.locationOptions.firstWhere(
          (loc) => loc.name.toLowerCase() == cityName.toLowerCase() ||
                   loc.displayName.toLowerCase() == cityName.toLowerCase(),
          orElse: () => PredictController.locationOptions.first,
        );
        return found;
      }
    } catch (_) {}
    return PredictController.locationOptions.first;
  }
}
