import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../models/prediction_result_model.dart';

class PredictCropResultScreen extends StatelessWidget {
  final PredictionResultModel result;

  const PredictCropResultScreen({super.key, required this.result});

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
                        AppSizes.spaceXl,
                        _buildDescriptionCard(context),
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
          // Empty space to balance the back button
          const SizedBox(width: AppSizes.iconExtraLarge),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    // Styling the crop illustration avatar
    Color cropIconColor = Colors.orangeAccent;
    IconData cropIcon = Icons.grain_rounded;

    if (result.cropName.toLowerCase() == 'maize') {
      cropIcon = Icons.wb_twilight_rounded; // stylized seed/maize look
      cropIconColor = Colors.amber;
    } else if (result.cropName.toLowerCase() == 'rice') {
      cropIcon = Icons.eco;
      cropIconColor = Colors.green;
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.xxl,
        horizontal: AppSizes.xl,
      ),
      child: Column(
        children: [
          // Styled Crop Image Container
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryGreen,
                width: 3.0,
              ),
              color: AppColors.lightGreen,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Center(
                child: Icon(
                  cropIcon,
                  size: 72,
                  color: cropIconColor,
                ),
              ),
            ),
          ),
          AppSizes.spaceL,
          Text(
            'Best Crop for Your Field',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSizes.spaceS,
          Text(
            result.cropName,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSizes.spaceL,
          Text(
            'Confidence Score',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSizes.spaceXs,
          Text(
            '${(result.confidenceScore * 100).toInt()}%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSizes.spaceM,
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: result.confidenceScore,
              minHeight: 10,
              backgroundColor: AppColors.white.withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
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
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
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
            child: Text(
              result.description,
              style: const TextStyle(
                color: AppColors.textMedium,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
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
            // Future navigation to Fertilizer Prediction screen
          },
        ),
        AppSizes.spaceM,
        SecondaryButton(
          text: 'Skip / Back to Home',
          onPressed: () {
            // Pop back to root dashboard (main.dart screen)
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }
}
