import 'package:flutter/material.dart';
import '../models/history_item_model.dart';
import '../../../core/services/mock_database.dart';

class HistoryController extends ChangeNotifier {
  List<HistoryItemModel> _filteredHistory = [];
  List<HistoryItemModel> get filteredHistory => _filteredHistory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void loadHistory() {
    _isLoading = true;
    notifyListeners();

    _applyFilterAndSearch();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilterAndSearch();
    notifyListeners();
  }

  void _applyFilterAndSearch() {
    if (_searchQuery.isEmpty) {
      _filteredHistory = List.from(MockDatabase.historyList);
    } else {
      _filteredHistory = MockDatabase.historyList.where((item) {
        final query = _searchQuery.toLowerCase();
        final matchesCrop = item.cropName.toLowerCase().contains(query);
        final matchesFertilizer = item.recommendedFertilizer?.toLowerCase().contains(query) ?? false;
        return matchesCrop || matchesFertilizer;
      }).toList();
    }
  }
}
