import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../predict_fertilizer/controllers/fertilizer_controller.dart';
import '../../predict_fertilizer/repos/fertilizer_repo.dart';
import '../../predict_fertilizer/views/predict_fertilizer_screen.dart';
import '../models/history_item_model.dart';

class PredictionDetailsScreen extends StatelessWidget {
  final HistoryItemModel item;

  const PredictionDetailsScreen({super.key, required this.item});

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCropPredictionCard(context),
                        AppSizes.spaceM,
                        _buildInputParametersCard(context),
                        AppSizes.spaceM,
                        _buildFertilizerRecommendationCard(context),
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
            'Prediction Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.primaryGreen,
              size: AppSizes.iconMedium,
            ),
            onPressed: () {
              // Trigger sharing details implementation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCropPredictionCard(BuildContext context) {
    // Choose icons
    IconData cropIcon = Icons.grass;
    Color iconColor = AppColors.primaryGreen;

    switch (item.cropName.toLowerCase()) {
      case 'maize':
        cropIcon = Icons.wb_twilight_rounded;
        iconColor = Colors.amber;
        break;
      case 'wheat':
        cropIcon = Icons.grain;
        iconColor = Colors.orangeAccent;
        break;
      case 'rice':
        cropIcon = Icons.eco;
        iconColor = Colors.green;
        break;
      case 'cotton':
        cropIcon = Icons.cloud_queue_rounded;
        iconColor = Colors.lightBlueAccent;
        break;
      case 'groundnut':
        cropIcon = Icons.lens_blur_rounded;
        iconColor = Colors.brown;
        break;
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop Prediction',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          AppSizes.spaceM,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.lightGreen,
                    radius: 24,
                    child: Icon(
                      cropIcon,
                      color: iconColor,
                      size: AppSizes.iconLarge,
                    ),
                  ),
                  const SizedBox(width: AppSizes.m),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.cropName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                      ),
                      Text(
                        item.date,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Confidence Score',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                  Text(
                    '${(item.confidenceScore * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.textGreenLink,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputParametersCard(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Input Parameters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          AppSizes.spaceM,
          // Two column parameters layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildParameterTextRow('Nitrogen (N)', item.nitrogen.toInt().toString()),
                    AppSizes.spaceS,
                    _buildParameterTextRow('Phosphorus (P)', item.phosphorus.toInt().toString()),
                    AppSizes.spaceS,
                    _buildParameterTextRow('Potassium (K)', item.potassium.toInt().toString()),
                    AppSizes.spaceS,
                    _buildParameterTextRow('Soil pH', item.ph.toString()),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.l),
              // Column 2
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildParameterTextRow('Temperature (°C)', item.temperature.toString()),
                    AppSizes.spaceS,
                    _buildParameterTextRow('Rainfall (mm)', item.rainfall.toString()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParameterTextRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMedium,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFertilizerRecommendationCard(BuildContext context) {
    final hasRecommendation = item.recommendedFertilizer != null;

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
            'Fertilizer Recommendation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          AppSizes.spaceM,
          if (hasRecommendation)
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined, // bag icon
                    color: AppColors.primaryGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSizes.m),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.recommendedFertilizer!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                    ),
                    Text(
                      'Dosage: ${item.fertilizerDosage ?? "N/A"}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMedium,
                          ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              children: [
                const Text(
                  'No fertilizer recommendations have been simulated for this prediction yet.',
                  style: TextStyle(color: AppColors.textMedium, fontSize: 13),
                ),
                AppSizes.spaceM,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final fertCtrl = FertilizerController(fertilizerRepo: MockFertilizerRepo());
                      fertCtrl.prefillFromCropResult(
                        item.cropName,
                        item.nitrogen,
                        item.phosphorus,
                        item.potassium,
                        item.ph,
                        item.temperature,
                        item.rainfall,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PredictFertilizerScreen(controller: fertCtrl),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Get Recommendation'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
