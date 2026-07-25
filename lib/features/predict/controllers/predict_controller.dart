import 'package:flutter/material.dart';
import '../models/predict_request_model.dart';
import '../models/prediction_result_model.dart';
import '../repos/predict_repo.dart';
import '../../../core/services/mock_database.dart';
import '../../history/models/history_item_model.dart';

class PredictController extends ChangeNotifier {
  final PredictRepo _predictRepo;

  PredictController({required PredictRepo predictRepo}) : _predictRepo = predictRepo;

  // Form states
  double _nitrogen = 120.0;
  double get nitrogen => _nitrogen;

  double _phosphorus = 60.0;
  double get phosphorus => _phosphorus;

  double _potassium = 80.0;
  double get potassium => _potassium;

  double _temperature = 27.6;
  double get temperature => _temperature;

  double _rainfall = 82.4;
  double get rainfall => _rainfall;

  double _ph = 6.7;
  double get ph => _ph;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAutoFetchingTemperature = false;
  bool get isAutoFetchingTemperature => _isAutoFetchingTemperature;

  bool _isAutoFetchingRainfall = false;
  bool get isAutoFetchingRainfall => _isAutoFetchingRainfall;

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

  Future<void> autoFetchTemperature() async {
    _isAutoFetchingTemperature = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API fetch delay
      await Future.delayed(const Duration(milliseconds: 800));
      _temperature = 27.6; // Mock auto-fetched value
    } catch (e) {
      _errorMessage = 'Failed to fetch temperature: $e';
    } finally {
      _isAutoFetchingTemperature = false;
      notifyListeners();
    }
  }

  Future<void> autoFetchRainfall() async {
    _isAutoFetchingRainfall = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API fetch delay
      await Future.delayed(const Duration(milliseconds: 800));
      _rainfall = 82.4; // Mock auto-fetched value
    } catch (e) {
      _errorMessage = 'Failed to fetch rainfall: $e';
    } finally {
      _isAutoFetchingRainfall = false;
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
        temperature: _temperature,
        rainfall: _rainfall,
        ph: _ph,
      );
      _predictionResult = await _predictRepo.predictCrop(request);
      
      if (_predictionResult != null) {
        final newHistoryItem = HistoryItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          cropName: _predictionResult!.cropName,
          confidenceScore: _predictionResult!.confidenceScore,
          date: '25 Jul 2026 • 02:00 PM', // Simulating current local time
          nitrogen: _nitrogen,
          phosphorus: _phosphorus,
          potassium: _potassium,
          ph: _ph,
          temperature: _temperature,
          rainfall: _rainfall,
        );
        MockDatabase.addRecord(newHistoryItem);
      }
    } catch (e) {
      _errorMessage = 'Failed to perform crop prediction: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
