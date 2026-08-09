import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/analytics_kpi_model.dart';
import '../models/climate_card_model.dart';
import '../models/crop_distribution_model.dart';
import '../models/fertilizer_demand_model.dart';
import '../models/soil_acidity_hotspot_model.dart';
import '../models/usage_trend_model.dart';

class AnalyticsAuthException implements Exception {
  final int statusCode;
  final String message;
  AnalyticsAuthException(this.statusCode, this.message);
  @override
  String toString() => message;
}

abstract class AnalyticsRepo {
  Future<AnalyticsKpiModel> fetchKpis(String? authToken);
  Future<List<RegionalFertilizerDemand>> fetchFertilizerDemand(String? authToken);
  Future<List<SoilAcidityHotspot>> fetchSoilAcidityHotspots(String? authToken);
  Future<List<SeasonalCropDistribution>> fetchCropDistribution(String? authToken);
  Future<List<DailyUsageTrend>> fetchUsageTrends(String? authToken);
  Future<List<ClimateCardModel>> fetchClimateData(String? authToken);
}

class HttpAnalyticsRepo implements AnalyticsRepo {
  final http.Client _client;

  HttpAnalyticsRepo({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _handleErrorResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw AnalyticsAuthException(401, 'Authentication credentials were not provided or have expired.');
    } else if (response.statusCode == 403) {
      throw AnalyticsAuthException(403, 'Access restricted to Staff Users (is_staff=True).');
    } else if (response.statusCode >= 500) {
      throw Exception('Server error (${response.statusCode}). Please try again later.');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to load data (${response.statusCode}).');
    }
  }

  @override
  Future<AnalyticsKpiModel> fetchKpis(String? authToken) async {
    final url = Uri.parse(ApiEndpoints.analyticsKpis);
    final response = await _client.get(url, headers: _buildHeaders(authToken));
    _handleErrorResponse(response);
    final Map<String, dynamic> body = jsonDecode(response.body);
    return AnalyticsKpiModel.fromJson(body);
  }

