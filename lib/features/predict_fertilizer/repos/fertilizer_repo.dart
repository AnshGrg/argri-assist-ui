import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/fertilizer_request_model.dart';
import '../models/fertilizer_result_model.dart';

abstract class FertilizerRepo {
  Future<FertilizerResultModel> predictFertilizer(FertilizerRequestModel request, {String? token});
  Future<List<String>> getCrops();
  Future<List<String>> getFertilizers();
}

class HttpFertilizerRepo implements FertilizerRepo {
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
  Future<FertilizerResultModel> predictFertilizer(FertilizerRequestModel request, {String? token}) async {
    final uri = Uri.parse(ApiEndpoints.predictFertilizer);

    String? lastError;

    // 1. Try POST request with Bearer Auth header so prediction is stored in DB for authenticated farmer
    try {
      final response = await http.post(
        uri,
        headers: _headers(token),
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return FertilizerResultModel.fromJson(decoded);
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
        return FertilizerResultModel.fromJson(decoded);
      }
    } catch (_) {}

    throw Exception(lastError);
  }

  @override
  Future<List<String>> getCrops() async {
    final uri = Uri.parse(ApiEndpoints.getCrops);

    // 1. Try with ngrok header
    try {
      final response = await http.get(
        uri,
        headers: {'ngrok-skip-browser-warning': 'true'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List cropsList = [];
        if (decoded is List) {
          cropsList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          cropsList = (decoded['crops'] as List?) ?? (decoded['results'] as List?) ?? [];
        }
        if (cropsList.isNotEmpty) {
          return cropsList.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}

    // 2. Try standard GET without headers
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List cropsList = [];
        if (decoded is List) {
          cropsList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          cropsList = (decoded['crops'] as List?) ?? (decoded['results'] as List?) ?? [];
        }
        if (cropsList.isNotEmpty) {
          return cropsList.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}

    // 3. Fallback default 22 supported crops
    return const [
      'apple', 'banana', 'blackgram', 'chickpea', 'coconut', 'coffee',
      'cotton', 'grapes', 'jute', 'kidneybeans', 'lentil', 'maize',
      'mango', 'mothbeans', 'mungbean', 'muskmelon', 'orange', 'papaya',
      'pigeonpeas', 'pomegranate', 'rice', 'watermelon'
    ];
  }

  @override
  Future<List<String>> getFertilizers() async {
    final uri = Uri.parse(ApiEndpoints.getFertilizers);

    // 1. Try with ngrok header
    try {
      final response = await http.get(
        uri,
        headers: {'ngrok-skip-browser-warning': 'true'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['fertilizers'] as List?) ?? (decoded['results'] as List?) ?? [];
        }
        if (list.isNotEmpty) {
          return list.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}

    // 2. Try standard GET without headers
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['fertilizers'] as List?) ?? (decoded['results'] as List?) ?? [];
        }
        if (list.isNotEmpty) {
          return list.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}

    // 3. Fallback default 9 supported fertilizers
    return const [
      'Urea', 'DAP', 'MOP', 'SSP', 'NPK 10-26-26', 'NPK 12-32-16', 'NPK 20-20-0', 'Compost', 'Lime'
    ];
  }
}

class MockFertilizerRepo implements FertilizerRepo {
  @override
  Future<FertilizerResultModel> predictFertilizer(FertilizerRequestModel request, {String? token}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return DAP matching the new response JSON structure
    return FertilizerResultModel.fromJson(const {
      "status": "success",
      "data": {
        "recommended_fertilizer": "DAP",
        "confidence": 99.95,
        "npk_analysis": {
          "nitrogen_status": "High",
          "phosphorus_status": "Optimal",
          "potassium_status": "Optimal",
          "ph_status": "Neutral"
        },
        "climate_data": {
          "temperature": 22.95,
          "humidity": 85.17,
          "rainfall": 828.9,
          "season": "Monsoon",
          "source": "NASA POWER 2025 API (Mocked)"
        },
        "explanation": "Recommended DAP to balance soil nutrients for growing rice during the Monsoon season. (Mocked response)",
        "application_advice": "Apply DAP during sowing for root development."
      }
    });
  }

  @override
  Future<List<String>> getCrops() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      'apple',
      'banana',
      'blackgram',
      'chickpea',
      'coconut',
      'coffee',
      'cotton',
      'grapes',
      'jute',
      'kidneybeans',
      'lentil',
      'maize',
      'mango',
      'mothbeans',
      'mungbean',
      'muskmelon',
      'orange',
      'papaya',
      'pigeonpeas',
      'pomegranate',
      'rice',
      'watermelon'
    ];
  }

  @override
  Future<List<String>> getFertilizers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      'Urea', 'DAP', 'MOP', 'SSP', 'NPK 10-26-26', 'NPK 12-32-16', 'NPK 20-20-0', 'Compost', 'Lime'
    ];
  }
}
