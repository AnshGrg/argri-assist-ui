import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/news_controller.dart';
import '../models/news_article_model.dart';
import 'news_detail_screen.dart';

import 'category_subscription_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  final NewsController controller;
  final bool isStaff;

  const NewsFeedScreen({
    super.key,
    required this.controller,
    this.isStaff = false,
  });

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.init();
    });
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
                _buildSearchBar(),
                _buildCategoryChips(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) {
                      if (widget.controller.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryGreen),
                        );
                      }

                      if (widget.controller.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.controller.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                              AppSizes.spaceM,
                              ElevatedButton(
                                onPressed: () => widget.controller.fetchFarmerNewsFeed(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final articles = widget.controller.articles;
                      if (articles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.newspaper_outlined, size: 64, color: AppColors.textLight),
                              AppSizes.spaceM,
                              Text(
                                'No news articles found',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textMedium,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primaryGreen,
                        onRefresh: () => widget.controller.fetchFarmerNewsFeed(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSizes.l),
                          itemCount: articles.length,
                          separatorBuilder: (context, index) => AppSizes.spaceM,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            return _buildArticleCard(article);
                          },
                        ),
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
            'Agriculture News',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryGreen),
                tooltip: 'Topic Subscriptions',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategorySubscriptionScreen(controller: widget.controller),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.xs),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => widget.controller.setSearchQuery(val),
          decoration: InputDecoration(
            hintText: 'Search news by crop, region, advisory...',
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.textLight),
                    onPressed: () {
                      _searchController.clear();
                      widget.controller.setSearchQuery('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final categories = widget.controller.categories;
        final selectedCat = widget.controller.selectedCategory;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.s),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedCat == null,
                selectedColor: AppColors.primaryGreen,
                checkmarkColor: AppColors.white,
                labelStyle: TextStyle(
                  color: selectedCat == null ? AppColors.white : AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: AppColors.white.withValues(alpha: 0.5),
                onSelected: (_) => widget.controller.selectCategory(null),
              ),
              ...categories.map((cat) {
                final isSelected = selectedCat?.id == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(left: AppSizes.s),
                  child: FilterChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    checkmarkColor: AppColors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: AppColors.white.withValues(alpha: 0.5),
                    onSelected: (_) => widget.controller.selectCategory(cat),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArticleCard(NewsArticleModel article) {
    final formattedDate = article.publishedAt != null
        ? '${article.publishedAt!.day}/${article.publishedAt!.month}/${article.publishedAt!.year}'
        : '';

    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(
                initialArticle: article,
                controller: widget.controller,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
                child: Image.network(
                  article.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: AppColors.lightGreen,
                    child: const Center(
                      child: Icon(Icons.newspaper_outlined, color: AppColors.primaryGreen, size: 36),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.category.name,
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (formattedDate.isNotEmpty)
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMedium),
                        ),
                    ],
                  ),
                  AppSizes.spaceS,
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMedium,
                          height: 1.3,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
