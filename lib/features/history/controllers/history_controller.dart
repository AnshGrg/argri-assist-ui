import 'package:flutter/material.dart';
import '../../../core/services/token_storage.dart';
import '../models/history_item_model.dart';
import '../repos/history_repo.dart';

class HistoryController extends ChangeNotifier {
  final HistoryRepo repo;
  final String? userToken;

  List<HistoryItemModel> _allHistory = [];
  List<HistoryItemModel> _filteredHistory = [];
  List<HistoryItemModel> get filteredHistory => _filteredHistory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  HistoryController({
    HistoryRepo? repo,
    this.userToken,
  }) : repo = repo ?? HttpHistoryRepo();

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    var effectiveToken = userToken;
    if (effectiveToken == null || effectiveToken.isEmpty) {
      final saved = await TokenStorage.loadTokens();
      effectiveToken = saved?.access;
    }

    try {
      _allHistory = await repo.getAllHistory(token: effectiveToken);
    } catch (_) {
      _allHistory = [];
    }

    _applyFilterAndSearch();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilterAndSearch();
    notifyListeners();
  }

  Future<HistoryItemModel?> fetchHistoryDetail(dynamic id) async {
    var effectiveToken = userToken;
    if (effectiveToken == null || effectiveToken.isEmpty) {
      final saved = await TokenStorage.loadTokens();
      effectiveToken = saved?.access;
    }
    try {
      return await repo.getCropHistoryDetail(id, token: effectiveToken);
    } catch (_) {
      return null;
    }
  }

  Future<HistoryItemModel?> fetchFertilizerHistoryDetail(dynamic id) async {
    var effectiveToken = userToken;
    if (effectiveToken == null || effectiveToken.isEmpty) {
      final saved = await TokenStorage.loadTokens();
      effectiveToken = saved?.access;
    }
    try {
      return await repo.getFertilizerHistoryDetail(id, token: effectiveToken);
    } catch (_) {
      return null;
    }
  }

  void _applyFilterAndSearch() {
    if (_searchQuery.isEmpty) {
      _filteredHistory = List.from(_allHistory);
    } else {
      _filteredHistory = _allHistory.where((item) {
        final query = _searchQuery.toLowerCase();
        final matchesCrop = item.cropName.toLowerCase().contains(query);
        final matchesFertilizer = item.recommendedFertilizer?.toLowerCase().contains(query) ?? false;
        return matchesCrop || matchesFertilizer;
      }).toList();
    }
  }
}
