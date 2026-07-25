import '../models/weather_model.dart';
import '../models/prediction_history_model.dart';
import '../../../core/services/mock_database.dart';

abstract class HomeRepo {
  Future<WeatherModel> fetchWeatherData();
  Future<List<PredictionHistoryModel>> fetchPredictionHistory();
}

class MockHomeRepo implements HomeRepo {
  @override
  Future<WeatherModel> fetchWeatherData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    return const WeatherModel(
      temperature: 23.0,
      condition: 'Partly Cloudy',
      location: 'Mumbai, India',
      humidity: 65.0,
    );
  }

  @override
  Future<List<PredictionHistoryModel>> fetchPredictionHistory() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Convert first 3 items from MockDatabase to PredictionHistoryModel
    return MockDatabase.historyList.take(3).map((item) {
      return PredictionHistoryModel(
        id: item.id,
        cropName: item.cropName,
        date: item.date.split(' • ').first, // extract date portion
        recommendation: item.recommendedFertilizer ?? 'Pending',
        imageUrl: 'assets/images/${item.cropName.toLowerCase()}.png',
      );
    }).toList();
  }
}
