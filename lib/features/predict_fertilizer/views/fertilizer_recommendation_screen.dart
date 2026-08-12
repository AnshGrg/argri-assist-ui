import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/fertilizer_controller.dart';
import '../models/fertilizer_result_model.dart';

class FertilizerRecommendationScreen extends StatelessWidget {
  final FertilizerController controller;
  final FertilizerResultModel result;

  const FertilizerRecommendationScreen({
    super.key,
    required this.controller,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF7EE),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _buildRecommendationCard(context),
                    const SizedBox(height: 24),
                    _buildNpkAnalysisCard(context),
                    const SizedBox(height: 24),
                    _buildExplanationCard(context),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            _buildFooterButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textDark,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Fertilizer Recommendation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context) {
    final confPct = result.confidence.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Best Fertilizer Recommendation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFA8E0B5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                result.recommendedFertilizer,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Best fertilizer for your field',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Confidence',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$confPct%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: result.confidence / 100.0,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE8F5E9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNpkAnalysisCard(BuildContext context) {
    final analysis = result.npkAnalysis;
    final climate = result.climateData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SOIL PARAMETERS (3 rows x 2 columns)
        const Text(
          'SOIL PARAMETERS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Color(0xFF5B8C67),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            // Row 1: Nitrogen | pH Level
            Row(
              children: [
                Expanded(
                  child: _buildParamTile(
                    icon: const Text(
                      'N',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C6B30),
                        fontSize: 16,
                      ),
                    ),
                    label: 'Nitrogen',
                    value: analysis.nitrogenStatus,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildParamTile(
                    icon: const Icon(
                      Icons.science_outlined,
                      size: 20,
                      color: Color(0xFF2C6B30),
                    ),
                    label: 'pH Level',
                    value: analysis.phStatus,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Row 2: Phosphorus | Moisture
            Row(
              children: [
                Expanded(
                  child: _buildParamTile(
                    icon: const Text(
                      'P',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C6B30),
                        fontSize: 16,
                      ),
                    ),
                    label: 'Phosphorus',
                    value: analysis.phosphorusStatus,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildParamTile(
                    icon: const Icon(
                      Icons.water_drop_outlined,
                      size: 20,
                      color: Color(0xFF2C6B30),
                    ),
                    label: 'Moisture',
                    value: '${climate.humidity.toInt()}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Row 3: Potassium | Temp
            Row(
              children: [
                Expanded(
                  child: _buildParamTile(
                    icon: const Text(
                      'K',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C6B30),
                        fontSize: 16,
                      ),
                    ),
                    label: 'Potassium',
                    value: analysis.potassiumStatus,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildParamTile(
                    icon: const Icon(
                      Icons.thermostat_outlined,
                      size: 20,
                      color: Color(0xFF2C6B30),
                    ),
                    label: 'Temp',
                    value: '${climate.temperature.toInt()}°C',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildParamTile({
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EFE6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E5D7), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(width: 24, child: Center(child: icon)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology_outlined,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: AppSizes.s),
              Text(
                'Explanation & Advice',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          AppSizes.spaceM,
          Text(
            'Application Advice:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            result.applicationAdvice,
            style: const TextStyle(
              color: AppColors.textMedium,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          AppSizes.spaceM,
          Text(
            'Rationale:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            result.explanation,
            style: const TextStyle(
              color: AppColors.textMedium,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: PrimaryButton(
        text: 'Continue',
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}
