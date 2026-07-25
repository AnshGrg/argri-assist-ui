import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/fertilizer_controller.dart';
import 'fertilizer_recommendation_screen.dart';

class PredictFertilizerScreen extends StatefulWidget {
  final FertilizerController controller;

  const PredictFertilizerScreen({super.key, required this.controller});

  @override
  State<PredictFertilizerScreen> createState() => _PredictFertilizerScreenState();
}

class _PredictFertilizerScreenState extends State<PredictFertilizerScreen> {
  bool _showMoreParameters = true;

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
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                return Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLockedCropType(context),
                            AppSizes.spaceM,
                            _buildSoilTypeDropdown(context),
                            AppSizes.spaceM,
                            _buildNutrientsInputs(context),
                            AppSizes.spaceM,
                            if (_showMoreParameters) _buildOtherParameters(context),
                            AppSizes.spaceM,
                            _buildViewMoreToggle(context),
                            AppSizes.spaceL,
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
            'Predict Fertilizer',
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

  Widget _buildLockedCropType(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.l,
        vertical: AppSizes.m,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Crop Type',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
          ),
          Row(
            children: [
              Text(
                widget.controller.cropType,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
              ),
              const SizedBox(width: AppSizes.s),
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textLight,
                size: AppSizes.iconSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoilTypeDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.l,
        vertical: AppSizes.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Soil Type',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
          ),
          DropdownButton<String>(
            value: widget.controller.soilType,
            underline: const SizedBox(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMedium,
            ),
            dropdownColor: AppColors.backgroundGreen,
            onChanged: (String? newValue) {
              if (newValue != null) {
                widget.controller.setSoilType(newValue);
              }
            },
            items: <String>['Loamy', 'Sandy', 'Clayey', 'Silty']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientsInputs(BuildContext context) {
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
        children: [
          _buildNutrientRow(
            context: context,
            label: 'Nitrogen (N)',
            initialValue: widget.controller.nitrogen.toInt().toString(),
            onChanged: widget.controller.setNitrogen,
          ),
          const Divider(color: AppColors.glassBorder),
          _buildNutrientRow(
            context: context,
            label: 'Phosphorus (P)',
            initialValue: widget.controller.phosphorus.toInt().toString(),
            onChanged: widget.controller.setPhosphorus,
          ),
          const Divider(color: AppColors.glassBorder),
          _buildNutrientRow(
            context: context,
            label: 'Potassium (K)',
            initialValue: widget.controller.potassium.toInt().toString(),
            onChanged: widget.controller.setPotassium,
          ),
          const Divider(color: AppColors.glassBorder),
          _buildNutrientRow(
            context: context,
            label: 'Soil pH',
            initialValue: widget.controller.ph.toString(),
            onChanged: widget.controller.setPh,
            isDecimal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow({
    required BuildContext context,
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    bool isDecimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
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
          SizedBox(
            width: 70,
            height: 36,
            child: TextFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherParameters(BuildContext context) {
    return Column(
      children: [
        _buildParameterRow(
          context: context,
          label: 'Temperature (°C)',
          value: widget.controller.temperature.toString(),
          isFetching: widget.controller.isAutoFetchingTemperature,
          onFetch: widget.controller.autoFetchTemperature,
        ),
        AppSizes.spaceM,
        _buildParameterRow(
          context: context,
          label: 'Humidity (%)',
          value: widget.controller.humidity.toInt().toString(),
          isFetching: widget.controller.isAutoFetchingHumidity,
          onFetch: widget.controller.autoFetchHumidity,
        ),
        AppSizes.spaceM,
        _buildParameterRow(
          context: context,
          label: 'Rainfall (mm)',
          value: widget.controller.rainfall.toString(),
          isFetching: widget.controller.isAutoFetchingRainfall,
          onFetch: widget.controller.autoFetchRainfall,
        ),
      ],
    );
  }

  Widget _buildParameterRow({
    required BuildContext context,
    required String label,
    required String value,
    required bool isFetching,
    required VoidCallback onFetch,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.l,
        vertical: AppSizes.m,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.8),
          width: 1,
        ),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.s,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: const Text(
                  'Auto-fetched',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.s),
              GestureDetector(
                onTap: isFetching ? null : onFetch,
                child: const Icon(
                  Icons.refresh_rounded,
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

  Widget _buildViewMoreToggle(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showMoreParameters = !_showMoreParameters;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _showMoreParameters ? 'View Less' : 'View More',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              _showMoreParameters
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: PrimaryButton(
        text: 'Predict Fertilizer',
        icon: Icons.shopping_bag_outlined,
        isLoading: widget.controller.isLoading,
        onPressed: () async {
          await widget.controller.predictFertilizer();
          if (context.mounted && widget.controller.predictionResult != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FertilizerRecommendationScreen(
                  controller: widget.controller,
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
        title: const Text('About Fertilizer Prediction'),
        content: const Text(
          'Input your soil nutrient specifications and environmental conditions '
          'to calculate the recommended fertilizer application amount and details.',
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
}
