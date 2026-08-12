import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/history_controller.dart';
import '../models/history_item_model.dart';
import 'prediction_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryController controller;

  const HistoryScreen({super.key, required this.controller});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedType = 'All Types';
  String _selectedSort = 'Newest';

  static const _typeOptions = ['All Types', 'Crop', 'Fertilizer'];
  static const _sortOptions = ['Newest', 'Oldest', 'Highest Confidence'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HistoryItemModel> get _displayedList {
    var list = widget.controller.filteredHistory.toList();

    // Type filter
    if (_selectedType == 'Crop') {
      list = list.where((e) => e.historyType == HistoryType.crop).toList();
    } else if (_selectedType == 'Fertilizer') {
      list = list
          .where((e) => e.historyType == HistoryType.fertilizer)
          .toList();
    }

    // Sort
    if (_selectedSort == 'Newest') {
      list.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
    } else if (_selectedSort == 'Oldest') {
      list.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return a.createdAt!.compareTo(b.createdAt!);
      });
    } else if (_selectedSort == 'Highest Confidence') {
      list.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF7EE),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final list = _displayedList;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(context),
                _buildFilterRow(context),
                _buildResultCount(context, list.length),
                Expanded(
                  child: widget.controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                        )
                      : list.isEmpty
                      ? _buildEmptyState(context)
                      : _buildHistoryList(context, list),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: widget.controller.setSearchQuery,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'Search by crop, date, or location...',
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textLight,
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      widget.controller.setSearchQuery('');
                      setState(() {});
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textLight,
                      size: 18,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.primaryGreen.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          // Type Filter Dropdown
          Expanded(
            child: _buildDropdownButton(
              icon: Icons.tune_rounded,
              value: _selectedType,
              options: _typeOptions,
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
          ),
          const SizedBox(width: 12),
          // Sort Dropdown
          Expanded(
            child: _buildDropdownButton(
              icon: Icons.swap_vert_rounded,
              value: _selectedSort,
              options: _sortOptions,
              onChanged: (v) {
                if (v != null) setState(() => _selectedSort = v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownButton({
    required IconData icon,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.textMedium,
          ),
          isExpanded: true,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          items: options.map((opt) {
            return DropdownMenuItem(
              value: opt,
              child: Row(
                children: [
                  if (opt == value) ...[
                    Icon(icon, size: 16, color: AppColors.primaryGreen),
                    const SizedBox(width: 6),
                  ],
                  Text(opt),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildResultCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        '$count prediction${count == 1 ? '' : 's'} found',
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textMedium,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              size: 48,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No predictions found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<HistoryItemModel> list) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: list.length,
      separatorBuilder: (context, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildHistoryCard(context, list[index]);
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryItemModel item) {
    final isFertilizer = item.historyType == HistoryType.fertilizer;

    // Icon & gradient based on type/crop
    IconData cropIcon;
    List<Color> iconGradient;
    Color iconColor;

    switch (item.cropName.toLowerCase()) {
      case 'rice':
        cropIcon = Icons.eco;
        iconGradient = [const Color(0xFF388E3C), const Color(0xFF66BB6A)];
        iconColor = Colors.amber;
        break;
      case 'wheat':
        cropIcon = Icons.grain;
        iconGradient = [const Color(0xFFF57F17), const Color(0xFFFFB300)];
        iconColor = Colors.white;
        break;
      case 'maize':
      case 'corn':
        cropIcon = Icons.wb_twilight_rounded;
        iconGradient = [const Color(0xFFF9A825), const Color(0xFFFFD54F)];
        iconColor = Colors.white;
        break;
      case 'cotton':
        cropIcon = Icons.cloud_queue_rounded;
        iconGradient = [const Color(0xFF0288D1), const Color(0xFF4FC3F7)];
        iconColor = Colors.white;
        break;
      case 'groundnut':
        cropIcon = Icons.circle_outlined;
        iconGradient = [const Color(0xFF6D4C41), const Color(0xFFA1887F)];
        iconColor = Colors.white;
        break;
      default:
        if (isFertilizer) {
          cropIcon = Icons.science_rounded;
          iconGradient = [const Color(0xFF00838F), const Color(0xFF26C6DA)];
          iconColor = Colors.white;
        } else {
          cropIcon = Icons.grass_rounded;
          iconGradient = [const Color(0xFF2E7D32), const Color(0xFF4CAF50)];
          iconColor = Colors.amber;
        }
    }

    // Confidence as percentage (0–1 → 0–100)
    final confidencePct = item.confidenceScore <= 1.0
        ? (item.confidenceScore * 100).round()
        : item.confidenceScore.round();

    // Display recommendation text
    final recommendation = isFertilizer
        ? (item.recommendedFertilizer ?? 'Pending')
        : 'Recommended: ${item.cropName}';

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => PredictionDetailsScreen(item: item),
              ),
            )
            .then((_) {
              widget.controller.loadHistory();
            });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Title + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gradient Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: iconGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(cropIcon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  // Title & meta info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.cropName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Date
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.date,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Recommendation Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recommendation,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Confidence Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Confidence',
                    style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                  ),
                  Text(
                    '$confidencePct%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Confidence Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: item.confidenceScore <= 1.0
                      ? item.confidenceScore
                      : item.confidenceScore / 100.0,
                  backgroundColor: const Color(0xFFE8F5E9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryGreen,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
