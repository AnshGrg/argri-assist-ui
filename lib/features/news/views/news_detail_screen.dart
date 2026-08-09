import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../models/news_article_model.dart';
import '../controllers/news_controller.dart';
import '../repos/news_repo.dart';
import '../repos/subscription_repo.dart';

class NewsDetailScreen extends StatefulWidget {
  final int? newsId;
  final NewsArticleModel? initialArticle;
  final NewsController? controller;

  const NewsDetailScreen({
    super.key,
    this.newsId,
    this.initialArticle,
    this.controller,
  }) : assert(newsId != null || initialArticle != null, 'Either newsId or initialArticle must be provided');

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late NewsController _newsController;
  NewsArticleModel? _article;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _newsController = widget.controller ??
        NewsController(
          newsRepo: MockNewsRepo(),
          subscriptionRepo: MockSubscriptionRepo(),
        );

    if (widget.initialArticle != null) {
      _article = widget.initialArticle;
      if (_article?.content == null && widget.initialArticle?.id != null) {
        _loadDetail(widget.initialArticle!.id);
      }
    } else if (widget.newsId != null) {
      _loadDetail(widget.newsId!);
    }
  }

  Future<void> _loadDetail(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _newsController.fetchArticleDetail(id);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result != null) {
          _article = result;
        } else {
          _errorMessage = _newsController.errorMessage ?? 'Failed to load article';
        }
      });
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
          // Frosted Glass Blur Overlay
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
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryGreen),
                        )
                      : _errorMessage != null
                          ? _buildErrorWidget()
                          : _article == null
                              ? const Center(child: Text('Article not found'))
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.all(AppSizes.l),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildArticleHeader(),
                                      AppSizes.spaceL,
                                      if (_article!.imageUrl != null && _article!.imageUrl!.isNotEmpty)
                                        _buildArticleBannerImage(),
                                      AppSizes.spaceL,
                                      _buildArticleBodyCard(),
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
            'News Article',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          const SizedBox(width: 48), // Spacer balance
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            AppSizes.spaceM,
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            AppSizes.spaceM,
            ElevatedButton(
              onPressed: () {
                final targetId = _article?.id ?? widget.newsId;
                if (targetId != null) _loadDetail(targetId);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleHeader() {
    final formattedDate = _article!.publishedAt != null
        ? '${_article!.publishedAt!.day}/${_article!.publishedAt!.month}/${_article!.publishedAt!.year}'
        : 'Recent';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: Text(
                _article!.category.name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMedium),
            const SizedBox(width: 4),
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMedium),
            ),
          ],
        ),
        AppSizes.spaceM,
        Text(
          _article!.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                height: 1.3,
              ),
        ),
        if (_article!.createdBy != null) ...[
          AppSizes.spaceS,
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 4),
              Text(
                'By ${_article!.createdBy}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildArticleBannerImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      child: Image.network(
        _article!.imageUrl!,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            color: AppColors.lightGreen,
            child: const Center(
              child: Icon(Icons.image_not_supported_rounded, color: AppColors.primaryGreen, size: 40),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleBodyCard() {
    final contentText = _article!.content ?? _article!.summary;

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _article!.summary,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.m),
            child: Divider(color: AppColors.glassBorder),
          ),
          Text(
            contentText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textDark,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
