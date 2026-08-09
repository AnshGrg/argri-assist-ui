import 'dart:async';
import 'package:flutter/material.dart';
import '../models/in_app_notification_model.dart';
import '../repos/notification_repo.dart';

class NotificationController extends ChangeNotifier with WidgetsBindingObserver {
  final NotificationRepo notificationRepo;
  final String? userToken;

  int _unreadCount = 0;
  List<InAppNotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;
  bool _isAppInForeground = true;

  NotificationController({
    required this.notificationRepo,
    this.userToken,
  }) {
    WidgetsBinding.instance.addObserver(this);
  }

  int get unreadCount => _unreadCount;
  List<InAppNotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      fetchUnreadCount();
      _startPeriodicTimer();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _isAppInForeground = false;
      _stopPeriodicTimer();
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    _startPeriodicTimer(interval: interval);
    fetchUnreadCount();
  }

  void _startPeriodicTimer({Duration interval = const Duration(seconds: 30)}) {
    _stopPeriodicTimer();
    _pollingTimer = Timer.periodic(interval, (_) {
      if (_isAppInForeground) {
        fetchUnreadCount();
      }
    });
  }

  void _stopPeriodicTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await notificationRepo.getUnreadCount(token: userToken);
      if (_unreadCount != count) {
        _unreadCount = count;
        notifyListeners();
        // If count changed or has unread, update full list if loaded
        if (_notifications.isNotEmpty) {
          fetchNotifications(showLoading: false);
        }
      }
    } catch (_) {
      // Periodic check should fail silently without disturbing UI state
    }
  }

  Future<void> fetchNotifications({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _notifications = await notificationRepo.getNotifications(token: userToken);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final updated = await notificationRepo.markAsRead(notificationId, token: userToken);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = updated;
      } else {
        fetchNotifications(showLoading: false);
      }
      if (_unreadCount > 0) {
        _unreadCount--;
      }
      notifyListeners();
    } catch (e) {
      // Optimistic update fallback
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true, readAt: DateTime.now());
        if (_unreadCount > 0) _unreadCount--;
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await notificationRepo.markAllAsRead(token: userToken);
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPeriodicTimer();
    super.dispose();
  }
}
