import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/token_storage.dart';
import '../controllers/news_controller.dart';
import '../models/news_article_model.dart';
import '../repos/news_repo.dart';
import '../repos/subscription_repo.dart';

/// Mobile design for viewing news articles / advisories.
class NewsDetailScreen extends StatefulWidget {
  final int? newsId;
  final NewsArticleModel? initialArticle;
  final NewsController? controller;
  final bool isAdmin;

  const NewsDetailScreen({
    super.key,
    this.newsId,
    this.initialArticle,
    this.controller,
    this.isAdmin = false,
  }) : assert(
         newsId != null || initialArticle != null,
         'Either newsId or initialArticle must be provided',
       );

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
    _initControllerAndLoad();
  }

  Future<void> _initControllerAndLoad() async {
    if (widget.controller != null) {
      _newsController = widget.controller!;
    } else {
      String? token;
      final saved = await TokenStorage.loadTokens();
      token = saved?.access;
      _newsController = NewsController(
        newsRepo: HttpNewsRepo(),
        subscriptionRepo: HttpSubscriptionRepo(),
        userToken: token,
      );
    }

    _newsController.fetchSubscriptions();

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
    if (_article == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await _newsController.fetchArticleDetail(id);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result != null) {
          _article = result;
        } else if (_article == null) {
          _errorMessage =
              _newsController.errorMessage ?? 'Failed to load article';
        }
      });
    }
  }

  String _getCategoryEmoji(String catName) {
    final lower = catName.toLowerCase();
    if (lower.contains('all')) return '🌿';
    if (lower.contains('crop')) return '🌾';
    if (lower.contains('fertilizer')) return '🧪';
    if (lower.contains('pest')) return '🐛';
    if (lower.contains('weather')) return '🌦️';
    if (lower.contains('market') || lower.contains('price')) return '📈';
    return '🌱';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EAD8),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : _errorMessage != null
          ? _buildErrorWidget()
          : _article == null
          ? const Center(
              child: Text(
                'Article not found',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverHeader(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryPill(),
                        const SizedBox(height: 14),
                        Text(
                          _article!.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A29),
                            height: 1.25,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildContentCard(),
                        if (!widget.isAdmin) ...[
                          const SizedBox(height: 24),
                          _buildSubscribeButton(),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCoverHeader(BuildContext context) {
    final hasImage =
        _article!.imageUrl != null && _article!.imageUrl!.isNotEmpty;

    return Stack(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          color: const Color(0xFFC3E0C6),
          child: hasImage
              ? Image.network(
                  _article!.imageUrl!,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF1E3A29),
                      size: 20,
                    ),
                  ),
                ),
                // Subscribe / Unsubscribe Button
                // _buildSubscribeIconButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFC3E0C6),
      child: const Center(
        child: Icon(Icons.eco_rounded, color: Color(0xFF2B9348), size: 64),
      ),
    );
  }

  Widget _buildCategoryPill() {
    final catEmoji = _getCategoryEmoji(_article!.category.name);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC5E5C9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(catEmoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            _article!.category.name,
            style: const TextStyle(
              color: Color(0xFF1B4D27),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return AnimatedBuilder(
      animation: _newsController,
      builder: (context, _) {
        final isSubscribed = _newsController.subscribedCategoryIds.contains(_article!.category.id);
        final isActionLoading = _newsController.isActionLoading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSubscribed ? Colors.white : AppColors.primaryGreen,
              foregroundColor: isSubscribed ? AppColors.primaryGreen : Colors.white,
              elevation: 2,
              side: isSubscribed ? const BorderSide(color: AppColors.primaryGreen, width: 1.5) : BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isActionLoading ? null : () => _toggleSub(isSubscribed),
            icon: isActionLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSubscribed ? AppColors.primaryGreen : Colors.white,
                      ),
                    ),
                  )
                : Icon(
                    isSubscribed ? Icons.notifications_off_outlined : Icons.notifications_active_outlined,
                    size: 20,
                  ),
            label: Text(
              isSubscribed
                  ? 'Unsubscribe from ${_article!.category.name}'
                  : 'Subscribe to ${_article!.category.name}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSubscribed ? AppColors.primaryGreen : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleSub(bool isSubscribed) async {
    final messenger = ScaffoldMessenger.of(context);
    final success = await _newsController.toggleSubscription(
      _article!.category.id,
    );
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isSubscribed
                ? 'Unsubscribed from ${_article!.category.name}.'
                : 'Subscribed to ${_article!.category.name}!',
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _newsController.errorMessage ?? 'Subscription action failed.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildContentCard() {
    final text =
        (_article!.content != null && _article!.content!.trim().isNotEmpty)
        ? _article!.content!
        : _article!.summary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF6EC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF2D3748),
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              onPressed: () {
                final targetId = _article?.id ?? widget.newsId;
                if (targetId != null) _loadDetail(targetId);
              },
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
