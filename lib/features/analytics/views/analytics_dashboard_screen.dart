// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'admin_overview_view.dart';
import 'admin_soil_fertilizer_view.dart';
import 'admin_crop_climate_view.dart';
import 'admin_news_management_view.dart';
import '../controllers/analytics_controller.dart';

import '../../news/controllers/news_controller.dart';
import '../../news/models/news_article_model.dart';
import '../../news/repos/news_repo.dart';
import '../../news/repos/subscription_repo.dart';
import '../../news/views/create_news_article_screen.dart';
import '../../news/views/news_detail_screen.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  final AnalyticsController? controller;
  final String? authToken;

  const AnalyticsDashboardScreen({
    super.key,
    this.controller,
    this.authToken,
  });

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  late final AnalyticsController _controller;
  late final NewsController _newsController;

  List<NewsArticleModel> _adminNewsArticles = [];
  bool _isLoadingNews = false;
  String _newsFilter = 'ALL';
  String _newsSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AnalyticsController();

    _newsController = NewsController(
      newsRepo: HttpNewsRepo(),
      subscriptionRepo: HttpSubscriptionRepo(),
      userToken: widget.authToken,
    );
    if (widget.authToken != null && widget.authToken!.isNotEmpty) {
      _newsController.setAdminToken(widget.authToken);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchAnalyticsData(token: widget.authToken);
      _newsController.fetchCategories();
      _loadAdminNews();
    });
  }

  Future<void> _loadAdminNews() async {
    setState(() => _isLoadingNews = true);
    final list = await _newsController.fetchAdminNewsList();
    if (mounted) {
      setState(() {
        _adminNewsArticles = list;
        _isLoadingNews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              children: [
                _buildWebHeaderNavigation(context, isDesktop),
                if (_controller.errorMessage != null)
                  _buildErrorBanner(context),
                Expanded(
                  child: _controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32.0 : 16.0,
                            vertical: 24.0,
                          ),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 1280),
                              child: _buildPageBody(context, isDesktop),
                            ),
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

  // Single Web Navigation Bar (Header + Inline Navigation Tabs)
  Widget _buildWebHeaderNavigation(BuildContext context, bool isDesktop) {
    final currentIndex = _controller.currentTabIndex;

    final tabs = [
      _TabItem(title: 'Overview', route: '/admin/dashboard', icon: Icons.dashboard_rounded),
      _TabItem(title: 'Soil & Fertilizer', route: '/admin/soil-health', icon: Icons.science_rounded),
      _TabItem(title: 'Crop & Climate', route: '/admin/crop-intelligence', icon: Icons.eco_rounded),
      _TabItem(title: 'News & Advisories', route: '/admin/news', icon: Icons.newspaper_rounded),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Top Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
            child: Row(
              children: [
                if (Navigator.of(context).canPop()) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF334155), size: 20),
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AgriAssist Admin Console',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Agricultural Intelligence & Portal Management',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Web Navigation Tab Row directly underneath header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: tabs.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isSelected = idx == currentIndex;

                  return InkWell(
                    onTap: () => _controller.setTabIndex(idx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryGreen : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    final code = _controller.errorCode;
    final msg = _controller.errorMessage ?? 'An error occurred';

    Color bannerBg = Colors.amber.shade100;
    Color borderClr = Colors.amber.shade400;
    Color textClr = Colors.amber.shade900;
    IconData iconData = Icons.warning_amber_rounded;

    if (code == 401) {
      bannerBg = Colors.orange.shade100;
      borderClr = Colors.orange.shade400;
      textClr = Colors.orange.shade900;
      iconData = Icons.lock_outline_rounded;
    } else if (code == 403) {
      bannerBg = Colors.red.shade100;
      borderClr = Colors.red.shade400;
      textClr = Colors.red.shade900;
      iconData = Icons.gpp_bad_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bannerBg,
        border: Border(bottom: BorderSide(color: borderClr, width: 1)),
      ),
      child: Row(
        children: [
          Icon(iconData, color: textClr, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(color: textClr, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: textClr,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _controller.fetchAnalyticsData(token: widget.authToken),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageBody(BuildContext context, bool isDesktop) {
    switch (_controller.currentTabIndex) {
      case 1:
        return _buildPage2SoilAndFertilizer(context, isDesktop);
      case 2:
        return _buildPage3CropAndClimate(context, isDesktop);
      case 3:
        return _buildPage4NewsManagement(context, isDesktop);
      case 0:
      default:
        return _buildPage1SystemOverview(context, isDesktop);
    }
  }

  Widget _buildPage1SystemOverview(BuildContext context, bool isDesktop) {
    return AdminOverviewView(
      controller: _controller,
      isDesktop: isDesktop,
    );
  }

  // ================= PAGE 2: REGIONAL SOIL HEALTH & FERTILIZER DEMAND =================
  Widget _buildPage2SoilAndFertilizer(BuildContext context, bool isDesktop) {
    return AdminSoilFertilizerView(
      controller: _controller,
      isDesktop: isDesktop,
    );
  }




  // ================= PAGE 3: CROP CULTIVATION & SATELLITE CLIMATE INTELLIGENCE =================
  Widget _buildPage3CropAndClimate(BuildContext context, bool isDesktop) {
    return AdminCropClimateView(
      controller: _controller,
      isDesktop: isDesktop,
    );
  }



  List<NewsArticleModel> get _filteredAdminNews {
    return _adminNewsArticles.where((article) {
      final statusUpper = article.status.toUpperCase();
      final matchesFilter = _newsFilter == 'ALL' ||
          (_newsFilter == 'PUBLISHED' && statusUpper == 'PUBLISHED') ||
          (_newsFilter == 'DRAFT' && statusUpper == 'DRAFT');
      final matchesSearch = _newsSearchQuery.isEmpty ||
          article.title.toLowerCase().contains(_newsSearchQuery.toLowerCase()) ||
          article.summary.toLowerCase().contains(_newsSearchQuery.toLowerCase()) ||
          article.category.name.toLowerCase().contains(_newsSearchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  // ================= PAGE 4: NEWS & ADVISORIES MANAGEMENT =================
  Widget _buildPage4NewsManagement(BuildContext context, bool isDesktop) {
    return AdminNewsManagementView(
      newsController: _newsController,
      articles: _filteredAdminNews,
      isLoading: _isLoadingNews,
      newsFilter: _newsFilter,
      newsSearchQuery: _newsSearchQuery,
      onFilterChanged: (filter) => setState(() => _newsFilter = filter),
      onSearchChanged: (search) => setState(() => _newsSearchQuery = search.trim()),
      onRefresh: _loadAdminNews,
      onCreateNews: () => _openCreateNewsScreen(context),
      onViewArticle: (article) => _showViewNewsDialog(context, article),
      onEditArticle: (article) => _showEditNewsDialog(context, article),
      onPublishArticle: (article) async {
        final messenger = ScaffoldMessenger.of(context);
        final success = await _newsController.publishAdminArticle(article.id);
        messenger.showSnackBar(
          SnackBar(content: Text(success ? 'Article published!' : 'Failed to publish.')),
        );
        if (success) _loadAdminNews();
      },
      onDeleteArticle: (article) => _confirmDeleteNews(context, article),
    );
  }

  void _openCreateNewsScreen(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewsArticleScreen(controller: _newsController),
      ),
    );
    if (result == true) {
      _loadAdminNews();
    }
  }

  void _showEditNewsDialog(BuildContext context, NewsArticleModel article) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewsArticleScreen(
          controller: _newsController,
          articleToEdit: article,
        ),
      ),
    );
    if (result == true) {
      _loadAdminNews();
    }
  }

  void _showViewNewsDialog(BuildContext context, NewsArticleModel article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(
          initialArticle: article,
          controller: _newsController,
          isAdmin: true,
        ),
      ),
    );
  }

  void _confirmDeleteNews(BuildContext context, NewsArticleModel article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete News Article'),
          ],
        ),
        content: Text('Are you sure you want to permanently delete "${article.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _newsController.deleteAdminArticle(article.id);
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Article deleted successfully!' : 'Failed to delete article.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) _loadAdminNews();
      }
    }
  }
}

class _TabItem {
  final String title;
  final String route;
  final IconData icon;

  _TabItem({required this.title, required this.route, required this.icon});
}

