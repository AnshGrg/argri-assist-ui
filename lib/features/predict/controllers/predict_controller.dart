import 'package:flutter/material.dart';
import '../models/predict_request_model.dart';
import '../models/prediction_result_model.dart';
import '../repos/predict_repo.dart';
import '../../../core/services/mock_database.dart';
import '../../history/models/history_item_model.dart';

class LocationOption {
  final String name;
  final double latitude;
  final double longitude;

  const LocationOption({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class PredictController extends ChangeNotifier {
  final PredictRepo _predictRepo;

  PredictController({required PredictRepo predictRepo}) : _predictRepo = predictRepo;

  static const List<LocationOption> locationOptions = [
    LocationOption(name: 'Kathmandu, Nepal', latitude: 27.7172, longitude: 85.3240),
    LocationOption(name: 'Pokhara, Nepal', latitude: 28.2096, longitude: 83.9856),
    LocationOption(name: 'Lalitpur, Nepal', latitude: 27.6744, longitude: 85.3244),
    LocationOption(name: 'Biratnagar, Nepal', latitude: 26.4525, longitude: 87.2718),
    LocationOption(name: 'Bharatpur, Nepal', latitude: 27.6796, longitude: 84.4334),
    LocationOption(name: 'Janakpur, Nepal', latitude: 26.7271, longitude: 85.9231),
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

  LocationOption _selectedLocation = locationOptions[0];
  LocationOption get selectedLocation => _selectedLocation;

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

  void setLocation(LocationOption loc) {
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
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        season: _selectedSeason,
      );
      _predictionResult = await _predictRepo.predictCrop(request);
      
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
