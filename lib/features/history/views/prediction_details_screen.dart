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
  State<PredictionDetailsScreen> createState() =>
      _PredictionDetailsScreenState();
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
      backgroundColor: const Color(0xFFEDF7EE),
      body: SafeArea(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_detailError != null) _buildErrorBanner(context),
                          _buildCropPredictionCard(context),
                          const SizedBox(height: 24),
                          _buildInputParametersCard(context),
                          const SizedBox(height: 24),
                          if (_item.advice != null &&
                              _item.advice!.isNotEmpty) ...[
                            _buildAdviceCard(context),
                            const SizedBox(height: 24),
                          ],
                          _buildFertilizerRecommendationCard(context),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
            ),
          ],
        ),
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
          Text(
            _item.historyType == HistoryType.crop
                ? 'Crop Prediction Details'
                : 'Fertilizer Details',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropPredictionCard(BuildContext context) {
    // Choose icons
    IconData cropIcon = Icons.grass_rounded;
    Color cropIconColor = AppColors.primaryGreen;

    switch (_item.cropName.toLowerCase()) {
      case 'maize':
        cropIcon = Icons.wb_twilight_rounded;
        cropIconColor = const Color(0xFFF9A825);
        break;
      case 'wheat':
        cropIcon = Icons.grain;
        cropIconColor = const Color(0xFFF57F17);
        break;
      case 'rice':
        cropIcon = Icons.eco;
        cropIconColor = const Color(0xFF388E3C);
        break;
      case 'cotton':
        cropIcon = Icons.cloud_queue_rounded;
        cropIconColor = Colors.lightBlueAccent;
        break;
      case 'groundnut':
        cropIcon = Icons.lens_blur_rounded;
        cropIconColor = Colors.brown;
        break;
    }

    final confPct = (_item.confidenceScore * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                'Prediction Result',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                _item.cropName[0].toUpperCase() + _item.cropName.substring(1),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _item.date,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
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
                  value: _item.confidenceScore,
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

  Widget _buildInputParametersCard(BuildContext context) {
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
                    value: '${_item.nitrogen.toInt()} kg/ha',
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
                    value: '${_item.ph}',
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
                    value: '${_item.phosphorus.toInt()} kg/ha',
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
                    value: '${_item.humidity.toInt()}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                    value: '${_item.potassium.toInt()} kg/ha',
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
                    value: '${_item.temperature.toInt()}°C',
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
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.primaryGreen,
                size: 20,
              ),
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
                            builder: (context) =>
                                PredictFertilizerScreen(controller: fertCtrl),
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
