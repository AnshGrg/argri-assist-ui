import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/home_controller.dart';
import '../models/prediction_history_model.dart';
import '../models/weather_model.dart';
import '../../predict/views/predict_crop_screen.dart';
import '../../predict/controllers/predict_controller.dart';
import '../../predict/repos/predict_repo.dart';
import '../../predict_fertilizer/views/predict_fertilizer_screen.dart';
import '../../predict_fertilizer/controllers/fertilizer_controller.dart';
import '../../predict_fertilizer/repos/fertilizer_repo.dart';
import '../../history/views/history_screen.dart';
import '../../history/controllers/history_controller.dart';
import '../../history/views/prediction_details_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/repos/auth_repo.dart';
import '../../../core/services/mock_database.dart';
import '../../notifications/controllers/notification_controller.dart';
import '../../notifications/repos/notification_repo.dart';
import '../../notifications/views/notification_list_screen.dart';
import '../../news/controllers/news_controller.dart';
import '../../news/repos/news_repo.dart';
import '../../news/repos/subscription_repo.dart';
import '../../news/views/news_feed_screen.dart';
import '../../../core/utils/string_utils.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final HomeController controller;
  final NotificationController? notificationController;
  final NewsController? newsController;
  final AuthController? authController;

  const HomeScreen({
    super.key,
    required this.controller,
    this.notificationController,
    this.newsController,
    this.authController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentNavigationIndex = 0;
  late final NotificationController _notificationController;
  late final NewsController _newsController;
  late final AuthController _authController;

  String? get _userToken => _authController.tokens?.access;


  String get _greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authController =
        widget.authController ?? AuthController(authRepo: HttpAuthRepo());
    _notificationController =
        widget.notificationController ??
        NotificationController(
          notificationRepo: HttpNotificationRepo(),
          userToken: _userToken,
          onNewNotifications: _showNewNotificationToast,
        );
    _newsController =
        widget.newsController ??
        NewsController(
          newsRepo: HttpNewsRepo(),
          subscriptionRepo: HttpSubscriptionRepo(),
          userToken: _userToken,
        );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.controller.loadDashboardData();
      _notificationController.startPolling(
        interval: const Duration(seconds: 90),
      );
      await _authController.checkAndValidateSavedSession();
    });
    _authController.addListener(_onAuthChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authController.checkAndValidateSavedSession();
    }
  }

  void _showNewNotificationToast(int unreadCount) {
    if (!mounted) return;
    final message = unreadCount == 1
        ? 'You have 1 unread notification'
        : 'You have $unreadCount unread notifications';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    NotificationListScreen(controller: _notificationController),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
      if (_authController.isLoggedIn) {
        _notificationController.startPolling(
          interval: const Duration(seconds: 90),
        );
      } else {
        _notificationController.fetchUnreadCount();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authController.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF7EE),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBody() {
    switch (_currentNavigationIndex) {
      case 1:
        return HistoryScreen(
          controller: HistoryController(userToken: _userToken),
        );
      case 2:
        return ProfileScreen(authController: _authController);
      case 0:
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SafeArea(
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
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: widget.controller.loadDashboardData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final weather = widget.controller.weather;
          final history = widget.controller.historyList;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 18),
                if (weather != null) _buildWeatherCard(context, weather),
                const SizedBox(height: 24),
                _buildPredictionSection(context),
                const SizedBox(height: 24),
                if (history.isNotEmpty) ...[
                  _buildRecentActivity(context, history),
                  const SizedBox(height: 24),
                ],
                _buildNewsCardBanner(context),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final rawUsername = _authController.tokens?.username ?? 'Farmer';
    final formattedUsername = StringUtils.formatUsername(rawUsername);
    final username = formattedUsername.isNotEmpty ? formattedUsername : 'Farmer';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greetingText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AnimatedBuilder(
          animation: _notificationController,
          builder: (context, _) {
            final unread = _notificationController.unreadCount;
            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotificationListScreen(
                          controller: _notificationController,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }


  Widget _buildWeatherCard(BuildContext context, WeatherModel weather) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFD9EFD9).withValues(alpha: 0.7),
            border: Border.all(color: Colors.white, width: 1.5),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.location,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${weather.temperature.toInt()}°C',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weather.condition,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    weather.iconPath,
                    width: 72,
                    height: 72,
                    placeholderBuilder: (_) => const Icon(
                      Icons.wb_sunny_rounded,
                      color: Colors.amber,
                      size: 56,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildWeatherMiniCard(
                      icon: Icons.water_drop_outlined,
                      iconColor: const Color(0xFF29B6F6),
                      value: '${weather.humidity.toInt()}%',
                      label: 'Humidity',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildWeatherMiniCard(
                      icon: Icons.air_rounded,
                      iconColor: const Color(0xFF42A5F5),
                      value: '12 km/h',
                      label: 'Wind',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildWeatherMiniCard(
                      icon: Icons.wb_sunny_outlined,
                      iconColor: const Color(0xFFFFB300),
                      value: 'Moderate',
                      label: 'UV Index',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherMiniCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What would you like to do?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Prediction – Green filled card
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PredictCropScreen(
                        controller: PredictController(
                          predictRepo: HttpPredictRepo(),
                          userToken: _userToken,
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFA8D5BA).withValues(alpha: 0.6),
                            const Color(0xFF2D9B4A).withValues(alpha: 0.5),
                          ],
                        ),
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.grass_rounded,
                              color: Colors.amber,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 52),
                          const Text(
                            'Crop\nPrediction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF082819),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Analyze soil &\nrecommend crops',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF082819),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Fertilizer Prediction – White card
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => PredictFertilizerScreen(
                            controller: FertilizerController(
                              fertilizerRepo: HttpFertilizerRepo(),
                              userToken: _userToken,
                            ),
                          ),
                        ),
                      )
                      .then((_) => widget.controller.loadDashboardData());
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE0F0E0),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.science_rounded,
                          color: Color(0xFF26C6DA),
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 52),
                      const Text(
                        'Fertilizer\nPrediction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Get nutrient\nrecommendations',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(
    BuildContext context,
    List<PredictionHistoryModel> history,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _currentNavigationIndex = 1),
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8F0E8), width: 1),
            ),
            child: const Text(
              'No recent activity yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...history
              .take(4)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRecentHistoryItem(context, item),
                ),
              ),
      ],
    );
  }

  Widget _buildRecentHistoryItem(
    BuildContext context,
    PredictionHistoryModel item,
  ) {
    IconData icon = Icons.eco;
    if (item.cropName.toLowerCase() == 'wheat') {
      icon = Icons.grain;
    } else if (item.cropName.toLowerCase() == 'maize') {
      icon = Icons.grass;
    }

    return GestureDetector(
      onTap: () {
        final fullItem = MockDatabase.historyList.firstWhere(
          (e) => e.id == item.id,
          orElse: () => MockDatabase.historyList.first,
        );
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => PredictionDetailsScreen(item: fullItem),
              ),
            )
            .then((_) => widget.controller.loadDashboardData());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8F0E8), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.cropName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    item.date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.recommendation,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCardBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NewsFeedScreen(controller: _newsController),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8F0E8), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.newspaper_rounded,
                color: AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agri News & Advisories',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pest warnings, weather advisories & govt subsidies.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryGreen,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8F0E8), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(
                1,
                Icons.history_rounded,
                Icons.history_outlined,
                'History',
              ),
              _buildNavItem(
                2,
                Icons.person_rounded,
                Icons.person_outline_rounded,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = _currentNavigationIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentNavigationIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primaryGreen : AppColors.textLight,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textLight,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
