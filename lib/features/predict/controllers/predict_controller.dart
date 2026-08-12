import 'package:flutter/material.dart';
import '../models/predict_request_model.dart';
import '../models/prediction_result_model.dart';
import '../repos/predict_repo.dart';
import '../../../core/services/mock_database.dart';
import '../../../core/services/token_storage.dart';
import '../../history/models/history_item_model.dart';

class LocationOption {
  final String name;
  final String district;
  final double latitude;
  final double longitude;

  const LocationOption({
    required this.name,
    required this.district,
    required this.latitude,
    required this.longitude,
  });

  String get displayName => '$name, $district';
}

class PredictController extends ChangeNotifier {
  final PredictRepo _predictRepo;
  final String? userToken;

  PredictController({
    required PredictRepo predictRepo,
    this.userToken,
  }) : _predictRepo = predictRepo;

  static const List<LocationOption> locationOptions = [
    LocationOption(name: 'Bharatpur', district: 'Chitwan', latitude: 27.6833, longitude: 84.4333),
    LocationOption(name: 'Jomsom', district: 'Mustang', latitude: 28.7808, longitude: 83.7314),
    LocationOption(name: 'Jumla', district: 'Jumla', latitude: 29.2747, longitude: 82.1838),
    LocationOption(name: 'Putalibazar', district: 'Syangja', latitude: 28.0955, longitude: 83.8746),
    LocationOption(name: 'Dhankuta', district: 'Dhankuta', latitude: 26.9833, longitude: 87.3333),
    LocationOption(name: 'Biratnagar', district: 'Morang', latitude: 26.4551, longitude: 87.2701),
    LocationOption(name: 'Birtamod', district: 'Jhapa', latitude: 26.6380, longitude: 87.9930),
    LocationOption(name: 'Tamghas', district: 'Gulmi', latitude: 28.0625, longitude: 83.2492),
    LocationOption(name: 'Pokhara', district: 'Kaski', latitude: 28.2096, longitude: 83.9856),
    LocationOption(name: 'Nepalgunj', district: 'Banke', latitude: 28.0500, longitude: 81.6167),
    LocationOption(name: 'Gulariya', district: 'Bardiya', latitude: 28.2333, longitude: 81.3333),
    LocationOption(name: 'Banepa', district: 'Kavrepalanchok', latitude: 27.6298, longitude: 85.5214),
    LocationOption(name: 'Ghorahi', district: 'Dang', latitude: 28.0432, longitude: 82.4863),
    LocationOption(name: 'Malangwa', district: 'Sarlahi', latitude: 26.8667, longitude: 85.5667),
    LocationOption(name: 'Rajbiraj', district: 'Saptari', latitude: 26.5333, longitude: 86.7333),
  ];

  static const List<String> seasonOptions = ['Monsoon', 'Winter', 'Spring', 'Summer'];

  // Form states
  double _nitrogen = 90.0;
  double get nitrogen => _nitrogen;

  double _phosphorus = 42.0;
  double get phosphorus => _phosphorus;

  double _potassium = 43.0;
  double get potassium => _potassium;

  double _ph = 6.5;
  double get ph => _ph;

  LocationOption? _selectedLocation;
  LocationOption? get selectedLocation => _selectedLocation;

  String _selectedSeason = 'Monsoon';
  String get selectedSeason => _selectedSeason;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PredictionResultModel? _predictionResult;
  PredictionResultModel? get predictionResult => _predictionResult;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setNitrogen(String val) {
    _nitrogen = double.tryParse(val) ?? 0.0;
  }

  void setPhosphorus(String val) {
    _phosphorus = double.tryParse(val) ?? 0.0;
  }

  void setPotassium(String val) {
    _potassium = double.tryParse(val) ?? 0.0;
  }

  void setPh(String val) {
    _ph = double.tryParse(val) ?? 0.0;
    notifyListeners();
  }

  void setLocation(LocationOption? loc) {
    _selectedLocation = loc;
    notifyListeners();
  }

  void setSeason(String season) {
    if (seasonOptions.contains(season)) {
      _selectedSeason = season;
      notifyListeners();
    }
  }

  Future<void> predictCrop() async {
    if (_selectedLocation == null) {
      _errorMessage = 'Please select a location.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _predictionResult = null;
    notifyListeners();

    try {
      final request = PredictRequestModel(
        nitrogen: _nitrogen,
        phosphorus: _phosphorus,
        potassium: _potassium,
        ph: _ph,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        season: _selectedSeason,
      );
      var effectiveToken = userToken;
      if (effectiveToken == null || effectiveToken.isEmpty) {
        final saved = await TokenStorage.loadTokens();
        effectiveToken = saved?.access;
      }
      _predictionResult = await _predictRepo.predictCrop(request, token: effectiveToken);
      
      if (_predictionResult != null) {
        final newHistoryItem = HistoryItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          cropName: _predictionResult!.cropName,
          confidenceScore: _predictionResult!.confidenceScore,
          date: '26 Jul 2026 • 07:15 PM', // Simulating current local time
          nitrogen: _nitrogen,
          phosphorus: _phosphorus,
          potassium: _potassium,
          ph: _ph,
          temperature: _predictionResult!.climateData.temperature,
          rainfall: _predictionResult!.climateData.rainfall,
        );
        MockDatabase.addRecord(newHistoryItem);
      }
    } catch (e) {
      _errorMessage = '$e'.replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
