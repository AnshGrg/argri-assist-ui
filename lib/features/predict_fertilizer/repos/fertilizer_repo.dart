import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/fertilizer_request_model.dart';
import '../models/fertilizer_result_model.dart';

abstract class FertilizerRepo {
  Future<FertilizerResultModel> predictFertilizer(FertilizerRequestModel request);
  Future<List<String>> getCrops();
}

class HttpFertilizerRepo implements FertilizerRepo {
  @override
  Future<FertilizerResultModel> predictFertilizer(FertilizerRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.predictFertilizer),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return FertilizerResultModel.fromJson(decoded);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to backend server. Please verify if the API is running locally.\nDetails: $e'
      );
    }
  }

  @override
  Future<List<String>> getCrops() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getCrops),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final cropsList = decoded['crops'] as List;
        return cropsList.map((e) => e.toString()).toList();
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load crops list: $e');
    }
  }
}

class MockFertilizerRepo implements FertilizerRepo {
  @override
  Future<FertilizerResultModel> predictFertilizer(FertilizerRequestModel request) async {
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
}
