import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/analytics_controller.dart';
import '../models/crop_distribution_model.dart';

class AdminCropClimateView extends StatelessWidget {
  final AnalyticsController controller;
  final bool isDesktop;

  const AdminCropClimateView({
    super.key,
    required this.controller,
    required this.isDesktop,
  });

  static const List<Color> _pieColors = [
    Color(0xFF2E6F40),
    Color(0xFF5CA368),
    Color(0xFF81C784),
    Color(0xFFFFB74D),
    Color(0xFF4FC3F7),
    Color(0xFFBA68C8),
    Color(0xFFFF8A65),
    Color(0xFFAED581),
    Color(0xFF4DD0E1),
    Color(0xFFF06292),
  ];


  Widget _webCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page heading
        const Text(
          'Crop & Climate',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Top recommended crops leaderboard and seasonal crop distribution breakdown.',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),

        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildTopRecommendedCropsCard()),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildCropDistributionCard()),
            ],
          ),
        ] else ...[
          _buildTopRecommendedCropsCard(),
          const SizedBox(height: 20),
          _buildCropDistributionCard(),
        ],

        const SizedBox(height: 24),
      ],
    );
  }


  Widget _buildTopRecommendedCropsCard() {
    final topCropsList = controller.topCropsLeaderboard;

    return _webCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Top Recommended Crops',
            'Ranked by query count and model confidence',
          ),
          const SizedBox(height: 20),
          if (topCropsList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No crop leaderboard data available',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            Column(
              children: topCropsList.map((item) {
                final Color rankColor = item.rank == 1
                    ? const Color(0xFFD97706)
                    : (item.rank == 2 ? const Color(0xFF475569) : AppColors.primaryGreen);
                final Color rankBg = item.rank == 1
                    ? const Color(0xFFFEF3C7)
                    : (item.rank == 2 ? const Color(0xFFF1F5F9) : const Color(0xFFE8F5E9));

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: rankBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${item.rank}',
                            style: TextStyle(
                              color: rankColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.cropName.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        '${item.totalRecommendations} queries',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.avgConfidencePct.toStringAsFixed(1)}% conf.',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
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

  Widget _buildCropDistributionCard() {
    final list = controller.cropDistributionList;
    final selectedSeason = controller.selectedSeason;

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

    return _webCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Seasonal Crop Breakdown',
            'Recommended crops by season',
          ),
          const SizedBox(height: 16),

          // Season selector tabs (web style — plain underline)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: seasons.map((s) {
                final isSelected =
                    s.toLowerCase() == selectedSeason.toLowerCase();
                return GestureDetector(
                  onTap: () => controller.setSelectedSeason(s),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          if (currentSeasonDist.topCrops.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'No crop data for this season',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                // Donut chart
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 50,
                          startDegreeOffset: -90,
                          sections: _buildPieSections(currentSeasonDist),
                          pieTouchData: PieTouchData(enabled: true),
                        ),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${currentSeasonDist.totalRecommendations}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Legend
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    currentSeasonDist.topCrops.length,
                    (i) {
                      final crop = currentSeasonDist.topCrops[i];
                      final color = _pieColors[i % _pieColors.length];
                      return _buildPieLegendItem(
                        color: color,
                        label: crop.crop[0].toUpperCase() +
                            crop.crop.substring(1),
                        count: crop.count,
                        percentage: crop.percentage,
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
      SeasonalCropDistribution dist) {
    return List.generate(dist.topCrops.length, (i) {
      final crop = dist.topCrops[i];
      final color = _pieColors[i % _pieColors.length];
      return PieChartSectionData(
        color: color,
        value: crop.count.toDouble(),
        title: '${crop.percentage.toStringAsFixed(1)}%',
        radius: 35,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        titlePositionPercentageOffset: 0.55,
      );
    });
  }

  Widget _buildPieLegendItem({
    required Color color,
    required String label,
    required int count,
    required double percentage,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
