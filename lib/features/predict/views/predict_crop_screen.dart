import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/nutrient_input_field.dart';
import '../controllers/predict_controller.dart';
import 'predict_crop_result_screen.dart';

class PredictCropScreen extends StatefulWidget {
  final PredictController controller;

  const PredictCropScreen({super.key, required this.controller});

  @override
  State<PredictCropScreen> createState() => _PredictCropScreenState();
}

class _PredictCropScreenState extends State<PredictCropScreen> {
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
          // Screen Content
          SafeArea(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                return Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNutrientsSection(context),
                            AppSizes.spaceXl,
                            _buildParametersSection(context),
                            AppSizes.spaceXl,
                            _buildInfoNotice(context),
                          ],
                        ),
                      ),
                    ),
                    _buildFooterButton(context),
                  ],
                );
              },
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
            'Predict Crop',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primaryGreen,
              size: AppSizes.iconMedium,
            ),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soil Nutrients (kg/ha)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
        ),
        AppSizes.spaceM,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: NutrientInputField(
                label: 'Nitrogen (N)',
                initialValue: widget.controller.nitrogen.toInt().toString(),
                onChanged: widget.controller.setNitrogen,
              ),
            ),
            AppSizes.spaceM,
            Expanded(
              child: NutrientInputField(
                label: 'Phosphorus (P)',
                initialValue: widget.controller.phosphorus.toInt().toString(),
                onChanged: widget.controller.setPhosphorus,
              ),
            ),
            AppSizes.spaceM,
            Expanded(
              child: NutrientInputField(
                label: 'Potassium (K)',
                initialValue: widget.controller.potassium.toInt().toString(),
                onChanged: widget.controller.setPotassium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParametersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other Parameters',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
        ),
        AppSizes.spaceM,
        _buildParameterItem(
          context: context,
          label: 'Temperature (°C)',
          value: widget.controller.temperature.toString(),
          isFetching: widget.controller.isAutoFetchingTemperature,
          badgeText: 'Auto-fetched',
          actionIcon: Icons.refresh_rounded,
          onActionTap: widget.controller.autoFetchTemperature,
        ),
        AppSizes.spaceM,
        _buildParameterItem(
          context: context,
          label: 'Rainfall (mm)',
          value: widget.controller.rainfall.toString(),
          isFetching: widget.controller.isAutoFetchingRainfall,
          badgeText: 'Auto-fetched',
          actionIcon: Icons.refresh_rounded,
          onActionTap: widget.controller.autoFetchRainfall,
        ),
        AppSizes.spaceM,
        _buildParameterItem(
          context: context,
          label: 'Soil pH',
          value: widget.controller.ph.toString(),
          isFetching: false,
          actionIcon: Icons.edit_outlined,
          onActionTap: () => _showPhEditDialog(context),
        ),
      ],
    );
  }

  Widget _buildParameterItem({
    required BuildContext context,
    required String label,
    required String value,
    required bool isFetching,
    String? badgeText,
    required IconData actionIcon,
    required VoidCallback onActionTap,
  }) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
          ),
          Row(
            children: [
              if (isFetching)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  ),
                )
              else
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                ),
              const SizedBox(width: AppSizes.s),
              if (badgeText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.s,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.s),
              ],
              GestureDetector(
                onTap: isFetching ? null : onActionTap,
                child: Icon(
                  actionIcon,
                  color: AppColors.textMedium,
                  size: AppSizes.iconMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.l),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            color: AppColors.primaryGreen,
            size: AppSizes.iconLarge,
          ),
          SizedBox(width: AppSizes.m),
          Expanded(
            child: Text(
              'Weather data is auto-fetched from your location and can be edited.',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
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
        text: 'Predict Crop',
        icon: Icons.eco_outlined,
        isLoading: widget.controller.isLoading,
        onPressed: () async {
          await widget.controller.predictCrop();
          if (context.mounted && widget.controller.predictionResult != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PredictCropResultScreen(
                  result: widget.controller.predictionResult!,
                ),
              ),
            );
          } else if (context.mounted && widget.controller.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.controller.errorMessage!)),
            );
          }
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Crop Prediction'),
        content: const Text(
          'This tool predicts the most suitable crop to grow based on soil nutrients '
          '(Nitrogen, Phosphorus, Potassium) and climatic parameters (Temperature, Rainfall, pH).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showPhEditDialog(BuildContext context) {
    final textController = TextEditingController(text: widget.controller.ph.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Soil pH'),
        content: TextField(
          controller: textController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Soil pH (0.0 - 14.0)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.controller.setPh(textController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


}
