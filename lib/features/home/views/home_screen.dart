import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authController = widget.authController ??
        AuthController(authRepo: HttpAuthRepo());
    _notificationController = widget.notificationController ??
        NotificationController(
          notificationRepo: HttpNotificationRepo(),
          userToken: _userToken,
          onNewNotifications: _showNewNotificationToast,
        );
    _newsController = widget.newsController ??
        NewsController(
          newsRepo: HttpNewsRepo(),
          subscriptionRepo: HttpSubscriptionRepo(),
          userToken: _userToken,
        );

    // Fetch initial dashboard data & start periodic notification polling
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
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 20),
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
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationListScreen(
                  controller: _notificationController,
                ),
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
        _notificationController.fetchUnreadCount(); // Will stop timer and clear count
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
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBody() {
    switch (_currentNavigationIndex) {
      case 1:
        return PredictCropScreen(
          controller: PredictController(
            predictRepo: HttpPredictRepo(),
            userToken: _userToken,
          ),
        );
      case 2:
        return HistoryScreen(
          controller: HistoryController(
            userToken: _userToken,
          ),
        );
      case 3:
        return ProfileScreen(
          authController: _authController,
        );
      case 0:
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        // Blur Filter & Translucent Overlay
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
              child: Container(
                color: AppColors.backgroundGreen.withValues(alpha: 0.65),
              ),
            ),
          ),
        ),
        // Scrollable UI
        SafeArea(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              if (widget.controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                );
              }

              if (widget.controller.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.controller.errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.red,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      AppSizes.spaceM,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xl,
                  vertical: AppSizes.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    AppSizes.spaceXl,
                    if (weather != null) _buildWeatherCard(context, weather),
                    AppSizes.spaceXl,
                    _buildActionHeading(context),
                    AppSizes.spaceM,
                    _buildActionCards(context),
                    AppSizes.spaceL,
                    _buildNewsCardBanner(context),
                    AppSizes.spaceXl,
                    _buildHistoryHeader(context),

                    AppSizes.spaceM,
                    _buildHistoryList(context, history),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            Row(
              children: [
                Text(
                  _authController.tokens?.username ?? 'Farmer',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: AppSizes.s),
                const Text(
                  '👋',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            AnimatedBuilder(
              animation: _notificationController,
              builder: (context, _) {
                final unread = _notificationController.unreadCount;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: AppSizes.iconLarge,
                        color: AppColors.primaryGreen,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NotificationListScreen(
                              controller: _notificationController,
                            ),
                          ),
                        );
                      },
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.notificationDot,
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
                                fontSize: 10,
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
        ),
      ],
    );
  }

  Widget _buildWeatherCard(BuildContext context, WeatherModel weather) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left portion
          Row(
            children: [
              // Weather icon
              Container(
                padding: const EdgeInsets.all(AppSizes.s),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded, // or cloud with sun if custom asset exists
                  color: Colors.amber,
                  size: AppSizes.iconLarge,
                ),
              ),
              AppSizes.spaceM,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.toInt()}°C',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    weather.condition,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                        ),
                  ),
                ],
              ),
            ],
          ),
          // Right portion
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                weather.location,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                'Humidity ${weather.humidity.toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMedium,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionHeading(BuildContext context) {
    return Text(
      'What would you like to do?',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    final double cardWidth = (MediaQuery.of(context).size.width - (AppSizes.xl * 2) - AppSizes.m) / 2;

    return Row(
      children: [
        _buildActionCard(
          context: context,
          width: cardWidth,
          title: 'Predict\nCrop',
          icon: Icons.eco_outlined,
          gradient: AppColors.cropCardGradient,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PredictCropScreen(
                  controller: PredictController(
                    predictRepo: HttpPredictRepo(),
                    userToken: _userToken,
                  ),
                ),
              ),
            );
          },
        ),
        AppSizes.spaceM,
        _buildActionCard(
          context: context,
          width: cardWidth,
          title: 'Predict\nFertilizer',
          icon: Icons.shopping_bag_outlined, // bag icon
          gradient: AppColors.fertilizerCardGradient,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PredictFertilizerScreen(
                  controller: FertilizerController(
                    fertilizerRepo: HttpFertilizerRepo(),
                    userToken: _userToken,
                  ),
                ),
              ),
            ).then((_) {
              widget.controller.loadDashboardData();
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required double width,
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 180,
        padding: const EdgeInsets.all(AppSizes.l),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(AppSizes.s),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: AppSizes.iconLarge,
              ),
            ),
            // Title & Next Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCardBanner(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewsFeedScreen(controller: _newsController),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.m),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.newspaper_rounded,
                color: AppColors.primaryGreen,
                size: AppSizes.iconLarge,
              ),
            ),
            AppSizes.spaceM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agri News & Advisories',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pest warnings, weather advisories & government subsidy notices.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryHeader(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Prediction History',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
        ),
        GestureDetector(
          onTap: () {
            // Future History page redirection
          },
          child: Text(
            'View All',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGreenLink,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(BuildContext context, List<PredictionHistoryModel> history) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (context, index) => AppSizes.spaceM,
      itemBuilder: (context, index) {
        final item = history[index];
        return _buildHistoryItem(context, item);
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, PredictionHistoryModel item) {
    // Determine background color / icon based on crop name
    Color avatarBgColor = AppColors.lightGreen;
    IconData cropIcon = Icons.grass;

    if (item.cropName.toLowerCase() == 'rice') {
      cropIcon = Icons.eco;
    } else if (item.cropName.toLowerCase() == 'wheat') {
      cropIcon = Icons.grain;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.8), width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.m,
          vertical: AppSizes.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: avatarBgColor,
          radius: 24,
          child: Icon(
            cropIcon,
            color: AppColors.primaryGreen,
          ),
        ),
        title: Text(
          item.cropName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          item.date,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.recommendation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMedium,
                  ),
            ),
            const SizedBox(width: AppSizes.s),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
            ),
          ],
        ),
        onTap: () {
          final fullItem = MockDatabase.historyList.firstWhere(
            (e) => e.id == item.id,
            orElse: () => MockDatabase.historyList.first,
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PredictionDetailsScreen(item: fullItem),
            ),
          ).then((_) {
            widget.controller.loadDashboardData();
          });
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.white.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavigationIndex,
        onTap: (index) {
          setState(() {
            _currentNavigationIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Predict',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
