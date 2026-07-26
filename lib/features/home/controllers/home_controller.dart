import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../predict/controllers/predict_controller.dart';
import '../../predict_fertilizer/controllers/fertilizer_controller.dart';
import '../../predict_fertilizer/repos/fertilizer_repo.dart';
import '../models/weather_model.dart';
import '../models/prediction_history_model.dart';
import '../repos/home_repo.dart';

class HomeController extends ChangeNotifier {
  final HomeRepo _homeRepo;

  HomeController({required HomeRepo homeRepo}) : _homeRepo = homeRepo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  List<PredictionHistoryModel> _historyList = [];
  List<PredictionHistoryModel> get historyList => _historyList;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Prefetch crops in background silently
    FertilizerController.prefetchCrops(HttpFertilizerRepo());

    try {
      final weatherFuture = _homeRepo.fetchWeatherData();
      final historyFuture = _homeRepo.fetchPredictionHistory();

      final results = await Future.wait([weatherFuture, historyFuture]);

      _weather = results[0] as WeatherModel;
      _historyList = results[1] as List<PredictionHistoryModel>;

      // Attempt to access user GPS location
      final position = await LocationService.getCurrentPosition();
      if (position != null && _weather != null) {
        final latStr = position.latitude.toStringAsFixed(4);
        final lonStr = position.longitude.toStringAsFixed(4);
        
        // Find nearest matching preset location within 20km
        String locationName = 'Lat: $latStr, Lon: $lonStr';
        for (final loc in PredictController.locationOptions) {
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            loc.latitude,
            loc.longitude,
          );
          if (distance < 20000) {
            locationName = loc.name;
            break;
          }
        }

        _weather = WeatherModel(
          temperature: _weather!.temperature,
          condition: _weather!.condition,
          location: locationName,
          humidity: _weather!.humidity,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load dashboard details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
