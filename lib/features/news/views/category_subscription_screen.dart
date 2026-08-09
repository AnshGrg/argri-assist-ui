import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/news_controller.dart';
import '../models/news_category_model.dart';

class CategorySubscriptionScreen extends StatefulWidget {
  final NewsController controller;

  const CategorySubscriptionScreen({
    super.key,
    required this.controller,
  });

  @override
  State<CategorySubscriptionScreen> createState() => _CategorySubscriptionScreenState();
}

class _CategorySubscriptionScreenState extends State<CategorySubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchCategories();
    widget.controller.fetchSubscriptions();
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
          // Blur Filter Overlay
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
                child: Container(
                  color: AppColors.backgroundGreen.withValues(alpha: 0.70),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                _buildSubHeader(context),
                Expanded(
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) {
                      if (widget.controller.categories.isEmpty && widget.controller.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryGreen),
                        );
                      }

                      final categories = widget.controller.categories;
                      final subscribedIds = widget.controller.subscribedCategoryIds;

                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.l),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => AppSizes.spaceM,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSubscribed = subscribedIds.contains(category.id);
                          return _buildCategoryItem(category, isSubscribed);
                        },
                      );
                    },
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Topic Subscriptions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.xs),
      child: Text(
        'Subscribe to news categories to receive instant in-app advisory notifications.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMedium,
            ),
      ),
    );
  }

  Widget _buildCategoryItem(NewsCategoryModel category, bool isSubscribed) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.m),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.s),
            decoration: BoxDecoration(
              color: isSubscribed
                  ? AppColors.primaryGreen.withValues(alpha: 0.15)
                  : AppColors.lightGreen.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(category.name),
              color: isSubscribed ? AppColors.primaryGreen : AppColors.textMedium,
              size: AppSizes.iconMedium,
            ),
          ),
          AppSizes.spaceM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                ),
                if (category.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    category.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: isSubscribed,
            activeTrackColor: AppColors.primaryGreen,
            onChanged: (val) async {

              final success = await widget.controller.toggleSubscription(category.id);
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.controller.errorMessage ?? 'Failed to update subscription'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'weather alerts':
        return Icons.thunderstorm_outlined;
      case 'crop management':
        return Icons.eco_outlined;
      case 'fertilizer':
        return Icons.shopping_bag_outlined;
      case 'pest & disease':
        return Icons.bug_report_outlined;
      case 'government schemes':
        return Icons.account_balance_outlined;
      default:
        return Icons.newspaper_outlined;
    }
  }
}
