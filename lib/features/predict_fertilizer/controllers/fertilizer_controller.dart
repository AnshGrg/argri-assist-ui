import 'package:flutter/material.dart';
import '../models/fertilizer_request_model.dart';
import '../models/fertilizer_result_model.dart';
import '../repos/fertilizer_repo.dart';
import '../../../core/services/mock_database.dart';
import '../../history/models/history_item_model.dart';

class FertilizerController extends ChangeNotifier {
  final FertilizerRepo _fertilizerRepo;

  FertilizerController({required FertilizerRepo fertilizerRepo}) : _fertilizerRepo = fertilizerRepo;

  String _cropType = 'Maize';
  String get cropType => _cropType;

  String _soilType = 'Loamy';
  String get soilType => _soilType;

  double _nitrogen = 120.0;
  double get nitrogen => _nitrogen;

  double _phosphorus = 60.0;
  double get phosphorus => _phosphorus;

  double _potassium = 80.0;
  double get potassium => _potassium;

  double _ph = 6.7;
  double get ph => _ph;

  double _temperature = 27.6;
  double get temperature => _temperature;

  double _humidity = 65.0;
  double get humidity => _humidity;

  double _rainfall = 82.4;
  double get rainfall => _rainfall;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAutoFetchingTemperature = false;
  bool get isAutoFetchingTemperature => _isAutoFetchingTemperature;

  bool _isAutoFetchingHumidity = false;
  bool get isAutoFetchingHumidity => _isAutoFetchingHumidity;

  bool _isAutoFetchingRainfall = false;
  bool get isAutoFetchingRainfall => _isAutoFetchingRainfall;

  FertilizerResultModel? _predictionResult;
  FertilizerResultModel? get predictionResult => _predictionResult;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void prefillFromCropResult(String crop, double n, double p, double k, double phVal, double temp, double rain) {
    _cropType = crop;
    _nitrogen = n;
    _phosphorus = p;
    _potassium = k;
    _ph = phVal;
    _temperature = temp;
    _rainfall = rain;
  }

  void setCropType(String val) {
    _cropType = val;
    notifyListeners();
  }

  void setSoilType(String val) {
    _soilType = val;
    notifyListeners();
  }

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
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _temperature = 27.6;
    _isAutoFetchingTemperature = false;
    notifyListeners();
  }

  Future<void> autoFetchHumidity() async {
    _isAutoFetchingHumidity = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _humidity = 65.0;
    _isAutoFetchingHumidity = false;
    notifyListeners();
  }

  Future<void> autoFetchRainfall() async {
    _isAutoFetchingRainfall = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _rainfall = 82.4;
    _isAutoFetchingRainfall = false;
    notifyListeners();
  }

  Future<void> predictFertilizer() async {
    _isLoading = true;
    _errorMessage = null;
    _predictionResult = null;
    notifyListeners();

    try {
      final request = FertilizerRequestModel(
        cropType: _cropType,
        soilType: _soilType,
        nitrogen: _nitrogen,
        phosphorus: _phosphorus,
        potassium: _potassium,
        ph: _ph,
        temperature: _temperature,
        humidity: _humidity,
        rainfall: _rainfall,
      );
      _predictionResult = await _fertilizerRepo.predictFertilizer(request);
    } catch (e) {
      _errorMessage = 'Failed to fetch fertilizer prediction: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void saveToHistory() {
    if (_predictionResult == null) return;

    // Check if there is an existing history item for this crop prediction we just made, and attach the fertilizer details to it.
    // If not, we can create a new record.
    final existingIndex = MockDatabase.historyList.indexWhere(
      (item) => item.cropName == _cropType && item.recommendedFertilizer == null,
    );

    if (existingIndex != -1) {
      final item = MockDatabase.historyList[existingIndex];
      MockDatabase.historyList[existingIndex] = item.copyWith(
        recommendedFertilizer: _predictionResult!.recommendedFertilizer,
        fertilizerDosage: _predictionResult!.dosage,
      );
    } else {
      final newItem = HistoryItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cropName: _cropType,
        confidenceScore: 0.92,
        date: '25 Jul 2026 • 02:05 PM',
        nitrogen: _nitrogen,
        phosphorus: _phosphorus,
        potassium: _potassium,
        ph: _ph,
        temperature: _temperature,
        rainfall: _rainfall,
        recommendedFertilizer: _predictionResult!.recommendedFertilizer,
        fertilizerDosage: _predictionResult!.dosage,
      );
      MockDatabase.addRecord(newItem);
    }
  }
}
