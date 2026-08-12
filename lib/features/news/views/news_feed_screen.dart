import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../controllers/news_controller.dart';
import '../models/news_article_model.dart';
import 'news_detail_screen.dart';

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

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dt.month - 1];
    return '$month ${dt.day}, ${dt.year}';
  }

  String _getCategoryEmoji(String catName) {
    final lower = catName.toLowerCase();
    if (lower.contains('all')) return '🌿';
    if (lower.contains('crop')) return '🌾';
    if (lower.contains('fertilizer')) return '🧪';
    if (lower.contains('pest')) return '🐛';
    if (lower.contains('weather')) return '🌦️';
    if (lower.contains('market') || lower.contains('price')) return '📈';
    return '🍃';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF7EE),
      body: SafeArea(
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
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
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
                            onPressed: () =>
                                widget.controller.fetchFarmerNewsFeed(),
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
                          const Icon(
                            Icons.newspaper_outlined,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          AppSizes.spaceM,
                          Text(
                            'No news articles found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.textMedium),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: () => widget.controller.fetchFarmerNewsFeed(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Text(
                            '${articles.length} article${articles.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B8C67),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: articles.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final article = articles[index];
                              return _buildArticleCard(article);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
            'Agriculture News',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0EBE0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => widget.controller.setSearchQuery(val),
          decoration: InputDecoration(
            hintText: 'Search news, topics...',
            hintStyle: const TextStyle(color: Color(0xFF9EABA0), fontSize: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF4A90E2),
              size: 22,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: AppColors.textLight,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      widget.controller.setSearchQuery('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterBadge(
                label: 'All',
                emoji: '🌿',
                isSelected: selectedCat == null,
                onTap: () => widget.controller.selectCategory(null),
              ),
              ...categories.map((cat) {
                final isSelected = selectedCat?.id == cat.id;
                final emoji = _getCategoryEmoji(cat.name);
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildFilterBadge(
                    label: cat.name,
                    emoji: emoji,
                    isSelected: isSelected,
                    onTap: () => widget.controller.selectCategory(cat),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterBadge({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C6B30) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2C6B30)
                : const Color(0xFFE0EBE0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2C6B30).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(NewsArticleModel article) {
    final dt = article.publishedAt ?? article.createdAt;
    final formattedDate = _formatDate(dt);
    final catEmoji = _getCategoryEmoji(article.category.name);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE6F2E6), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child:
                      article.imageUrl != null && article.imageUrl!.isNotEmpty
                      ? Image.network(
                          article.imageUrl!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF2DF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$catEmoji ${article.category.name}',
                          style: const TextStyle(
                            color: Color(0xFF2C6B30),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (formattedDate.isNotEmpty)
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8E9BAE),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const Spacer(),
                          const Icon(
                            Icons.local_offer_outlined,
                            size: 14,
                            color: Color(0xFFD4B185),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: Icon(
          Icons.newspaper_rounded,
          color: AppColors.primaryGreen,
          size: 32,
        ),
      ),
    );
  }
}
