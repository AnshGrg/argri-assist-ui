import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/mock_database.dart';
import '../models/history_item_model.dart';

abstract class HistoryRepo {
  Future<List<HistoryItemModel>> getCropHistory({String? token});
  Future<List<HistoryItemModel>> getFertilizerHistory({String? token});
  Future<List<HistoryItemModel>> getAllHistory({String? token});
  Future<HistoryItemModel?> getCropHistoryDetail(dynamic id, {String? token});
  Future<HistoryItemModel?> getFertilizerHistoryDetail(dynamic id, {String? token});
}

class HttpHistoryRepo implements HistoryRepo {
  Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  @override
  Future<List<HistoryItemModel>> getCropHistory({String? token}) async {
    final uri = Uri.parse(ApiEndpoints.cropHistory);

    try {
      final response = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded is Map<String, dynamic>
            ? (decoded['results'] as List? ?? decoded['history'] as List? ?? [])
            : (decoded as List);
        return list.map((item) => HistoryItemModel.fromJson(item as Map<String, dynamic>, type: HistoryType.crop)).toList();
      }
    } catch (_) {}

    try {
      final response = await http
          .get(uri, headers: {'ngrok-skip-browser-warning': 'true'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded is Map<String, dynamic>
            ? (decoded['results'] as List? ?? decoded['history'] as List? ?? [])
            : (decoded as List);
        return list.map((item) => HistoryItemModel.fromJson(item as Map<String, dynamic>, type: HistoryType.crop)).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<List<HistoryItemModel>> getFertilizerHistory({String? token}) async {
    final uri = Uri.parse(ApiEndpoints.fertilizerHistory);

    try {
      final response = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded is Map<String, dynamic>
            ? (decoded['results'] as List? ?? decoded['history'] as List? ?? [])
            : (decoded as List);
        return list.map((item) => HistoryItemModel.fromJson(item as Map<String, dynamic>, type: HistoryType.fertilizer)).toList();
      }
    } catch (_) {}

    try {
      final response = await http
          .get(uri, headers: {'ngrok-skip-browser-warning': 'true'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded is Map<String, dynamic>
            ? (decoded['results'] as List? ?? decoded['history'] as List? ?? [])
            : (decoded as List);
        return list.map((item) => HistoryItemModel.fromJson(item as Map<String, dynamic>, type: HistoryType.fertilizer)).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<List<HistoryItemModel>> getAllHistory({String? token}) async {
    final results = await Future.wait([
      getCropHistory(token: token),
      getFertilizerHistory(token: token),
    ]);

    final cropItems = results[0];
    final fertilizerItems = results[1];

    final combined = <HistoryItemModel>[...cropItems, ...fertilizerItems];

    // Sort by createdAt / date descending (newest first)
    combined.sort((a, b) {
      if (a.createdAt != null && b.createdAt != null) {
        return b.createdAt!.compareTo(a.createdAt!);
      }
      return 0;
    });

    return combined;
  }

  @override
  Future<HistoryItemModel?> getCropHistoryDetail(dynamic id, {String? token}) async {
    final uri = Uri.parse(ApiEndpoints.cropHistoryDetail(id));

    try {
      final response = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final itemJson = decoded['history'] as Map<String, dynamic>? ?? decoded;
        return HistoryItemModel.fromJson(itemJson, type: HistoryType.crop);
      }
    } catch (_) {}

    try {
      final response = await http
          .get(uri, headers: {'ngrok-skip-browser-warning': 'true'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final itemJson = decoded['history'] as Map<String, dynamic>? ?? decoded;
        return HistoryItemModel.fromJson(itemJson, type: HistoryType.crop);
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<HistoryItemModel?> getFertilizerHistoryDetail(dynamic id, {String? token}) async {
    final uri = Uri.parse(ApiEndpoints.fertilizerHistoryDetail(id));

    try {
      final response = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final itemJson = decoded['history'] as Map<String, dynamic>? ?? decoded;
        return HistoryItemModel.fromJson(itemJson, type: HistoryType.fertilizer);
      }
    } catch (_) {}

    try {
      final response = await http
          .get(uri, headers: {'ngrok-skip-browser-warning': 'true'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final itemJson = decoded['history'] as Map<String, dynamic>? ?? decoded;
        return HistoryItemModel.fromJson(itemJson, type: HistoryType.fertilizer);
      }
    } catch (_) {}

    return null;
  }
}

class MockHistoryRepo implements HistoryRepo {
  @override
  Future<List<HistoryItemModel>> getCropHistory({String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(MockDatabase.historyList);
  }

  @override
  Future<List<HistoryItemModel>> getFertilizerHistory({String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(MockDatabase.historyList.where((e) => e.recommendedFertilizer != null));
  }

  @override
  Future<List<HistoryItemModel>> getAllHistory({String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(MockDatabase.historyList);
  }

  @override
  Future<HistoryItemModel?> getCropHistoryDetail(dynamic id, {String? token}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDatabase.historyList.firstWhere(
      (item) => item.id == id.toString(),
      orElse: () => MockDatabase.historyList.first,
    );
  }

  @override
  Future<HistoryItemModel?> getFertilizerHistoryDetail(dynamic id, {String? token}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDatabase.historyList.firstWhere(
      (item) => item.id == id.toString() && item.recommendedFertilizer != null,
      orElse: () => MockDatabase.historyList.first,
    );
  }
}
