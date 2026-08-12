import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/analytics_controller.dart';
import '../models/fertilizer_demand_model.dart';

/// Web-style Soil & Fertilizer tab view, extracted from analytics_dashboard_screen.dart.
/// All data is read from [controller]; no API calls are made here.
class AdminSoilFertilizerView extends StatelessWidget {
  final AnalyticsController controller;
  final bool isDesktop;

  const AdminSoilFertilizerView({
    super.key,
    required this.controller,
    required this.isDesktop,
  });

  // ─── Helpers ────────────────────────────────────────────────────────────────

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

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final kpi = controller.kpiData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page heading
        const Text(
          'Soil & Fertilizer',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'NPK deficiency indicators, acidity hotspots, and regional fertilizer demand.',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),

        _buildNpkDeficiencyCard(kpi),
        const SizedBox(height: 20),
        _buildSoilAcidityHotspotsCard(),
        const SizedBox(height: 20),
        _buildFertilizerDemandCard(context),
        const SizedBox(height: 24),
      ],
    );
  }

  // ─── NPK Card ────────────────────────────────────────────────────────────────

  Widget _buildNpkDeficiencyCard(dynamic kpi) {
    final nRate = kpi?.nitrogenDeficiencyRate ?? 42.0;
    final pRate = kpi?.phosphorusDeficiencyRate ?? 38.0;
    final kRate = kpi?.potassiumDeficiencyRate ?? 21.0;

    return _webCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'NPK Deficiency Rates (%)',
            'National macronutrient deficit indicators',
          ),
          const SizedBox(height: 20),
          _buildDeficiencyBar('Nitrogen (N)', nRate, const Color(0xFFEF4444)),
          const SizedBox(height: 14),
          _buildDeficiencyBar('Phosphorus (P)', pRate, const Color(0xFFF59E0B)),
          const SizedBox(height: 14),
          _buildDeficiencyBar('Potassium (K)', kRate, const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildDeficiencyBar(String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF334155),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${val.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (val / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ─── Acidity Hotspots Card ────────────────────────────────────────────────

  Widget _buildSoilAcidityHotspotsCard() {
    final hotspots = controller.acidityHotspotsList;

    return _webCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Soil Acidity Hotspots & Liming Risk',
            'Regions with pH < 5.5 and recommended action',
          ),
          const SizedBox(height: 20),
          if (hotspots.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No acidity hotspot data available',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 48,
                columnSpacing: 24,
                dividerThickness: 1,
                border: TableBorder.all(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                columns: const [
                  DataColumn(label: Text('City / Region', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Avg pH', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Acidic Tests', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Acidic %', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Risk Level', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                  DataColumn(label: Text('Action Required', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                ],
                rows: hotspots.map((item) {
                  Color riskColor;
                  Color riskBg;

                  switch (item.acidityRiskLevel.toUpperCase()) {
                    case 'CRITICAL':
                      riskColor = const Color(0xFF991B1B);
                      riskBg = const Color(0xFFFEE2E2);
                      break;
                    case 'HIGH':
                      riskColor = const Color(0xFF92400E);
                      riskBg = const Color(0xFFFEF3C7);
                      break;
                    default:
                      riskColor = const Color(0xFF14532D);
                      riskBg = const Color(0xFFDCFCE7);
                      break;
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(item.city, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      DataCell(Text(item.averagePh.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Text('${item.acidicTestsCount} / ${item.totalTests}')),
                      DataCell(Text('${item.acidicPercentage.toStringAsFixed(1)}%')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: riskBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.acidityRiskLevel,
                            style: TextStyle(
                              color: riskColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.defaultAction,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.primaryGreen,
                          ),
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

  // ─── Fertilizer Demand Card ───────────────────────────────────────────────

  Widget _buildFertilizerDemandCard(BuildContext context) {
    final list = controller.fertilizerDemandList;
    final selectedCity = controller.selectedCity;
    final cities = ['All', ...list.map((e) => e.city)];
    final filteredList = selectedCity == 'All'
        ? list
        : list.where((e) => e.city == selectedCity).toList();

    return _webCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader(
                'Regional Fertilizer Demand',
                'DAP vs Urea vs Lime vs MOP per city',
              ),
              // City Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: cities.contains(selectedCity) ? selectedCity : 'All',
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                    items: cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.setSelectedCity(val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (filteredList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No demand data available',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            Column(
              children: filteredList.map((item) => _buildCityFertilizerRow(item)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCityFertilizerRow(RegionalFertilizerDemand item) {
    final maxVal = item.fertilizers.values.isEmpty
        ? 1
        : item.fertilizers.values.reduce(max);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.city,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Total: ${item.totalQueries} queries',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...item.fertilizers.entries.map((entry) {
            final double ratio = (entry.value / maxVal).clamp(0.05, 1.0);
            final Color barColor = entry.key.contains('Lime')
                ? const Color(0xFF8B5CF6)
                : (entry.key.contains('Urea') ? AppColors.primaryGreen : const Color(0xFFF59E0B));

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      Text(
                        '${entry.value} bags',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
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
}
