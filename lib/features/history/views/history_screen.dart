import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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

  @override
  void initState() {
    super.initState();
    widget.controller.loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                return Column(
                  children: [
                    _buildAppBar(context),
                    _buildSearchBar(context),
                    Expanded(
                      child: widget.controller.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: AppColors.primaryGreen),
                            )
                          : widget.controller.filteredHistory.isEmpty
                              ? _buildEmptyState(context)
                              : _buildHistoryList(context, widget.controller.filteredHistory),
                    ),
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
        horizontal: AppSizes.xl,
        vertical: AppSizes.s,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Prediction History',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.primaryGreen,
              size: AppSizes.iconMedium,
            ),
            onPressed: () {
              // Trigger filter dialog implementation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.xl,
        vertical: AppSizes.s,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.8),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.textLight),
            const SizedBox(width: AppSizes.s),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: widget.controller.setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search crops or fertilizers...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                ),
                style: const TextStyle(color: AppColors.textDark, fontSize: 14),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  widget.controller.setSearchQuery('');
                },
                child: const Icon(Icons.close_rounded, color: AppColors.textLight),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history_toggle_off_rounded,
            size: 64,
            color: AppColors.textLight,
          ),
          AppSizes.spaceM,
          Text(
            'No history matches found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMedium,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<HistoryItemModel> list) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.xl),
      itemCount: list.length,
      separatorBuilder: (context, index) => AppSizes.spaceM,
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildHistoryItem(context, item);
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, HistoryItemModel item) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.m,
          vertical: AppSizes.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.lightGreen,
          radius: 24,
          child: Icon(
            cropIcon,
            color: iconColor,
            size: AppSizes.iconLarge,
          ),
        ),
        title: Text(
          item.cropName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
        ),
        subtitle: Text(
          item.date,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.recommendedFertilizer ?? 'Pending',
                  style: const TextStyle(
                    color: AppColors.textGreenLink,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (item.fertilizerDosage != null)
                  Text(
                    item.fertilizerDosage!,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSizes.s),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PredictionDetailsScreen(item: item),
            ),
          ).then((_) {
            // reload list in case updates were made
            widget.controller.loadHistory();
          });
        },
      ),
    );
  }
}