  @override
  Future<List<RegionalFertilizerDemand>> fetchFertilizerDemand(String? authToken) async {
    final url = Uri.parse(ApiEndpoints.analyticsFertilizerDemand);
    final response = await _client.get(url, headers: _buildHeaders(authToken));
    _handleErrorResponse(response);
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> list = body['regional_demand'] as List<dynamic>? ?? [];
    return list.map((item) => RegionalFertilizerDemand.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SoilAcidityHotspot>> fetchSoilAcidityHotspots(String? authToken) async {
    final url = Uri.parse(ApiEndpoints.analyticsSoilAcidity);
    final response = await _client.get(url, headers: _buildHeaders(authToken));
    _handleErrorResponse(response);
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> list = body['hotspots'] as List<dynamic>? ?? [];
    return list.map((item) => SoilAcidityHotspot.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SeasonalCropDistribution>> fetchCropDistribution(String? authToken) async {
    final url = Uri.parse(ApiEndpoints.analyticsCropDistribution);
    final response = await _client.get(url, headers: _buildHeaders(authToken));
    _handleErrorResponse(response);
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> list = body['crop_distribution'] as List<dynamic>? ?? [];
    return list.map((item) => SeasonalCropDistribution.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DailyUsageTrend>> fetchUsageTrends(String? authToken) async {
    final url = Uri.parse(ApiEndpoints.analyticsUsageTrends);
    final response = await _client.get(url, headers: _buildHeaders(authToken));
    _handleErrorResponse(response);
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> list = body['daily_trends'] as List<dynamic>? ?? [];
    return list.map((item) => DailyUsageTrend.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ClimateCardModel>> fetchClimateData(String? authToken) async {
    // NASA Satellite Climate averages fallback/spec endpoint
    return [
      ClimateCardModel(city: 'Pokhara', averageTemperature: 24.8, averageHumidity: 82.1, averageRainfall: 245.5),
      ClimateCardModel(city: 'Chitwan', averageTemperature: 28.2, averageHumidity: 74.5, averageRainfall: 180.0),
      ClimateCardModel(city: 'Kathmandu', averageTemperature: 22.4, averageHumidity: 78.0, averageRainfall: 195.2),
      ClimateCardModel(city: 'Lalitpur', averageTemperature: 22.1, averageHumidity: 76.8, averageRainfall: 188.4),
    ];
  }
}

class MockAnalyticsRepo implements AnalyticsRepo {
  @override
  Future<AnalyticsKpiModel> fetchKpis(String? authToken) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return AnalyticsKpiModel(
      totalFarmers: 1420,
      totalCropPredictions: 5340,
      totalFertilizerPredictions: 4890,
      totalAcidicSoilAlerts: 1280,
      acidicSoilPercentage: 26.18,
      nitrogenDeficiencyRate: 42.0,
      phosphorusDeficiencyRate: 38.0,
      potassiumDeficiencyRate: 21.0,
    );
  }

  @override
  Future<List<RegionalFertilizerDemand>> fetchFertilizerDemand(String? authToken) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      RegionalFertilizerDemand(
        city: 'Pokhara',
        totalQueries: 1160,
        fertilizers: {
          'DAP': 420,
          'Urea': 310,
          'Lime / Gypsum': 280,
          'MOP': 150,
        },
      ),
      RegionalFertilizerDemand(
        city: 'Chitwan',
        totalQueries: 1240,
        fertilizers: {
          'Urea': 550,
          'DAP': 480,
          '20-20-0': 210,
        },
      ),
      RegionalFertilizerDemand(
        city: 'Kathmandu',
        totalQueries: 890,
        fertilizers: {
          'Urea': 390,
          'DAP': 320,
          '17-17-17': 180,
        },
      ),
      RegionalFertilizerDemand(
        city: 'Lalitpur',
        totalQueries: 750,
        fertilizers: {
          'Lime / Gypsum': 340,
          'DAP': 240,
          'Urea': 170,
        },
      ),
    ];
  }

  @override
  Future<List<SoilAcidityHotspot>> fetchSoilAcidityHotspots(String? authToken) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      SoilAcidityHotspot(
        city: 'Pokhara',
        averagePh: 5.12,
        totalTests: 850,
        acidicTestsCount: 590,
        acidicPercentage: 69.41,
        acidityRiskLevel: 'CRITICAL',
        actionRequired: 'Subsidy Lime 200kg/ha',
      ),
      SoilAcidityHotspot(
        city: 'Lalitpur',
        averagePh: 5.38,
        totalTests: 420,
        acidicTestsCount: 210,
        acidicPercentage: 50.0,
        acidityRiskLevel: 'HIGH',
        actionRequired: 'Subsidy Lime 150kg/ha',
      ),
      SoilAcidityHotspot(
        city: 'Chitwan',
        averagePh: 6.35,
        totalTests: 1100,
        acidicTestsCount: 120,
        acidicPercentage: 10.91,
        acidityRiskLevel: 'LOW',
        actionRequired: 'Normal Monitoring',
      ),
      SoilAcidityHotspot(
        city: 'Bhaktapur',
        averagePh: 5.42,
        totalTests: 390,
        acidicTestsCount: 185,
        acidicPercentage: 47.43,
        acidityRiskLevel: 'HIGH',
        actionRequired: 'Subsidy Lime 120kg/ha',
      ),
    ];
  }

  @override
  Future<List<SeasonalCropDistribution>> fetchCropDistribution(String? authToken) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      SeasonalCropDistribution(
        season: 'Monsoon',
        totalRecommendations: 2310,
        topCrops: [
          CropShare(crop: 'rice', count: 1420, percentage: 61.47),
          CropShare(crop: 'maize', count: 890, percentage: 38.53),
        ],
      ),
      SeasonalCropDistribution(
        season: 'Winter',
        totalRecommendations: 1170,
        topCrops: [
          CropShare(crop: 'chickpea', count: 650, percentage: 55.56),
          CropShare(crop: 'lentil', count: 520, percentage: 44.44),
        ],
      ),
      SeasonalCropDistribution(
        season: 'Summer',
        totalRecommendations: 980,
        topCrops: [
          CropShare(crop: 'jute', count: 510, percentage: 52.04),
          CropShare(crop: 'cotton', count: 470, percentage: 47.96),
        ],
      ),
      SeasonalCropDistribution(
        season: 'Pre-Monsoon',
        totalRecommendations: 880,
        topCrops: [
          CropShare(crop: 'watermelon', count: 480, percentage: 54.55),
          CropShare(crop: 'muskmelon', count: 400, percentage: 45.45),
        ],
      ),
    ];
  }

  @override
  Future<List<DailyUsageTrend>> fetchUsageTrends(String? authToken) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      DailyUsageTrend(date: '2026-08-03', cropQueries: 110, fertilizerQueries: 95),
      DailyUsageTrend(date: '2026-08-04', cropQueries: 132, fertilizerQueries: 115),
      DailyUsageTrend(date: '2026-08-05', cropQueries: 125, fertilizerQueries: 108),
      DailyUsageTrend(date: '2026-08-06', cropQueries: 145, fertilizerQueries: 120),
      DailyUsageTrend(date: '2026-08-07', cropQueries: 182, fertilizerQueries: 165),
      DailyUsageTrend(date: '2026-08-08', cropQueries: 195, fertilizerQueries: 178),
      DailyUsageTrend(date: '2026-08-09', cropQueries: 210, fertilizerQueries: 190),
    ];
  }

  @override
  Future<List<ClimateCardModel>> fetchClimateData(String? authToken) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      ClimateCardModel(city: 'Pokhara', averageTemperature: 24.8, averageHumidity: 82.1, averageRainfall: 245.5),
      ClimateCardModel(city: 'Chitwan', averageTemperature: 28.2, averageHumidity: 74.5, averageRainfall: 180.0),
      ClimateCardModel(city: 'Kathmandu', averageTemperature: 22.4, averageHumidity: 78.0, averageRainfall: 195.2),
      ClimateCardModel(city: 'Lalitpur', averageTemperature: 22.1, averageHumidity: 76.8, averageRainfall: 188.4),
    ];
  }
}
