import 'package:flutter/material.dart';
import '../models/analytics_kpi_model.dart';
import '../models/climate_card_model.dart';
import '../models/crop_distribution_model.dart';
import '../models/fertilizer_demand_model.dart';
import '../models/soil_acidity_hotspot_model.dart';
import '../models/usage_trend_model.dart';
import '../repos/analytics_repo.dart';

class AnalyticsController extends ChangeNotifier {
  final AnalyticsRepo _httpRepo;
  final AnalyticsRepo _mockRepo;

  bool _useMockData = false;
  bool get useMockData => _useMockData;

  AnalyticsController({
    AnalyticsRepo? httpRepo,
    AnalyticsRepo? mockRepo,
    bool initialMock = false,
  })  : _httpRepo = httpRepo ?? HttpAnalyticsRepo(),
        _mockRepo = mockRepo ?? MockAnalyticsRepo(),
        _useMockData = initialMock;

  AnalyticsRepo get _activeRepo => _useMockData ? _mockRepo : _httpRepo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int? _errorCode;
  int? get errorCode => _errorCode;

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  AnalyticsKpiModel? _kpiData;
  AnalyticsKpiModel? get kpiData => _kpiData;

  List<RegionalFertilizerDemand> _fertilizerDemandList = [];
  List<RegionalFertilizerDemand> get fertilizerDemandList => _fertilizerDemandList;

  List<SoilAcidityHotspot> _acidityHotspotsList = [];
  List<SoilAcidityHotspot> get acidityHotspotsList => _acidityHotspotsList;

  List<SeasonalCropDistribution> _cropDistributionList = [];
  List<SeasonalCropDistribution> get cropDistributionList => _cropDistributionList;

  List<CropLeaderboardItem> _topCropsLeaderboard = [];
  List<CropLeaderboardItem> get topCropsLeaderboard => _topCropsLeaderboard;

  List<DailyUsageTrend> _usageTrendsList = [];
  List<DailyUsageTrend> get usageTrendsList => _usageTrendsList;

  List<ClimateCardModel> _climateDataList = [];
  List<ClimateCardModel> get climateDataList => _climateDataList;

  String _selectedCity = 'All';
  String get selectedCity => _selectedCity;

  String _selectedSeason = 'Monsoon';
  String get selectedSeason => _selectedSeason;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void toggleMockMode(bool value, {String? token}) {
    _useMockData = value;
    fetchAnalyticsData(token: token);
  }

  void setSelectedCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setSelectedSeason(String season) {
    _selectedSeason = season;
    notifyListeners();
  }

  Future<void> fetchAnalyticsData({String? token}) async {
    _isLoading = true;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();

    try {
      final kpis = await _activeRepo.fetchKpis(token);
      final fertilizers = await _activeRepo.fetchFertilizerDemand(token);
      final hotspots = await _activeRepo.fetchSoilAcidityHotspots(token);
      final cropDist = await _activeRepo.fetchCropDistribution(token);
      final fullCropResp = await _activeRepo.fetchFullCropDistributionResponse(token);
      final leaderboard = await _activeRepo.fetchCropLeaderboard(token);
      final trends = await _activeRepo.fetchUsageTrends(token);
      final climate = await _activeRepo.fetchClimateData(token);

      _kpiData = kpis;
      _fertilizerDemandList = fertilizers;
      _acidityHotspotsList = hotspots;
      _cropDistributionList = (fullCropResp != null && fullCropResp.seasonalDistribution.isNotEmpty)
          ? fullCropResp.seasonalDistribution
          : cropDist;
      _topCropsLeaderboard = (fullCropResp != null && fullCropResp.topCropsLeaderboard.isNotEmpty)
          ? fullCropResp.topCropsLeaderboard
          : leaderboard;
      _usageTrendsList = trends;
      _climateDataList = climate;

      if (_cropDistributionList.isNotEmpty &&
          !_cropDistributionList.any((e) => e.season.toLowerCase() == _selectedSeason.toLowerCase())) {
        _selectedSeason = _cropDistributionList.first.season;
      }
    } on AnalyticsAuthException catch (e) {
      _errorCode = e.statusCode;
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
