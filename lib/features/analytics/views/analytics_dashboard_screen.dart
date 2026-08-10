// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/image_picker_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/analytics_controller.dart';
import '../models/crop_distribution_model.dart';
import '../models/fertilizer_demand_model.dart';
import '../../news/controllers/news_controller.dart';
import '../../news/models/news_article_model.dart';
import '../../news/repos/news_repo.dart';
import '../../news/repos/subscription_repo.dart';
import '../../news/views/create_news_article_screen.dart';
import '../../news/views/news_detail_screen.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  final AnalyticsController? controller;
  final String? authToken;

  const AnalyticsDashboardScreen({
    super.key,
    this.controller,
    this.authToken,
  });

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  late final AnalyticsController _controller;
  late final NewsController _newsController;

  List<NewsArticleModel> _adminNewsArticles = [];
  bool _isLoadingNews = false;
  String _newsFilter = 'ALL';
  String _newsSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AnalyticsController();

    _newsController = NewsController(
      newsRepo: HttpNewsRepo(),
      subscriptionRepo: HttpSubscriptionRepo(),
      userToken: widget.authToken,
    );
    if (widget.authToken != null && widget.authToken!.isNotEmpty) {
      _newsController.setAdminToken(widget.authToken);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchAnalyticsData(token: widget.authToken);
      _newsController.fetchCategories();
      _loadAdminNews();
    });
  }

  Future<void> _loadAdminNews() async {
    setState(() => _isLoadingNews = true);
    final list = await _newsController.fetchAdminNewsList();
    if (mounted) {
      setState(() {
        _adminNewsArticles = list;
        _isLoadingNews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          // Backdrop Blur & Overlay
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
                child: Container(
                  color: AppColors.backgroundGreen.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
          // Body Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  children: [
                    _buildTopNavigationBar(context, isDesktop),
                    _buildTabSwitcher(context),
                    if (_controller.errorMessage != null)
                      _buildErrorBanner(context),
                    Expanded(
                      child: _controller.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGreen,
                              ),
                            )
                          : SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 32.0 : AppSizes.m,
                                vertical: AppSizes.l,
                              ),
                              child: Center(
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 1280),
                                  child: _buildPageBody(context, isDesktop),
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigationBar(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.l,
        vertical: AppSizes.m,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.7),
        border: Border(
          bottom: BorderSide(
            color: AppColors.white.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: AppSizes.s),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSizes.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extension Officer & Admin Analytics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Nepal Regional Agricultural Intelligence Dashboard',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Staff Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'OFFICER: ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.s),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGreen),
            tooltip: 'Refresh Analytics',
            onPressed: () => _controller.fetchAnalyticsData(token: widget.authToken),
          ),
        ],
      ),
    );
  }

  // 3-Tab Switcher Component
  Widget _buildTabSwitcher(BuildContext context) {
    final currentIndex = _controller.currentTabIndex;

    final tabs = [
      _TabItem(title: 'System Overview', route: '/admin/dashboard', icon: Icons.dashboard_rounded),
      _TabItem(title: 'Soil & Fertilizer', route: '/admin/soil-health', icon: Icons.science_rounded),
      _TabItem(title: 'Crop & Climate Intelligence', route: '/admin/crop-intelligence', icon: Icons.eco_rounded),
      _TabItem(title: 'News & Advisories', route: '/admin/news', icon: Icons.newspaper_rounded),
    ];

    return Container(
      width: double.infinity,
      color: AppColors.white.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isSelected = idx == currentIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                showCheckmark: false,
                avatar: Icon(
                  item.icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primaryGreen,
                ),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      item.route,
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : AppColors.textLight,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen,
                backgroundColor: AppColors.white.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onSelected: (_) {
                  _controller.setTabIndex(idx);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    final code = _controller.errorCode;
    final msg = _controller.errorMessage ?? 'An error occurred';

    Color bannerBg = Colors.amber.shade100;
    Color borderClr = Colors.amber.shade400;
    Color textClr = Colors.amber.shade900;
    IconData iconData = Icons.warning_amber_rounded;

    if (code == 401) {
      bannerBg = Colors.orange.shade100;
      borderClr = Colors.orange.shade400;
      textClr = Colors.orange.shade900;
      iconData = Icons.lock_outline_rounded;
    } else if (code == 403) {
      bannerBg = Colors.red.shade100;
      borderClr = Colors.red.shade400;
      textClr = Colors.red.shade900;
      iconData = Icons.gpp_bad_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bannerBg,
        border: Border(bottom: BorderSide(color: borderClr, width: 1)),
      ),
      child: Row(
        children: [
          Icon(iconData, color: textClr, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(color: textClr, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: textClr,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _controller.fetchAnalyticsData(token: widget.authToken),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Page Body Switcher
  Widget _buildPageBody(BuildContext context, bool isDesktop) {
    switch (_controller.currentTabIndex) {
      case 1:
        return _buildPage2SoilAndFertilizer(context, isDesktop);
      case 2:
        return _buildPage3CropAndClimate(context, isDesktop);
      case 3:
        return _buildPage4NewsManagement(context, isDesktop);
      case 0:
      default:
        return _buildPage1SystemOverview(context, isDesktop);
    }
  }

  // ================= PAGE 1: SYSTEM OVERVIEW & NATIONAL KPIS =================
  Widget _buildPage1SystemOverview(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKpiStatCards(context, isDesktop),
        AppSizes.spaceXl,
        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildUsageTrendsCard(context),
              ),
              const SizedBox(width: AppSizes.l),
              Expanded(
                flex: 2,
                child: _buildCityLeaderboardCard(context),
              ),
            ],
          ),
        ] else ...[
          _buildUsageTrendsCard(context),
          AppSizes.spaceXl,
          _buildCityLeaderboardCard(context),
        ],
        AppSizes.spaceXl,
      ],
    );
  }

  Widget _buildKpiStatCards(BuildContext context, bool isDesktop) {
    final kpi = _controller.kpiData;

    final cards = [
      _StatCardData(
        title: 'Total Farmers',
        value: kpi?.totalFarmers.toString() ?? '1,420',
        icon: Icons.people_outline_rounded,
        gradient: [const Color(0xFF2E6F40), const Color(0xFF4CAF50)],
        subtitle: 'Registered across Nepal',
      ),
      _StatCardData(
        title: 'Crop Queries',
        value: kpi?.totalCropPredictions.toString() ?? '5,340',
        icon: Icons.eco_outlined,
        gradient: [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
        subtitle: 'Recommendation queries',
      ),
      _StatCardData(
        title: 'Fertilizer Queries',
        value: kpi?.totalFertilizerPredictions.toString() ?? '4,890',
        icon: Icons.shopping_bag_outlined,
        gradient: [const Color(0xFF8E24AA), const Color(0xFFAB47BC)],
        subtitle: 'Chemical demand logs',
      ),
      _StatCardData(
        title: 'Acidic Soil Alerts',
        value: kpi?.totalAcidicSoilAlerts.toString() ?? '1,280',
        icon: Icons.warning_rounded,
        gradient: [const Color(0xFFD32F2F), const Color(0xFFEF5350)],
        subtitle: '${kpi?.acidicSoilPercentage.toStringAsFixed(1) ?? '26.2'}% critical (pH < 5.5)',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000
            ? 4
            : (constraints.maxWidth > 600 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSizes.m,
            mainAxisSpacing: AppSizes.m,
            childAspectRatio: isDesktop ? 1.8 : 2.2,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return _buildSingleStatCard(context, card);
          },
        );
      },
    );
  }

  Widget _buildSingleStatCard(BuildContext context, _StatCardData card) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        gradient: LinearGradient(
          colors: card.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: card.gradient.last.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(card.icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          Text(
            card.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            card.subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTrendsCard(BuildContext context) {
    final trends = _controller.usageTrendsList;

    final maxVal = trends.fold<int>(1, (prev, element) {
      final m = max(element.cropQueries, element.fertilizerQueries);
      return max(prev, m);
    });

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform Query Activity over Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  Text(
                    'Dual-Line: Crop vs Fertilizer query volume over time',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendIndicator('Crop Queries', AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  _buildLegendIndicator('Fertilizer Queries', Colors.orange.shade700),
                ],
              ),
            ],
          ),
          AppSizes.spaceL,
          if (trends.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('No usage trend data available')),
            )
          else
            Container(
              height: 200,
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: trends.map((item) {
                  final cropHeight = (item.cropQueries / maxVal) * 150;
                  final fertHeight = (item.fertilizerQueries / maxVal) * 150;
                  final dateFormatted = item.date.length >= 5 ? item.date.substring(5) : item.date;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 12,
                            height: max(cropHeight, 4.0),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 12,
                            height: max(fertHeight, 4.0),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade700,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateFormatted,
                        style: const TextStyle(fontSize: 10, color: AppColors.textMedium, fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCityLeaderboardCard(BuildContext context) {
    final list = _controller.fertilizerDemandList;

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Active Cities Leaderboard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          Text(
            'Farmer engagement ranking',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMedium,
                ),
          ),
          AppSizes.spaceL,
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No city activity logs')),
            )
          else
            Column(
              children: list.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: idx == 1
                            ? Colors.amber.shade700
                            : (idx == 2 ? Colors.grey.shade600 : AppColors.primaryGreen),
                        child: Text(
                          '$idx',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.city,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Text(
                        '${item.totalQueries} queries',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryGreen, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ================= PAGE 2: REGIONAL SOIL HEALTH & FERTILIZER DEMAND =================
  Widget _buildPage2SoilAndFertilizer(BuildContext context, bool isDesktop) {
    final kpi = _controller.kpiData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNpkDeficiencyCard(context, kpi),
        AppSizes.spaceXl,
        _buildSoilAcidityHotspotsCard(context),
        AppSizes.spaceXl,
        _buildFertilizerDemandCard(context),
        AppSizes.spaceXl,
      ],
    );
  }

  Widget _buildNpkDeficiencyCard(BuildContext context, dynamic kpi) {
    final nRate = kpi?.nitrogenDeficiencyRate ?? 42.0;
    final pRate = kpi?.phosphorusDeficiencyRate ?? 38.0;
    final kRate = kpi?.potassiumDeficiencyRate ?? 21.0;

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NPK Deficiency Rates (%)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          Text(
            'National macronutrient deficit indicators',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMedium,
                ),
          ),
          AppSizes.spaceM,
          _buildDeficiencyBadge('Nitrogen (N) Deficiency', nRate, Colors.red.shade600),
          _buildDeficiencyBadge('Phosphorus (P) Deficiency', pRate, Colors.orange.shade600),
          _buildDeficiencyBadge('Potassium (K) Deficiency', kRate, Colors.amber.shade700),
        ],
      ),
    );
  }

  Widget _buildDeficiencyBadge(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              Text('${val.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (val / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.lightGreen,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilAcidityHotspotsCard(BuildContext context) {
    final hotspots = _controller.acidityHotspotsList;

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soil Acidity Hotspots & Liming Risk Table',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  Text(
                    'Acidity thresholds (pH < 5.5) and action required',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                        ),
                  ),
                ],
              ),
              const Icon(Icons.shield_outlined, color: AppColors.primaryGreen),
            ],
          ),
          AppSizes.spaceL,
          if (hotspots.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('No acidity hotspot data available')),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 48,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('City / Region', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Avg pH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Acidic Tests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Acidic %', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Risk Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Action Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
                rows: hotspots.map((item) {
                  Color riskColor;
                  Color riskBg;

                  switch (item.acidityRiskLevel.toUpperCase()) {
                    case 'CRITICAL':
                      riskColor = Colors.red.shade900;
                      riskBg = Colors.red.shade100;
                      break;
                    case 'HIGH':
                      riskColor = Colors.orange.shade900;
                      riskBg = Colors.orange.shade100;
                      break;
                    default:
                      riskColor = Colors.green.shade900;
                      riskBg = Colors.green.shade100;
                      break;
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.place_outlined, size: 14, color: AppColors.primaryGreen),
                            const SizedBox(width: 4),
                            Text(item.city, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                      DataCell(Text(item.averagePh.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('${item.acidicTestsCount} / ${item.totalTests}')),
                      DataCell(Text('${item.acidicPercentage.toStringAsFixed(1)}%')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: riskBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.acidityRiskLevel,
                            style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.defaultAction,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryGreen),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFertilizerDemandCard(BuildContext context) {
    final list = _controller.fertilizerDemandList;
    final selectedCity = _controller.selectedCity;

    final cities = ['All', ...list.map((e) => e.city)];

    final filteredList = selectedCity == 'All'
        ? list
        : list.where((e) => e.city == selectedCity).toList();

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Regional Fertilizer Demand by City',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  Text(
                    'Grouped Bar: DAP vs Urea vs Lime vs MOP per city',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                        ),
                  ),
                ],
              ),
              // City Filter Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: DropdownButton<String>(
                  value: cities.contains(selectedCity) ? selectedCity : 'All',
                  underline: const SizedBox(),
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryGreen),
                  items: cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(
                        city,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _controller.setSelectedCity(val);
                    }
                  },
                ),
              ),
            ],
          ),
          AppSizes.spaceL,
          if (filteredList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('No demand data available')),
            )
          else
            Column(
              children: filteredList.map((item) {
                return _buildCityFertilizerRow(context, item);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCityFertilizerRow(BuildContext context, RegionalFertilizerDemand item) {
    final maxVal = item.fertilizers.values.isEmpty
        ? 1
        : item.fertilizers.values.reduce(max);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.m),
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_city_rounded, size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 6),
                  Text(
                    item.city,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Text(
                'Total Queries: ${item.totalQueries}',
                style: const TextStyle(color: AppColors.textMedium, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...item.fertilizers.entries.map((entry) {
            final double ratio = (entry.value / maxVal).clamp(0.05, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                      Text(
                        '${entry.value} bags/queries',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: AppColors.lightGreen,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.key.contains('Lime')
                            ? Colors.purple.shade400
                            : (entry.key.contains('Urea') ? AppColors.primaryGreen : Colors.orange.shade400),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= PAGE 3: CROP CULTIVATION & SATELLITE CLIMATE INTELLIGENCE =================
  Widget _buildPage3CropAndClimate(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildTopRecommendedCropsCard(context),
              ),
              const SizedBox(width: AppSizes.l),
              Expanded(
                flex: 2,
                child: _buildCropDistributionCard(context),
              ),
            ],
          ),
        ] else ...[
          _buildTopRecommendedCropsCard(context),
          AppSizes.spaceXl,
          _buildCropDistributionCard(context),
        ],
        AppSizes.spaceXl,
      ],
    );
  }

  Widget _buildTopRecommendedCropsCard(BuildContext context) {
    final topCropsList = _controller.topCropsLeaderboard;

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Recommended Crops Leaderboard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          Text(
            'Ranked by total query count and model confidence %',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMedium,
                ),
          ),
          AppSizes.spaceL,
          if (topCropsList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('No crop leaderboard data available')),
            )
          else
            Column(
              children: topCropsList.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: item.rank == 1
                            ? Colors.amber.shade700
                            : (item.rank == 2 ? Colors.grey.shade600 : AppColors.primaryGreen),
                        child: Text(
                          '${item.rank}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.cropName.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Text(
                        '${item.totalRecommendations} queries',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${item.avgConfidencePct.toStringAsFixed(1)}% conf.',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCropDistributionCard(BuildContext context) {
    final list = _controller.cropDistributionList;
    final selectedSeason = _controller.selectedSeason;

    final seasons = list.map((e) => e.season).toList();
    if (seasons.isEmpty) {
      seasons.addAll(['Monsoon', 'Winter', 'Summer', 'Pre-Monsoon']);
    }

    final currentSeasonDist = list.firstWhere(
      (e) => e.season.toLowerCase() == selectedSeason.toLowerCase(),
      orElse: () => list.isNotEmpty
          ? list.first
          : SeasonalCropDistribution(
              season: selectedSeason,
              totalRecommendations: 0,
              topCrops: [],
            ),
    );

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seasonal Crop Breakdown (Pie / Donut)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          Text(
            'Recommended crops seasonal distribution',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMedium,
                ),
          ),
          AppSizes.spaceM,
          // Season Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: seasons.map((s) {
                final isSelected = s.toLowerCase() == selectedSeason.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _controller.setSelectedSeason(s);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          AppSizes.spaceL,
          Text(
            'Total Recommendations: ${currentSeasonDist.totalRecommendations}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMedium),
          ),
          const SizedBox(height: 12),
          if (currentSeasonDist.topCrops.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No crop recommendations for this season')),
            )
          else
            Column(
              children: currentSeasonDist.topCrops.map((c) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco, color: AppColors.primaryGreen, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.crop.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              '${c.count} queries (${c.percentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${c.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMedium),
        ),
      ],
    );
  }

  List<NewsArticleModel> get _filteredAdminNews {
    return _adminNewsArticles.where((article) {
      final statusUpper = article.status.toUpperCase();
      final matchesFilter = _newsFilter == 'ALL' ||
          (_newsFilter == 'PUBLISHED' && statusUpper == 'PUBLISHED') ||
          (_newsFilter == 'DRAFT' && statusUpper == 'DRAFT');
      final matchesSearch = _newsSearchQuery.isEmpty ||
          article.title.toLowerCase().contains(_newsSearchQuery.toLowerCase()) ||
          article.summary.toLowerCase().contains(_newsSearchQuery.toLowerCase()) ||
          article.category.name.toLowerCase().contains(_newsSearchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  // ================= PAGE 4: NEWS & ADVISORIES MANAGEMENT =================
  Widget _buildPage4NewsManagement(BuildContext context, bool isDesktop) {
    final filtered = _filteredAdminNews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSizes.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agriculture News & Advisories Management',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create, edit, publish and delete news articles & farmer advisories',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMedium,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text(
                      'Post News Article',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _openCreateNewsScreen(context),
                  ),
                ],
              ),
              AppSizes.spaceL,
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _newsSearchQuery = val.trim()),
                        decoration: const InputDecoration(
                          hintText: 'Search news by title, summary, category...',
                          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildNewsFilterChip('ALL', 'All (${_adminNewsArticles.length})'),
                        const SizedBox(width: 8),
                        _buildNewsFilterChip('PUBLISHED', 'Published'),
                        const SizedBox(width: 8),
                        _buildNewsFilterChip('DRAFT', 'Drafts'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGreen),
                    tooltip: 'Refresh News',
                    onPressed: _loadAdminNews,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSizes.spaceXl,
        if (_isLoadingNews)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          )
        else if (filtered.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.newspaper_rounded, size: 64, color: AppColors.textMedium.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    _newsSearchQuery.isNotEmpty
                        ? 'No articles match "$_newsSearchQuery"'
                        : 'No articles found in this filter.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text('Post News Article', style: TextStyle(color: Colors.white)),
                    onPressed: () => _openCreateNewsScreen(context),
                  ),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 650 ? 2 : 1);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: AppSizes.l,
                  mainAxisSpacing: AppSizes.l,
                  mainAxisExtent: 330,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final article = filtered[index];
                  return _buildNewsCardItem(context, article);
                },
              );
            },
          ),
        AppSizes.spaceXl,
      ],
    );
  }

  Widget _buildNewsFilterChip(String value, String label) {
    final isSelected = _newsFilter == value;
    return ChoiceChip(
      showCheckmark: false,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen,
      backgroundColor: AppColors.white.withValues(alpha: 0.6),
      onSelected: (_) => setState(() => _newsFilter = value),
    );
  }

  Widget _buildNewsCardItem(BuildContext context, NewsArticleModel article) {
    final isPublished = article.status == 'PUBLISHED';
    final dateStr = article.publishedAt != null
        ? '${article.publishedAt!.day}/${article.publishedAt!.month}/${article.publishedAt!.year}'
        : (article.createdAt != null ? '${article.createdAt!.day}/${article.createdAt!.month}/${article.createdAt!.year}' : '');

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
              child: Image.network(
                article.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  color: AppColors.lightGreen,
                  child: const Center(child: Icon(Icons.newspaper_rounded, color: AppColors.primaryGreen, size: 36)),
                ),
              ),
            )
          else
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
              ),
              child: const Center(child: Icon(Icons.article_rounded, color: AppColors.primaryGreen, size: 36)),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPublished ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.status,
                          style: TextStyle(
                            color: isPublished ? Colors.green.shade900 : Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.category.name,
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (dateStr.isNotEmpty)
                        Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textMedium)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                          height: 1.3,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 20, color: AppColors.primaryGreen),
                  tooltip: 'View Details',
                  onPressed: () => _showViewNewsDialog(context, article),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textDark),
                  tooltip: 'Edit Article',
                  onPressed: () => _showEditNewsDialog(context, article),
                ),
                if (!isPublished)
                  IconButton(
                    icon: const Icon(Icons.publish_rounded, size: 20, color: Colors.green),
                    tooltip: 'Publish Now',
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await _newsController.publishAdminArticle(article.id);
                      messenger.showSnackBar(
                        SnackBar(content: Text(success ? 'Article published!' : 'Failed to publish.')),
                      );
                      if (success) _loadAdminNews();
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                  tooltip: 'Delete Article',
                  onPressed: () => _confirmDeleteNews(context, article),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateNewsScreen(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewsArticleScreen(controller: _newsController),
      ),
    );
    if (result == true) {
      _loadAdminNews();
    }
  }

  void _showEditNewsDialog(BuildContext context, NewsArticleModel article) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: article.title);
    final summaryController = TextEditingController(text: article.summary);
    final contentController = TextEditingController(text: article.content ?? '');

    Uint8List? editImageBytes;
    String? editImageName;

    int? selectedCategoryId = article.category.id;
    String status = article.status;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text('Edit News Article', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                        ),
                        AppSizes.spaceS,
                        TextFormField(
                          controller: summaryController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Summary *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Summary is required' : null,
                        ),
                        AppSizes.spaceS,
                        TextFormField(
                          controller: contentController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Full Content *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Content is required' : null,
                        ),
                        AppSizes.spaceS,

                        // Image File Picker for Edit
                        InkWell(
                          onTap: () async {
                            final picked = await ImagePickerService.pickImage();
                            if (picked != null) {
                              setDialogState(() {
                                editImageBytes = picked.bytes;
                                editImageName = picked.name;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.image_outlined, color: AppColors.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    editImageName != null
                                        ? 'New File: $editImageName'
                                        : (article.imageUrl != null ? 'Current Image Attached' : 'Select Image File (Optional)'),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.folder_open_rounded, size: 20, color: AppColors.primaryGreen),
                              ],
                            ),
                          ),
                        ),
                        AppSizes.spaceS,
                        DropdownButtonFormField<int>(
                          value: (_newsController.categories.any((c) => c.id == selectedCategoryId))
                              ? selectedCategoryId
                              : (_newsController.categories.isNotEmpty ? _newsController.categories.first.id : null),
                          items: _newsController.categories.map((cat) {
                            return DropdownMenuItem<int>(value: cat.id, child: Text(cat.name));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedCategoryId = val);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        AppSizes.spaceS,
                        DropdownButtonFormField<String>(
                          initialValue: status,
                          items: const [
                            DropdownMenuItem(value: 'PUBLISHED', child: Text('PUBLISHED')),
                            DropdownMenuItem(value: 'DRAFT', child: Text('DRAFT')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => status = val);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                  label: const Text('Save Changes', style: TextStyle(color: AppColors.white)),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.pop(dialogCtx);
                      final success = await _newsController.updateAdminArticle(
                        article.id,
                        title: titleController.text.trim(),
                        summary: summaryController.text.trim(),
                        content: contentController.text.trim(),
                        categoryId: selectedCategoryId,
                        imageBytes: editImageBytes,
                        imageName: editImageName,
                        status: status,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Article updated successfully!' : 'Failed to update article.'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                        if (success) _loadAdminNews();
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showViewNewsDialog(BuildContext context, NewsArticleModel article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(
          initialArticle: article,
          controller: _newsController,
        ),
      ),
    );
  }

  void _confirmDeleteNews(BuildContext context, NewsArticleModel article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete News Article'),
          ],
        ),
        content: Text('Are you sure you want to permanently delete "${article.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _newsController.deleteAdminArticle(article.id);
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Article deleted successfully!' : 'Failed to delete article.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) _loadAdminNews();
      }
    }
  }
}

class _TabItem {
  final String title;
  final String route;
  final IconData icon;

  _TabItem({required this.title, required this.route, required this.icon});
}

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final String subtitle;

  _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.subtitle,
  });
}

