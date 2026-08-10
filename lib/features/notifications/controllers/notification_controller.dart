import 'dart:async';
import 'package:flutter/material.dart';
import '../models/in_app_notification_model.dart';
import '../repos/notification_repo.dart';
import '../../../core/services/token_storage.dart';

class NotificationController extends ChangeNotifier with WidgetsBindingObserver {
  final NotificationRepo notificationRepo;
  final String? userToken;

  int _unreadCount = 0;
  int _previousUnreadCount = 0;
  List<InAppNotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;
  bool _isAppInForeground = true;

  /// Callback invoked when new unread notifications are detected.
  /// Receives the current unread count as an argument.
  void Function(int newUnreadCount)? onNewNotifications;

  NotificationController({
    required this.notificationRepo,
    this.userToken,
    this.onNewNotifications,
  }) {
    WidgetsBinding.instance.addObserver(this);
  }

  int get unreadCount => _unreadCount;
  List<InAppNotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<String?> _getEffectiveToken() async {
    if (userToken != null && userToken!.isNotEmpty) {
      return userToken;
    }
    final saved = await TokenStorage.loadTokens();
    return saved?.access;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      _getEffectiveToken().then((token) {
        if (token != null && token.isNotEmpty && _isAppInForeground) {
          fetchUnreadCount();
          _startPeriodicTimer();
        }
      });
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached || state == AppLifecycleState.inactive) {
      _isAppInForeground = false;
      _stopPeriodicTimer();
    }
  }

  Future<void> startPolling({Duration interval = const Duration(seconds: 90)}) async {
    final token = await _getEffectiveToken();
    if (token != null && token.isNotEmpty) {
      _startPeriodicTimer(interval: interval);
      fetchUnreadCount();
    } else {
      _stopPeriodicTimer();
    }
  }

  void _startPeriodicTimer({Duration interval = const Duration(seconds: 90)}) {
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
    final token = await _getEffectiveToken();
    if (token == null || token.isEmpty) {
      _stopPeriodicTimer();
      if (_unreadCount != 0) {
        _unreadCount = 0;
        notifyListeners();
      }
      return;
    }

    try {
      final count = await notificationRepo.getUnreadCount(token: token);
      if (_unreadCount != count) {
        _previousUnreadCount = _unreadCount;
        _unreadCount = count;
        notifyListeners();

        // Fire callback if count increased (new notifications arrived)
        if (count > _previousUnreadCount && _previousUnreadCount >= 0 && onNewNotifications != null) {
          onNewNotifications!(count);
        }

        // If count changed, update full list if it was previously loaded
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
      final token = await _getEffectiveToken();
      _notifications = await notificationRepo.getNotifications(token: token);
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
      final token = await _getEffectiveToken();
      final updated = await notificationRepo.markAsRead(notificationId, token: token);
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
      final token = await _getEffectiveToken();
      await notificationRepo.markAllAsRead(token: token);
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
