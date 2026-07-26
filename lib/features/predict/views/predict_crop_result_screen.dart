import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../predict_fertilizer/controllers/fertilizer_controller.dart';
import '../../predict_fertilizer/repos/fertilizer_repo.dart';
import '../../predict_fertilizer/views/predict_fertilizer_screen.dart';
import '../controllers/predict_controller.dart';
import '../models/prediction_result_model.dart';

class PredictCropResultScreen extends StatelessWidget {
  final PredictController controller;
  final PredictionResultModel result;

  const PredictCropResultScreen({
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
                        _buildResultCard(context),
                        AppSizes.spaceM,
                        if (result.alternativeCrops.isNotEmpty) ...[
                          _buildAlternativeCropsCard(context),
                          AppSizes.spaceM,
                        ],
                        _buildClimateDataCard(context),
                        AppSizes.spaceM,
                        _buildDescriptionCard(context),
                        AppSizes.spaceM,
                        _buildAdviceCard(context),
                        AppSizes.spaceXl,
                        _buildActionButtons(context),
                        AppSizes.spaceL,
                      ],
                    ),
                  ),
                ),
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
          Text(
            'Predict Crop – Result',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          const SizedBox(width: AppSizes.iconExtraLarge),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    Color cropIconColor = Colors.orangeAccent;
    IconData cropIcon = Icons.grain_rounded;

    final cropLower = result.recommendedCrop.toLowerCase();
    if (cropLower == 'maize') {
      cropIcon = Icons.wb_twilight_rounded;
      cropIconColor = Colors.amber;
    } else if (cropLower == 'rice') {
      cropIcon = Icons.eco;
      cropIconColor = Colors.green;
    } else if (cropLower == 'jute') {
      cropIcon = Icons.grass;
      cropIconColor = Colors.lightGreen;
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.xl,
        horizontal: AppSizes.l,
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryGreen,
                width: 2.5,
              ),
              color: AppColors.lightGreen,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Center(
                child: Icon(
                  cropIcon,
                  size: 56,
                  color: cropIconColor,
                ),
              ),
            ),
          ),
          AppSizes.spaceM,
          Text(
            'Best Crop for Your Field',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSizes.spaceXs,
          Text(
            result.recommendedCrop.toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSizes.spaceM,
          Text(
            'Confidence Score',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          AppSizes.spaceS,
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: result.confidence / 100.0,
              minHeight: 8,
              backgroundColor: AppColors.white.withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeCropsCard(BuildContext context) {
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
            'Alternative Crops',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          AppSizes.spaceS,
          ...result.alternativeCrops.map((alt) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    alt.crop.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${alt.confidence.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
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

  Widget _buildDescriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.s),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: AppColors.primaryGreen,
              size: AppSizes.iconLarge,
            ),
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explanation',
                  style: TextStyle(
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
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.s),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primaryGreen,
              size: AppSizes.iconLarge,
            ),
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agricultural Advice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  result.advice,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          text: 'Continue to Fertilizer Prediction',
          icon: Icons.arrow_forward_rounded,
          onPressed: () {
            final fertilizerController = FertilizerController(
              fertilizerRepo: HttpFertilizerRepo(),
            );
            fertilizerController.prefillFromCropResult(
              crop: result.recommendedCrop,
              n: controller.nitrogen,
              p: controller.phosphorus,
              k: controller.potassium,
              phVal: controller.ph,
              location: controller.selectedLocation,
              season: controller.selectedSeason,
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PredictFertilizerScreen(
                  controller: fertilizerController,
                ),
              ),
            );
          },
        ),
        AppSizes.spaceM,
        SecondaryButton(
          text: 'Skip / Back to Home',
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }
}
