import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/token_storage.dart';
import '../../predict/controllers/predict_controller.dart';
import '../../predict_fertilizer/controllers/fertilizer_controller.dart';
import '../../predict_fertilizer/repos/fertilizer_repo.dart';
import '../../predict_fertilizer/views/predict_fertilizer_screen.dart';
import '../models/history_item_model.dart';
import '../repos/history_repo.dart';

class PredictionDetailsScreen extends StatefulWidget {
  final HistoryItemModel item;

  const PredictionDetailsScreen({super.key, required this.item});

  @override
  State<PredictionDetailsScreen> createState() => _PredictionDetailsScreenState();
}

class _PredictionDetailsScreenState extends State<PredictionDetailsScreen> {
  late HistoryItemModel _item;
  bool _isLoadingDetail = true;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoadingDetail = true;
      _detailError = null;
    });

    // Get token
    String? token;
    final saved = await TokenStorage.loadTokens();
    token = saved?.access;

    final repo = HttpHistoryRepo();

    try {
      HistoryItemModel? detail;
      if (_item.historyType == HistoryType.crop) {
        detail = await repo.getCropHistoryDetail(_item.id, token: token);
      } else {
        detail = await repo.getFertilizerHistoryDetail(_item.id, token: token);
      }

      if (detail != null && mounted) {
        setState(() {
          _item = detail!;
          _isLoadingDetail = false;
        });
      } else {
        setState(() {
          _isLoadingDetail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detailError = '$e'.replaceAll('Exception: ', '');
          _isLoadingDetail = false;
        });
      }
    }
  }

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
                  child: _isLoadingDetail
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_detailError != null)
                                _buildErrorBanner(context),
                              _buildCropPredictionCard(context),
                              AppSizes.spaceM,
                              _buildInputParametersCard(context),
                              AppSizes.spaceM,
                              if (_item.advice != null && _item.advice!.isNotEmpty)
                                ...[
                                  _buildAdviceCard(context),
                                  AppSizes.spaceM,
                                ],
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

  Widget _buildErrorBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.m),
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        _detailError!,
        style: const TextStyle(color: Colors.red, fontSize: 13),
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
            _item.historyType == HistoryType.crop
                ? 'Crop Prediction Details'
                : 'Fertilizer Details',
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

    switch (_item.cropName.toLowerCase()) {
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
            _item.historyType == HistoryType.crop
                ? 'Crop Prediction'
                : 'Fertilizer Prediction',
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
                        _item.cropName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                      ),
                      Text(
                        _item.date,
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
                    '${(_item.confidenceScore * 100).toInt()}%',
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
                    _buildParameterTextRow('Nitrogen (N)', _item.nitrogen.toInt().toString()),
                    AppSizes.spaceS,
                    _buildParameterTextRow('Phosphorus (P)', _item.phosphorus.toInt().toString()),
                    AppSizes.spaceS,
                    _buildParameterTextRow('Potassium (K)', _item.potassium.toInt().toString()),
                    AppSizes.spaceS,
                    _buildParameterTextRow('Soil pH', _item.ph.toString()),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.l),
              // Column 2
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildParameterTextRow('Temperature (°C)', _item.temperature.toString()),
                    AppSizes.spaceS,
                    _buildParameterTextRow('Humidity (%)', _item.humidity.toString()),
                    AppSizes.spaceS,
                    _buildParameterTextRow('Rainfall (mm)', _item.rainfall.toString()),
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

  Widget _buildAdviceCard(BuildContext context) {
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
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: AppSizes.s),
              Text(
                'Expert Advice',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
              ),
            ],
          ),
          AppSizes.spaceM,
          Text(
            _item.advice!,
            style: const TextStyle(
              color: AppColors.textMedium,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerRecommendationCard(BuildContext context) {
    final hasRecommendation = _item.recommendedFertilizer != null;

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
                      _item.recommendedFertilizer!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                    ),
                    Text(
                      'Dosage: ${_item.fertilizerDosage ?? "N/A"}',
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
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      String? token;
                      final saved = await TokenStorage.loadTokens();
                      token = saved?.access;

                      final fertCtrl = FertilizerController(
                        fertilizerRepo: HttpFertilizerRepo(),
                        userToken: token,
                      );
                      fertCtrl.prefillFromCropResult(
                        crop: _item.cropName,
                        n: _item.nitrogen,
                        p: _item.phosphorus,
                        k: _item.potassium,
                        phVal: _item.ph,
                        location: PredictController.locationOptions[0],
                        season: 'Monsoon',
                      );
                      if (mounted) {
                        navigator.push(
                          MaterialPageRoute(
                            builder: (context) => PredictFertilizerScreen(controller: fertCtrl),
                          ),
                        );
                      }
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
