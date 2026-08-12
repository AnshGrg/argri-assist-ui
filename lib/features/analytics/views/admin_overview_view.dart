import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/analytics_controller.dart';

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String subtitle;
  final String trendText;

  _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.subtitle,
    required this.trendText,
  });
}

class AdminOverviewView extends StatelessWidget {
  final AnalyticsController controller;
  final bool isDesktop;

  const AdminOverviewView({
    super.key,
    required this.controller,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time status of farmers, query volumes, and critical soil alerts.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 4 KPI Stat Cards
        _buildKpiStatCards(context),
        const SizedBox(height: 24),

        // Main Grid: Platform Usage Trends & City Leaderboard
        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildUsageTrendsCard(context),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: _buildCityLeaderboardCard(context),
              ),
            ],
          ),
        ] else ...[
          _buildUsageTrendsCard(context),
          const SizedBox(height: 20),
          _buildCityLeaderboardCard(context),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildKpiStatCards(BuildContext context) {
    final kpi = controller.kpiData;

    final cards = [
      _StatCardData(
        title: 'Total Farmers',
        value: kpi?.totalFarmers.toString() ?? '1,420',
        icon: Icons.people_alt_rounded,
        accentColor: const Color(0xFF2E7D32),
        subtitle: 'Registered across Nepal',
        trendText: '+12% this month',
      ),
      _StatCardData(
        title: 'Crop Queries',
        value: kpi?.totalCropPredictions.toString() ?? '5,340',
        icon: Icons.eco_rounded,
        accentColor: const Color(0xFF0288D1),
        subtitle: 'Recommendation queries',
        trendText: '+18% this month',
      ),
      _StatCardData(
        title: 'Fertilizer Queries',
        value: kpi?.totalFertilizerPredictions.toString() ?? '4,890',
        icon: Icons.shopping_bag_rounded,
        accentColor: const Color(0xFF7B1FA2),
        subtitle: 'Chemical demand logs',
        trendText: '+8% this month',
      ),
      _StatCardData(
        title: 'Acidic Soil Alerts',
        value: kpi?.totalAcidicSoilAlerts.toString() ?? '1,280',
        icon: Icons.warning_amber_rounded,
        accentColor: const Color(0xFFD32F2F),
        subtitle: '${kpi?.acidicSoilPercentage.toStringAsFixed(1) ?? '26.2'}% critical (pH < 5.5)',
        trendText: 'Requires liming',
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isDesktop ? 1.7 : 2.1,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return _buildWebStatCard(context, card);
          },
        );
      },
    );
  }

  Widget _buildWebStatCard(BuildContext context, _StatCardData card) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: card.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(card.icon, color: card.accentColor, size: 20),
              ),
            ],
          ),
          Text(
            card.value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              Text(
                card.subtitle,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTrendsCard(BuildContext context) {
    final trends = controller.usageTrendsList;

    final maxVal = trends.fold<int>(1, (prev, element) {
      final m = max(element.cropQueries, element.fertilizerQueries);
      return max(prev, m);
    });

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Platform Query Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Volume comparison: Crop vs Fertilizer queries',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendIndicator('Crop Queries', AppColors.primaryGreen),
                  const SizedBox(width: 16),
                  _buildLegendIndicator('Fertilizer Queries', const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (trends.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No usage trend data available',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            Container(
              height: 220,
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: trends.map((item) {
                  final cropHeight = (item.cropQueries / maxVal) * 160;
                  final fertHeight = (item.fertilizerQueries / maxVal) * 160;
                  final dateFormatted =
                      item.date.length >= 5 ? item.date.substring(5) : item.date;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 14,
                            height: max(cropHeight, 4.0),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 14,
                            height: max(fertHeight, 4.0),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateFormatted,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
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

  Widget _buildLegendIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildCityLeaderboardCard(BuildContext context) {
    final list = controller.fertilizerDemandList;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Active Cities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Farmer engagement leaderboard',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No city activity logs',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            Column(
              children: list.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: idx == 1
                              ? const Color(0xFFFEF3C7)
                              : (idx == 2 ? const Color(0xFFE2E8F0) : const Color(0xFFE8F5E9)),
                        ),
                        child: Center(
                          child: Text(
                            '$idx',
                            style: TextStyle(
                              color: idx == 1
                                  ? const Color(0xFFD97706)
                                  : (idx == 2 ? const Color(0xFF475569) : AppColors.primaryGreen),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.city,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        '${item.totalQueries} queries',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                          fontSize: 13,
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
}
