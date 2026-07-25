import 'package:flutter/material.dart';
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

    try {
      final weatherFuture = _homeRepo.fetchWeatherData();
      final historyFuture = _homeRepo.fetchPredictionHistory();

      final results = await Future.wait([weatherFuture, historyFuture]);

      _weather = results[0] as WeatherModel;
      _historyList = results[1] as List<PredictionHistoryModel>;
    } catch (e) {
      _errorMessage = 'Failed to load dashboard details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
