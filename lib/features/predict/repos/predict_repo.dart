import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/predict_request_model.dart';
import '../models/prediction_result_model.dart';

abstract class PredictRepo {
  Future<PredictionResultModel> predictCrop(PredictRequestModel request, {String? token});
}

class HttpPredictRepo implements PredictRepo {
  Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  @override
  Future<PredictionResultModel> predictCrop(PredictRequestModel request, {String? token}) async {
    final uri = Uri.parse(ApiEndpoints.predictCrop);
    String? lastError;

    // 1. Try POST request with Bearer Auth header
    try {
      final response = await http.post(
        uri,
        headers: _headers(token),
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return PredictionResultModel.fromJson(decoded);
      } else {
        lastError = 'Server error (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      lastError = 'Network error: $e';
    }

    // 2. Retry without Bearer token if auth 401/403 or CORS error occurs
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'ngrok-skip-browser-warning': 'true'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return PredictionResultModel.fromJson(decoded);
      } else {
        lastError = 'Server error (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      lastError = 'Network error: $e';
    }

    throw Exception(lastError);
  }
}

class MockPredictRepo implements PredictRepo {
  @override
  Future<PredictionResultModel> predictCrop(PredictRequestModel request, {String? token}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Return Rice matching the new response JSON structure
    return PredictionResultModel.fromJson(const {
      "status": "success",
      "data": {
        "recommended_crop": "rice",
        "confidence": 99.85,
        "alternative_crops": [
          {
            "crop": "jute",
            "confidence": 0.13
          },
          {
            "crop": "watermelon",
            "confidence": 0.0
          },
          {
            "crop": "papaya",
            "confidence": 0.0
          }
        ],
        "climate_data": {
          "temperature": 22.95,
          "humidity": 85.17,
          "rainfall": 828.9,
          "season": "Monsoon",
          "source": "NASA POWER 2025 API (Mocked)"
        },
        "explanation": "Rice matches your soil NPK composition (N:90.0, P:42.0, K:43.0). For the Monsoon season, NASA 2025 API data shows an average temperature of 22.95°C, humidity of 85.17%, and seasonal rainfall of 828.9mm. Soil pH of 6.5 is neutral and well-suited for nutrient absorption. (Mocked response)",
        "advice": "High seasonal rainfall. Ensure proper field drainage."
      }
    });
  }
}
