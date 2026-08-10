import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/in_app_notification_model.dart';

abstract class NotificationRepo {
  Future<int> getUnreadCount({String? token});
  Future<List<InAppNotificationModel>> getNotifications({String? token});
  Future<InAppNotificationModel> markAsRead(int notificationId, {String? token});
  Future<void> markAllAsRead({String? token});
}

class HttpNotificationRepo implements NotificationRepo {
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
  Future<int> getUnreadCount({String? token}) async {
    try {
      final response = await http
          .get(Uri.parse(ApiEndpoints.notificationsUnreadCount), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['unread_count'] is int
            ? decoded['unread_count'] as int
            : int.tryParse(decoded['unread_count']?.toString() ?? '0') ?? 0;
      }
      throw Exception('Failed to fetch unread count (${response.statusCode})');
    } catch (e) {
      throw Exception('NotificationRepo Error: $e');
    }
  }

  @override
  Future<List<InAppNotificationModel>> getNotifications({String? token}) async {
    try {
      final response = await http
          .get(Uri.parse(ApiEndpoints.notifications), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['notifications'] as List?) ??
                 (decoded['results'] as List?) ??
                 [];
        } else {
          list = [];
        }
        return list
            .map((item) => InAppNotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch notification list (${response.statusCode})');
    } catch (e) {
      throw Exception('NotificationRepo Error: $e');
    }
  }

  @override
  Future<InAppNotificationModel> markAsRead(int notificationId, {String? token}) async {
    try {
      final response = await http
          .patch(Uri.parse(ApiEndpoints.markNotificationRead(notificationId)), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final itemJson = decoded['notification'] as Map<String, dynamic>? ?? decoded;
        return InAppNotificationModel.fromJson(itemJson);
      }
      throw Exception('Failed to mark notification read (${response.statusCode})');
    } catch (e) {
      throw Exception('NotificationRepo Error: $e');
    }
  }

  @override
  Future<void> markAllAsRead({String? token}) async {
    try {
      final response = await http
          .patch(Uri.parse(ApiEndpoints.markAllNotificationsRead), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications read (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('NotificationRepo Error: $e');
    }
  }
}

class MockNotificationRepo implements NotificationRepo {
  late final List<InAppNotificationModel> _mockNotifications = [
    InAppNotificationModel(
      id: 45,
      title: 'New Advisory in Pest & Disease',
      message: 'Armyworm Outbreak Alert in Chitwan Maize Fields',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      newsId: 12,
      newsCategory: 'Pest & Disease',
    ),
    InAppNotificationModel(
      id: 46,
      title: 'Heavy Rainfall Warning',
      message: 'Monsoon Rainfall & Irrigation Advisory for Terai Region',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      newsId: 14,
      newsCategory: 'Weather Alerts',
    ),
    InAppNotificationModel(
      id: 47,
      title: 'Government Subsidy Update',
      message: 'Subsidized Urea & DAP Allocation Announced in Parsa',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      newsId: 15,
      newsCategory: 'Fertilizer',
    ),
  ];

  @override
  Future<int> getUnreadCount({String? token}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockNotifications.where((n) => !n.isRead).length;
  }

  @override
  Future<List<InAppNotificationModel>> getNotifications({String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockNotifications);
  }

  @override
  Future<InAppNotificationModel> markAsRead(int notificationId, {String? token}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final updated = _mockNotifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      _mockNotifications[index] = updated;
      return updated;
    }
    throw Exception('Notification not found');
  }

  @override
  Future<void> markAllAsRead({String? token}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _mockNotifications.length; i++) {
      _mockNotifications[i] = _mockNotifications[i].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
    }
  }
}
