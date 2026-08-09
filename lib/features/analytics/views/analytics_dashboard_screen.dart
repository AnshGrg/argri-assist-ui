import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/analytics_controller.dart';
import '../models/crop_distribution_model.dart';
import '../models/fertilizer_demand_model.dart';
import '../../home/views/home_screen.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/repos/home_repo.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AnalyticsController();
    _controller.fetchAnalyticsData(token: widget.authToken);
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
          IconButton(
            icon: const Icon(Icons.phone_android_rounded, color: AppColors.primaryGreen),
            tooltip: 'Switch to Farmer App View',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    controller: HomeController(homeRepo: MockHomeRepo()),
                  ),
                ),
              );
            },
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
        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildSoilPhSpectrumCard(context),
              ),
              const SizedBox(width: AppSizes.l),
              Expanded(
                flex: 2,
                child: _buildNpkDeficiencyCard(context, kpi),
              ),
            ],
          ),
        ] else ...[
          _buildSoilPhSpectrumCard(context),
          AppSizes.spaceXl,
          _buildNpkDeficiencyCard(context, kpi),
        ],
        AppSizes.spaceXl,
        _buildSoilAcidityHotspotsCard(context),
        AppSizes.spaceXl,
        _buildFertilizerDemandCard(context),
        AppSizes.spaceXl,
      ],
    );
  }

  Widget _buildSoilPhSpectrumCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'National Soil pH Spectrum',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          Text(
            'Extremely Acidic vs Moderately Acidic vs Neutral vs Alkaline',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMedium,
                ),
          ),
          AppSizes.spaceL,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPhSpectrumTile('Extremely Acidic\n(< 5.0)', '28.4%', Colors.red.shade700),
              _buildPhSpectrumTile('Moderately Acidic\n(5.0 - 6.0)', '41.2%', Colors.orange.shade700),
              _buildPhSpectrumTile('Neutral\n(6.0 - 7.5)', '24.1%', AppColors.primaryGreen),
              _buildPhSpectrumTile('Alkaline\n(> 7.5)', '6.3%', Colors.blue.shade700),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhSpectrumTile(String label, String percent, Color color) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              percent,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
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
        _buildNasaClimateCards(context),
        AppSizes.spaceXl,
      ],
    );
  }

  Widget _buildTopRecommendedCropsCard(BuildContext context) {
    final topCropsList = [
      _CropRankData(rank: 1, name: 'Rice', queries: 1420, confidence: 98.4),
      _CropRankData(rank: 2, name: 'Maize', queries: 890, confidence: 96.1),
      _CropRankData(rank: 3, name: 'Chickpea', queries: 650, confidence: 94.8),
      _CropRankData(rank: 4, name: 'Lentil', queries: 520, confidence: 93.2),
      _CropRankData(rank: 5, name: 'Jute', queries: 510, confidence: 91.5),
      _CropRankData(rank: 6, name: 'Watermelon', queries: 480, confidence: 90.0),
    ];

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
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Text(
                      '${item.queries} queries',
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
                        '${item.confidence}% conf.',
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

  Widget _buildNasaClimateCards(BuildContext context) {
    final climateList = _controller.climateDataList;

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
                    'Regional NASA Satellite Climate Averages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  Text(
                    'Live satellite parameters fetched from NASA POWER',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                        ),
                  ),
                ],
              ),
              const Icon(Icons.wb_sunny_outlined, color: AppColors.primaryGreen),
            ],
          ),
          AppSizes.spaceL,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: AppSizes.m,
              mainAxisSpacing: AppSizes.m,
              childAspectRatio: 1.8,
            ),
            itemCount: climateList.length,
            itemBuilder: (context, index) {
              final item = climateList[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.primaryGreen, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          item.city,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildClimateParam(Icons.thermostat_rounded, '${item.averageTemperature}°C', 'Temp', Colors.orange),
                        _buildClimateParam(Icons.water_drop_rounded, '${item.averageHumidity}%', 'Humidity', Colors.blue),
                        _buildClimateParam(Icons.grain_rounded, '${item.averageRainfall}mm', 'Rainfall', AppColors.primaryGreen),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClimateParam(IconData icon, String val, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMedium)),
      ],
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

class _CropRankData {
  final int rank;
  final String name;
  final int queries;
  final double confidence;

  _CropRankData({
    required this.rank,
    required this.name,
    required this.queries,
    required this.confidence,
  });
}
