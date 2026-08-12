import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
  int _selectedFilterIndex = 0; // 0: All, 1: Unread, 2: Read

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.fetchNotifications();
    });
  }

  String _formatTimeAgo(DateTime? dt) {
    if (dt == null) return 'Recently';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _getCategoryEmoji(String? catName) {
    if (catName == null || catName.isEmpty) return '🔔';
    final lower = catName.toLowerCase();
    if (lower.contains('crop')) return '🌾';
    if (lower.contains('fertilizer')) return '🧪';
    if (lower.contains('pest') || lower.contains('disease')) return '🐛';
    if (lower.contains('weather')) return '🌦️';
    if (lower.contains('market') || lower.contains('price')) return '📈';
    return '🍃';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF7EE),
      body: SafeArea(
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
                  final unreadCount = allList.where((n) => !n.isRead).length;

                  final filteredList = _selectedFilterIndex == 1
                      ? allList.where((n) => !n.isRead).toList()
                      : _selectedFilterIndex == 2
                          ? allList.where((n) => n.isRead).toList()
                          : allList;

                  return RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: () => widget.controller.fetchNotifications(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Text(
                            '${allList.length} notifications · $unreadCount unread',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5B8C67),
                            ),
                          ),
                        ),
                        Expanded(
                          child: filteredList.isEmpty
                              ? Center(
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
                                            : _selectedFilterIndex == 2
                                                ? 'No read notifications'
                                                : 'No notifications available',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: AppColors.textMedium,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  itemCount: filteredList.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final notification = filteredList[index];
                                    return _buildNotificationCard(notification);
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
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
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final allList = widget.controller.notifications;
        final totalCount = allList.length;
        final unreadCount = allList.where((n) => !n.isRead).length;
        final readCount = allList.where((n) => n.isRead).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterTabItem(
                  label: 'All',
                  count: totalCount,
                  isSelected: _selectedFilterIndex == 0,
                  onTap: () => setState(() => _selectedFilterIndex = 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterTabItem(
                  label: 'Unread',
                  count: unreadCount,
                  isSelected: _selectedFilterIndex == 1,
                  onTap: () => setState(() => _selectedFilterIndex = 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterTabItem(
                  label: 'Read',
                  count: readCount,
                  isSelected: _selectedFilterIndex == 2,
                  onTap: () => setState(() => _selectedFilterIndex = 2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTabItem({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C6B30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2C6B30) : const Color(0xFFE0EBE0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2C6B30).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textDark,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFDDF2DF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF2C6B30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(InAppNotificationModel notification) {
    final catEmoji = _getCategoryEmoji(notification.newsCategory);
    final categoryText = notification.newsCategory ?? 'General';
    final timeText = _formatTimeAgo(notification.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE6F2E6), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (!notification.isRead) {
                await widget.controller.markAsRead(notification.id);
              }
              if (mounted && notification.newsId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailScreen(newsId: notification.newsId),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF2DF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$catEmoji $categoryText',
                          style: const TextStyle(
                            color: Color(0xFF2C6B30),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!notification.isRead) ...[
                        Container(
                          margin: const EdgeInsets.only(top: 5, right: 6),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2C6B30),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMedium,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8E9BAE),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
