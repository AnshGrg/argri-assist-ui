import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
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
      body: Stack(
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
          // Screen UI
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                    child: Column(
                      children: [
                        _buildRecommendationCard(context),
                        AppSizes.spaceM,
                        _buildNpkAnalysisCard(context),
                        AppSizes.spaceM,
                        _buildClimateDataCard(context),
                        AppSizes.spaceM,
                        _buildExplanationCard(context),
                        AppSizes.spaceL,
                      ],
                    ),
                  ),
                ),
                _buildFooterButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.l,
        vertical: AppSizes.s,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: AppSizes.iconExtraLarge,
              color: AppColors.textDark,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Fertilizer Recommendation',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
            ),
          ),
          const SizedBox(width: AppSizes.iconExtraLarge),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.xl,
        horizontal: AppSizes.l,
      ),
      child: Column(
        children: [
          // Fertilizer Bag Circle
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGreen,
              border: Border.all(
                color: AppColors.primaryGreen,
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 44,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          AppSizes.spaceM,
          Text(
            'Recommended Fertilizer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSizes.spaceXs,
          Text(
            result.recommendedFertilizer,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSizes.spaceL,
          Text(
            'Confidence Score',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSizes.spaceXs,
          Text(
            '${result.confidence.toStringAsFixed(2)}%',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNpkAnalysisCard(BuildContext context) {
    final analysis = result.npkAnalysis;
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
          Text(
            'Soil Nutrient Status (NPK & pH)',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          AppSizes.spaceM,
          _buildNpkStatusRow('Nitrogen (N)', analysis.nitrogenStatus),
          const Divider(color: AppColors.glassBorder),
          _buildNpkStatusRow('Phosphorus (P)', analysis.phosphorusStatus),
          const Divider(color: AppColors.glassBorder),
          _buildNpkStatusRow('Potassium (K)', analysis.potassiumStatus),
          const Divider(color: AppColors.glassBorder),
          _buildNpkStatusRow('Soil pH', analysis.phStatus),
        ],
      ),
    );
  }

  Widget _buildNpkStatusRow(String label, String status) {
    Color badgeColor = Colors.grey;
    Color textColor = Colors.white;

    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'optimal' || lowerStatus == 'neutral') {
      badgeColor = AppColors.primaryGreen;
    } else if (lowerStatus == 'high') {
      badgeColor = Colors.orange;
    } else if (lowerStatus == 'low') {
      badgeColor = Colors.redAccent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w500),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateDataCard(BuildContext context) {
    final climate = result.climateData;
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
          Text(
            'Climate Data (${climate.season})',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          AppSizes.spaceS,
          _buildClimateRow('Average Temperature', '${climate.temperature}°C'),
          const Divider(color: AppColors.glassBorder),
          _buildClimateRow('Humidity', '${climate.humidity}%'),
          const Divider(color: AppColors.glassBorder),
          _buildClimateRow('Seasonal Rainfall', '${climate.rainfall} mm'),
          AppSizes.spaceS,
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              'Source: ${climate.source}',
              style: const TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
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
              const Icon(Icons.psychology_outlined, color: AppColors.primaryGreen),
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
        text: 'Save to History',
        icon: Icons.check_circle_outline_rounded,
        onPressed: () {
          controller.saveToHistory();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recommendation successfully saved to History!'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}
