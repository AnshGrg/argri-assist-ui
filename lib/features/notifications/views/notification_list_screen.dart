import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/notification_controller.dart';
import '../models/in_app_notification_model.dart';
import '../../news/views/news_detail_screen.dart';

class NotificationListScreen extends StatefulWidget {
  final NotificationController controller;

  const NotificationListScreen({
    super.key,
    required this.controller,
  });

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Unread

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Blur Filter Overlay
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
                child: Container(
                  color: AppColors.backgroundGreen.withValues(alpha: 0.70),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                _buildFilterTabs(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) {
                      if (widget.controller.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryGreen),
                        );
                      }

                      if (widget.controller.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.controller.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                              AppSizes.spaceM,
                              ElevatedButton(
                                onPressed: () => widget.controller.fetchNotifications(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final allList = widget.controller.notifications;
                      final filteredList = _selectedFilterIndex == 1
                          ? allList.where((n) => !n.isRead).toList()
                          : allList;

                      if (filteredList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedFilterIndex == 1
                                    ? Icons.mark_email_read_rounded
                                    : Icons.notifications_none_rounded,
                                size: 64,
                                color: AppColors.textLight,
                              ),
                              AppSizes.spaceM,
                              Text(
                                _selectedFilterIndex == 1
                                    ? 'No unread notifications'
                                    : 'No notifications available',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textMedium,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primaryGreen,
                        onRefresh: () => widget.controller.fetchNotifications(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSizes.l),
                          itemCount: filteredList.length,
                          separatorBuilder: (context, index) => AppSizes.spaceM,
                          itemBuilder: (context, index) {
                            final notification = filteredList[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          TextButton(
            onPressed: () => widget.controller.markAllAsRead(),
            child: const Text(
              'Read All',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.xs),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilterIndex = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedFilterIndex == 0 ? AppColors.primaryGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Center(
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedFilterIndex == 0 ? AppColors.white : AppColors.textMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilterIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedFilterIndex == 1 ? AppColors.primaryGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Center(
                    child: Text(
                      'Unread (${widget.controller.unreadCount})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedFilterIndex == 1 ? AppColors.white : AppColors.textMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(InAppNotificationModel notification) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.m),
      child: InkWell(
        onTap: () async {
          // Mark single as read
          if (!notification.isRead) {
            await widget.controller.markAsRead(notification.id);
          }

          // Deep-link to News Article detail screen if newsId present
          if (mounted && notification.newsId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(newsId: notification.newsId),
              ),
            );
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.s),
              decoration: BoxDecoration(
                color: notification.isRead
                    ? AppColors.lightGreen.withValues(alpha: 0.5)
                    : AppColors.primaryGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.newsCategory == 'Weather Alerts'
                    ? Icons.thunderstorm_outlined
                    : notification.newsCategory == 'Fertilizer'
                        ? Icons.shopping_bag_outlined
                        : notification.newsCategory == 'Pest & Disease'
                            ? Icons.bug_report_outlined
                            : Icons.notifications_active_outlined,
                color: AppColors.primaryGreen,
                size: AppSizes.iconMedium,
              ),
            ),
            AppSizes.spaceM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.notificationDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                          height: 1.3,
                        ),
                  ),
                  if (notification.newsCategory != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        notification.newsCategory!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSizes.s),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
