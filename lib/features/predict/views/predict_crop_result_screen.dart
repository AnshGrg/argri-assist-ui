import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBestRecommendationSection(context),
                    const SizedBox(height: 24),
                    if (result.alternativeCrops.isNotEmpty) ...[
                      _buildAlternativeOptionsSection(context),
                      const SizedBox(height: 24),
                    ],
                    _buildFieldConditionsSection(context),
                    const SizedBox(height: 24),
                    _buildExplanationSection(context),
                    const SizedBox(height: 16),
                    _buildAdviceSection(context),
                    const SizedBox(height: 28),
                    _buildActionButtons(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
            'Prediction Result',
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

  Widget _buildBestRecommendationSection(BuildContext context) {
    final confPct = result.confidence.round();

    // Helper for crop icon
    IconData cropIcon = Icons.grass_rounded;
    Color cropIconColor = AppColors.primaryGreen;

    final cropLower = result.recommendedCrop.toLowerCase();
    if (cropLower == 'rice') {
      cropIcon = Icons.eco;
      cropIconColor = const Color(0xFF388E3C);
    } else if (cropLower == 'wheat') {
      cropIcon = Icons.grain;
      cropIconColor = const Color(0xFFF57F17);
    } else if (cropLower == 'maize' || cropLower == 'corn') {
      cropIcon = Icons.wb_twilight_rounded;
      cropIconColor = const Color(0xFFF9A825);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Best Crop Recommendation',
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
                result.recommendedCrop[0].toUpperCase() +
                    result.recommendedCrop.substring(1),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Best crop for your field',
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

  Widget _buildAlternativeOptionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alternative Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: result.alternativeCrops.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final alt = result.alternativeCrops[index];
              return _buildAlternativeCard(context, alt);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeCard(BuildContext context, AlternativeCrop alt) {
    IconData altIcon = Icons.eco_outlined;
    final altLower = alt.crop.toLowerCase();
    if (altLower == 'wheat') {
      altIcon = Icons.grain_rounded;
    } else if (altLower == 'maize' || altLower == 'corn') {
      altIcon = Icons.wb_twilight_rounded;
    } else if (altLower == 'barley') {
      altIcon = Icons.circle;
    }

    final altConf = alt.confidence.round();

    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(altIcon, size: 28, color: AppColors.primaryGreen),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$altConf%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            alt.crop[0].toUpperCase() + alt.crop.substring(1),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          const Row(
            children: [
              Text(
                'Tap to select',
                style: TextStyle(fontSize: 10, color: AppColors.textLight),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_rounded,
                size: 10,
                color: AppColors.textLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldConditionsSection(BuildContext context) {
    final climate = result.climateData;
    final nVal = controller.nitrogen.toInt();
    final pVal = controller.phosphorus.toInt();
    final kVal = controller.potassium.toInt();
    final phVal = controller.ph.toStringAsFixed(1);

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
                    value: '$nVal kg/ha',
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
                    value: phVal,
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
                    value: '$pVal kg/ha',
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
                    value: '$kVal kg/ha',
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

  Widget _buildExplanationSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.psychology_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Explanation',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  result.explanation,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Agricultural Advice',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  result.advice,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    height: 1.45,
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
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              final fertilizerController = FertilizerController(
                fertilizerRepo: HttpFertilizerRepo(),
                userToken: controller.userToken,
              );
              fertilizerController.prefillFromCropResult(
                crop: result.recommendedCrop,
                n: controller.nitrogen,
                p: controller.phosphorus,
                k: controller.potassium,
                phVal: controller.ph,
                location: controller.selectedLocation!,
                season: controller.selectedSeason,
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PredictFertilizerScreen(controller: fertilizerController),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue to Fertilizer Prediction',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textDark,
              side: BorderSide(
                color: AppColors.textLight.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              'Back to Home',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
