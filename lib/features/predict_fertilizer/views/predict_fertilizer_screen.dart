import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/nutrient_input_field.dart';
import '../../predict/controllers/predict_controller.dart'; // for LocationOption
import '../controllers/fertilizer_controller.dart';
import 'fertilizer_recommendation_screen.dart';

class PredictFertilizerScreen extends StatefulWidget {
  final FertilizerController controller;

  const PredictFertilizerScreen({super.key, required this.controller});

  @override
  State<PredictFertilizerScreen> createState() => _PredictFertilizerScreenState();
}

class _PredictFertilizerScreenState extends State<PredictFertilizerScreen> {
  late final TextEditingController _phController;

  @override
  void initState() {
    super.initState();
    _phController = TextEditingController(
      text: widget.controller.isCropTypeLocked
          ? widget.controller.ph.toStringAsFixed(1)
          : '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.fetchCrops();
    });
  }

  @override
  void dispose() {
    _phController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF7EE),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCropSection(context),
                        const SizedBox(height: 20),
                        _buildNpkSection(context),
                        const SizedBox(height: 20),
                        _buildLocationSection(context),
                        const SizedBox(height: 20),
                        _buildSeasonSection(context),
                        const SizedBox(height: 20),
                        _buildPhSection(context),
                        const SizedBox(height: 20),
                        _buildClimateNotice(context),
                        const SizedBox(height: 28),
                        _buildSubmitButton(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                'Fertilizer Prediction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Enter your field details to get fertilizer recommendations',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Crop Section ─────────────────────────────────────────────────────────

  Widget _buildCropSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Crop',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.grass_rounded,
                  color: AppColors.primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              if (widget.controller.isCropTypeLocked)
                // Locked crop — prefilled from crop prediction
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.controller.cropType[0].toUpperCase() +
                            widget.controller.cropType.substring(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'From crop result',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.textLight,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                // Editable crop dropdown
                Expanded(
                  child: widget.controller.isFetchingCrops
                      ? const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Loading crops...',
                              style: TextStyle(fontSize: 13, color: AppColors.textLight),
                            ),
                          ],
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: widget.controller.crops.contains(widget.controller.cropType)
                                ? widget.controller.cropType
                                : (widget.controller.crops.isNotEmpty
                                    ? widget.controller.crops.first
                                    : widget.controller.cropType),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textLight,
                              size: 20,
                            ),
                            isExpanded: true,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                widget.controller.setCropType(newValue);
                              }
                            },
                            items: (widget.controller.crops.isNotEmpty
                                    ? widget.controller.crops
                                    : [widget.controller.cropType])
                                .map<DropdownMenuItem<String>>((crop) {
                              return DropdownMenuItem<String>(
                                value: crop,
                                child: Text(
                                  crop[0].toUpperCase() + crop.substring(1),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── NPK Section ──────────────────────────────────────────────────────────

  Widget _buildNpkSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NPK Ratio',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: NutrientInputField(
                label: 'Nitrogen (N)',
                hintText: 'e.g., 90',
                initialValue: widget.controller.isCropTypeLocked
                    ? widget.controller.nitrogen.toInt().toString()
                    : null,
                onChanged: widget.controller.setNitrogen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NutrientInputField(
                label: 'Phosphorus (P)',
                hintText: 'e.g., 42',
                initialValue: widget.controller.isCropTypeLocked
                    ? widget.controller.phosphorus.toInt().toString()
                    : null,
                onChanged: widget.controller.setPhosphorus,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NutrientInputField(
                label: 'Potassium (K)',
                hintText: 'e.g., 43',
                initialValue: widget.controller.isCropTypeLocked
                    ? widget.controller.potassium.toInt().toString()
                    : null,
                onChanged: widget.controller.setPotassium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Nitrogen-Phosphorus-Potassium ratio (kg/ha)',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  // ─── Location Section ─────────────────────────────────────────────────────

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location / Field',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE4EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFE91E63),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<LocationOption>(
                    value: widget.controller.selectedLocation,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        widget.controller.setLocation(newValue);
                      }
                    },
                    items: FertilizerController.locationOptions
                        .map<DropdownMenuItem<LocationOption>>((loc) {
                      return DropdownMenuItem<LocationOption>(
                        value: loc,
                        child: Text(loc.displayName),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Season Section ───────────────────────────────────────────────────────

  Widget _buildSeasonSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Season',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  color: Color(0xFFFFB300),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.controller.selectedSeason,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        widget.controller.setSeason(newValue);
                      }
                    },
                    items: FertilizerController.seasonOptions
                        .map<DropdownMenuItem<String>>((season) {
                      return DropdownMenuItem<String>(
                        value: season,
                        child: Text(season),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Soil pH Section ──────────────────────────────────────────────────────

  Widget _buildPhSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Soil pH',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F7FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.science_rounded,
                  color: Color(0xFF00ACC1),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _phController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: widget.controller.setPh,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g., 6.5',
                    hintStyle: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Optimal range: 6.0 – 7.0',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  // ─── Climate Notice ───────────────────────────────────────────────────────

  Widget _buildClimateNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('☀️', style: GoogleFonts.notoColorEmoji(fontSize: 18)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Climate data (temperature, humidity, rainfall) will be automatically fetched from NASA POWER 2025 API based on your selected location and season.',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Submit Button ────────────────────────────────────────────────────────

  String? _validateInputs() {
    final n = widget.controller.nitrogen;
    final p = widget.controller.phosphorus;
    final k = widget.controller.potassium;
    final ph = widget.controller.ph;

    if (n < 10 || n > 130) {
      return 'Nitrogen (N) must be between 10 and 130 kg/ha.';
    }
    if (p < 10 || p > 140) {
      return 'Phosphorus (P) must be between 10 and 140 kg/ha.';
    }
    if (k < 10 || k > 200) {
      return 'Potassium (K) must be between 10 and 200 kg/ha.';
    }
    if (ph < 4 || ph > 9) {
      return 'Soil pH must be between 4 and 9.';
    }
    return null;
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
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
        onPressed: widget.controller.isLoading
            ? null
            : () async {
                final validationError = _validateInputs();
                if (validationError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(validationError),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await widget.controller.predictFertilizer();
                if (context.mounted &&
                    widget.controller.predictionResult != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FertilizerRecommendationScreen(
                        controller: widget.controller,
                        result: widget.controller.predictionResult!,
                      ),
                    ),
                  );
                } else if (context.mounted &&
                    widget.controller.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(widget.controller.errorMessage!)),
                  );
                }
              },
        child: widget.controller.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Get Fertilizer Recommendation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
