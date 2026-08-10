import 'package:flutter/material.dart';
import '../../predict/controllers/predict_controller.dart'; // for LocationOption
import '../models/fertilizer_request_model.dart';
import '../models/fertilizer_result_model.dart';
import '../repos/fertilizer_repo.dart';
import '../../../core/services/mock_database.dart';
import '../../../core/services/token_storage.dart';
import '../../history/models/history_item_model.dart';

class FertilizerController extends ChangeNotifier {
  final FertilizerRepo _fertilizerRepo;
  final String? userToken;

  FertilizerController({
    required FertilizerRepo fertilizerRepo,
    this.userToken,
  }) : _fertilizerRepo = fertilizerRepo;

  static const List<LocationOption> locationOptions = PredictController.locationOptions;
  static const List<String> seasonOptions = PredictController.seasonOptions;

  String _cropType = 'rice';
  String get cropType => _cropType;

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

  static List<String> _crops = [];
  List<String> get crops => _crops;

  static List<String> _fertilizers = [];
  List<String> get fertilizers => _fertilizers;

  static Future<void> prefetchCrops(FertilizerRepo repo) async {
    if (_crops.isNotEmpty) return;
    try {
      _crops = await repo.getCrops();
    } catch (_) {
      // Fail silently without any error or retry
    }
  }

  Future<void> fetchFertilizers() async {
    if (_fertilizers.isNotEmpty) return;
    try {
      _fertilizers = await _fertilizerRepo.getFertilizers();
      notifyListeners();
    } catch (_) {}
  }

  bool _isFetchingCrops = false;
  bool get isFetchingCrops => _isFetchingCrops;

  bool _isCropTypeLocked = false;
  bool get isCropTypeLocked => _isCropTypeLocked;

  FertilizerResultModel? _predictionResult;
  FertilizerResultModel? get predictionResult => _predictionResult;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void prefillFromCropResult({
    required String crop,
    required double n,
    required double p,
    required double k,
    required double phVal,
    required LocationOption location,
    required String season,
  }) {
    _cropType = crop;
    _nitrogen = n;
    _phosphorus = p;
    _potassium = k;
    _ph = phVal;
    _selectedLocation = location;
    _selectedSeason = season;
    _isCropTypeLocked = true;
  }

  void setCropType(String val) {
    _cropType = val;
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

  Future<void> fetchCrops() async {
    if (_crops.isNotEmpty) return;
    _isFetchingCrops = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _crops = await _fertilizerRepo.getCrops();
      if (!_isCropTypeLocked && _crops.isNotEmpty && !_crops.contains(_cropType)) {
        _cropType = _crops.first;
      }
    } catch (e) {
      _errorMessage = '$e'.replaceAll('Exception: ', '');
    } finally {
      _isFetchingCrops = false;
      notifyListeners();
    }
  }

  Future<void> predictFertilizer() async {
    _isLoading = true;
    _errorMessage = null;
    _predictionResult = null;
    notifyListeners();

    try {
      final request = FertilizerRequestModel(
        nitrogen: _nitrogen,
        phosphorus: _phosphorus,
        potassium: _potassium,
        ph: _ph,
        cropName: _cropType.toLowerCase(),
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        season: _selectedSeason,
      );
      var effectiveToken = userToken;
      if (effectiveToken == null || effectiveToken.isEmpty) {
        final saved = await TokenStorage.loadTokens();
        effectiveToken = saved?.access;
      }

      _predictionResult = await _fertilizerRepo.predictFertilizer(request, token: effectiveToken);
    } catch (e) {
      _errorMessage = '$e'.replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void saveToHistory() {
    if (_predictionResult == null) return;

    final existingIndex = MockDatabase.historyList.indexWhere(
      (item) => item.cropName.toLowerCase() == _cropType.toLowerCase() && item.recommendedFertilizer == null,
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
        date: '26 Jul 2026 • 07:16 PM',
        nitrogen: _nitrogen,
        phosphorus: _phosphorus,
        potassium: _potassium,
        ph: _ph,
        temperature: _predictionResult!.climateData.temperature,
        rainfall: _predictionResult!.climateData.rainfall,
        recommendedFertilizer: _predictionResult!.recommendedFertilizer,
        fertilizerDosage: _predictionResult!.dosage,
      );
      MockDatabase.addRecord(newItem);
    }
  }
}
