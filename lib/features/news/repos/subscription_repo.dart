import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/subscription_model.dart';
import '../models/news_category_model.dart';

abstract class SubscriptionRepo {
  Future<List<SubscriptionModel>> getSubscriptions({String? token});
  Future<SubscriptionModel> subscribe(int categoryId, {String? token});
  Future<void> unsubscribe(int subscriptionId, {String? token});
}

class HttpSubscriptionRepo implements SubscriptionRepo {
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
  Future<List<SubscriptionModel>> getSubscriptions({String? token}) async {
    try {
      final response = await http
          .get(Uri.parse(ApiEndpoints.subscriptions), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded is Map<String, dynamic>
            ? (decoded['subscriptions'] as List? ?? [])
            : (decoded as List);
        return list.map((item) => SubscriptionModel.fromJson(item)).toList();
      }
      throw Exception('Failed to fetch subscriptions (${response.statusCode})');
    } catch (e) {
      throw Exception('SubscriptionRepo Error: $e');
    }
  }

  @override
  Future<SubscriptionModel> subscribe(int categoryId, {String? token}) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoints.subscriptions),
            headers: _headers(token),
            body: jsonEncode({'category_id': categoryId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final subJson = decoded['subscription'] as Map<String, dynamic>? ?? decoded;
        return SubscriptionModel.fromJson(subJson);
      } else if (response.statusCode == 400) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('detail')) {
          throw Exception(decoded['detail']);
        }
        throw Exception('You are already subscribed to this category.');
      }
      throw Exception('Failed to subscribe (${response.statusCode})');
    } catch (e) {
      if (e.toString().startsWith('Exception: ')) rethrow;
      throw Exception('SubscriptionRepo Error: $e');
    }
  }

  @override
  Future<void> unsubscribe(int subscriptionId, {String? token}) async {
    try {
      final response = await http
          .delete(Uri.parse(ApiEndpoints.unsubscribeTopic(subscriptionId)), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('Subscription not found.');
        }
        throw Exception('Failed to unsubscribe (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('SubscriptionRepo Error: $e');
    }
  }
}

class MockSubscriptionRepo implements SubscriptionRepo {
  final List<SubscriptionModel> _mockSubscriptions = [
    SubscriptionModel(
      id: 1,
      category: const NewsCategoryModel(id: 4, name: 'Pest & Disease', description: 'Pest outbreak alerts and treatment steps'),
      categoryId: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    SubscriptionModel(
      id: 2,
      category: const NewsCategoryModel(id: 1, name: 'Weather Alerts', description: 'Severe weather notices and rainfall forecasts'),
      categoryId: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<List<SubscriptionModel>> getSubscriptions({String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockSubscriptions);
  }

  @override
  Future<SubscriptionModel> subscribe(int categoryId, {String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_mockSubscriptions.any((s) => s.category.id == categoryId)) {
      throw Exception('You are already subscribed to this category.');
    }
    final mockCat = NewsCategoryModel(
      id: categoryId,
      name: categoryId == 2
          ? 'Crop Management'
          : categoryId == 3
              ? 'Fertilizer'
              : 'Government Schemes',
      description: 'Category description',
    );
    final newSub = SubscriptionModel(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      category: mockCat,
      categoryId: categoryId,
      createdAt: DateTime.now(),
    );
    _mockSubscriptions.add(newSub);
    return newSub;
  }

  @override
  Future<void> unsubscribe(int subscriptionId, {String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockSubscriptions.removeWhere((s) => s.id == subscriptionId);
  }
}
