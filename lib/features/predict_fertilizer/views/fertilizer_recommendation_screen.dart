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
                        _buildInstructionsCard(context),
                        AppSizes.spaceM,
                        _buildNotesCard(context),
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
          Text(
            'Fertilizer Recommendation',
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
                Icons.shopping_bag_outlined, // bag icon
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
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSizes.spaceL,
          Text(
            'Dosage',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSizes.spaceXs,
          Text(
            result.dosage,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context) {
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
            'Apply ${result.recommendedFertilizer} in two equal splits:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
          ),
          AppSizes.spaceS,
          ...result.instructions.map((inst) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        inst,
                        style: const TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
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
            'Notes',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
          ),
          AppSizes.spaceS,
          ...result.notes.map((note) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        note,
                        style: const TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
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
          // Navigate back to the home screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}
