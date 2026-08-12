import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/prediction_history_model.dart';
import '../../../core/services/mock_database.dart';

abstract class HomeRepo {
  Future<WeatherModel> fetchWeatherData({double? latitude, double? longitude, String? locationName});
  Future<List<PredictionHistoryModel>> fetchPredictionHistory();
}

class OpenMeteoHomeRepo implements HomeRepo {
  static String _wmoCodeToCondition(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Partly Cloudy';
    }
  }

  @override
  Future<WeatherModel> fetchWeatherData({double? latitude, double? longitude, String? locationName}) async {
    final lat = latitude ?? 27.7172; // Kathmandu lat long
    final lon = longitude ?? 85.3240;

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,is_day',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final current = decoded['current'] as Map<String, dynamic>?;

        if (current != null) {
          final temp = (current['temperature_2m'] as num).toDouble();
          final humidity = (current['relative_humidity_2m'] as num).toDouble();
          final weatherCode = (current['weather_code'] as num).toInt();
          final isDayVal = (current['is_day'] as num?)?.toInt() ?? 1;
          final condition = _wmoCodeToCondition(weatherCode);

          return WeatherModel(
            temperature: temp,
            condition: condition,
            location: (locationName != null && locationName.isNotEmpty) ? locationName : 'Kathmandu, Nepal',
            humidity: humidity,
            weatherCode: weatherCode,
            isDay: isDayVal == 1,
          );
        }
      }
    } catch (_) {}

    return WeatherModel(
      temperature: 23.0,
      condition: 'Partly Cloudy',
      location: (locationName != null && locationName.isNotEmpty) ? locationName : 'Kathmandu, Nepal',
      humidity: 65.0,
      weatherCode: 2,
      isDay: true,
    );
  }

  @override
  Future<List<PredictionHistoryModel>> fetchPredictionHistory() async {
    return [];
  }
}

class MockHomeRepo implements HomeRepo {
  @override
  Future<WeatherModel> fetchWeatherData({double? latitude, double? longitude, String? locationName}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return WeatherModel(
      temperature: 23.0,
      condition: 'Partly Cloudy',
      location: locationName ?? 'Mumbai, India',
      humidity: 65.0,
    );
  }

  @override
  Future<List<PredictionHistoryModel>> fetchPredictionHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MockDatabase.historyList.take(3).map((item) {
      return PredictionHistoryModel(
        id: item.id,
        cropName: item.cropName,
        date: item.date.split(' • ').first,
        recommendation: item.recommendedFertilizer ?? 'Pending',
        imageUrl: 'assets/images/${item.cropName.toLowerCase()}.png',
      );
    }).toList();
  }
}
