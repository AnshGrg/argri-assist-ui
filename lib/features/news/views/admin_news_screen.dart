// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/news_controller.dart';
import '../models/news_article_model.dart';
import '../../auth/views/admin_login_screen.dart';
import 'create_news_article_screen.dart';
import 'news_detail_screen.dart';

class AdminNewsScreen extends StatefulWidget {
  final NewsController controller;

  const AdminNewsScreen({
    super.key,
    required this.controller,
  });

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  final _searchController = TextEditingController();
  List<NewsArticleModel> _adminArticles = [];
  bool _isLoadingList = false;
  String _selectedFilter = 'ALL'; // ALL, PUBLISHED, DRAFT
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdminNews();
      if (widget.controller.categories.isEmpty) {
        widget.controller.fetchCategories();
      }
    });
  }

  Future<void> _loadAdminNews() async {
    setState(() => _isLoadingList = true);
    final list = await widget.controller.fetchAdminNewsList();
    if (mounted) {
      setState(() {
        _adminArticles = list;
        _isLoadingList = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NewsArticleModel> get _filteredArticles {
    return _adminArticles.where((article) {
      final statusUpper = article.status.toUpperCase();
      final matchesFilter = _selectedFilter == 'ALL' ||
          (_selectedFilter == 'PUBLISHED' && statusUpper == 'PUBLISHED') ||
          (_selectedFilter == 'DRAFT' && statusUpper == 'DRAFT');
      final matchesSearch = _searchQuery.isEmpty ||
          article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.summary.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.category.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _showPostDialog() async {
    if (!widget.controller.isAdminLoggedIn) {
      _promptAdminLogin();
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewsArticleScreen(controller: widget.controller),
      ),
    );
    if (result == true && mounted) {
      _loadAdminNews();
    }
  }

  void _showEditDialog(NewsArticleModel article) {
    if (!widget.controller.isAdminLoggedIn) {
      _promptAdminLogin();
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: article.title);
    final summaryController = TextEditingController(text: article.summary);
    final contentController = TextEditingController(text: article.content ?? '');
    final imageUrlController = TextEditingController(text: article.imageUrl ?? '');

    int? selectedCategoryId = article.category.id;
    String status = article.status;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text('Edit News Article', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                      ),
                      AppSizes.spaceS,
                      TextFormField(
                        controller: summaryController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Summary *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Summary is required' : null,
                      ),
                      AppSizes.spaceS,
                      TextFormField(
                        controller: contentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Full Content *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Content is required' : null,
                      ),
                      AppSizes.spaceS,
                      TextFormField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      AppSizes.spaceS,
                      DropdownButtonFormField<int>(
                        value: (widget.controller.categories.any((c) => c.id == selectedCategoryId))
                            ? selectedCategoryId
                            : (widget.controller.categories.isNotEmpty ? widget.controller.categories.first.id : null),
                        items: widget.controller.categories.map((cat) {
                          return DropdownMenuItem<int>(value: cat.id, child: Text(cat.name));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedCategoryId = val);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      AppSizes.spaceS,
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        items: const [
                          DropdownMenuItem(value: 'PUBLISHED', child: Text('PUBLISHED')),
                          DropdownMenuItem(value: 'DRAFT', child: Text('DRAFT')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => status = val);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                  label: const Text('Save Changes', style: TextStyle(color: AppColors.white)),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(dialogCtx);
                      final success = await widget.controller.updateAdminArticle(
                        article.id,
                        title: titleController.text.trim(),
                        summary: summaryController.text.trim(),
                        content: contentController.text.trim(),
                        categoryId: selectedCategoryId,
                        imageUrl: imageUrlController.text.trim().isEmpty ? null : imageUrlController.text.trim(),
                        status: status,
                      );
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Article updated successfully!' : 'Failed to update article.'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                      if (success && mounted) _loadAdminNews();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showViewDialog(NewsArticleModel article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(
          initialArticle: article,
          controller: widget.controller,
          isAdmin: true,
        ),
      ),
    );
  }

  void _confirmDelete(NewsArticleModel article) async {
    if (!widget.controller.isAdminLoggedIn) {
      _promptAdminLogin();
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
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
      final success = await widget.controller.deleteAdminArticle(article.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text(success ? 'Article deleted successfully!' : 'Failed to delete article.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success && mounted) _loadAdminNews();
    }
  }

  Future<void> _promptAdminLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminLoginScreen(newsController: widget.controller),
      ),
    );
    if (mounted && widget.controller.isAdminLoggedIn) {
      _loadAdminNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
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
                _buildAdminAuthStatus(),
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: _isLoadingList
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                      : _filteredArticles.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.newspaper_rounded, size: 64, color: AppColors.textMedium.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No articles match "$_searchQuery"'
                                        : widget.controller.isAdminLoggedIn
                                            ? 'No articles found in this filter.'
                                            : 'Please login as Admin to view and manage news.',
                                    style: const TextStyle(color: AppColors.textMedium),
                                  ),
                                  const SizedBox(height: 16),
                                  if (widget.controller.isAdminLoggedIn)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                                      label: const Text('Post First News Article', style: TextStyle(color: Colors.white)),
                                      onPressed: _showPostDialog,
                                    )
                                  else
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                      icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
                                      label: const Text('Admin Login', style: TextStyle(color: Colors.white)),
                                      onPressed: _promptAdminLogin,
                                    ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(AppSizes.l),
                              itemCount: _filteredArticles.length,
                              separatorBuilder: (context, index) => AppSizes.spaceM,
                              itemBuilder: (context, index) {
                                final article = _filteredArticles[index];
                                return _buildAdminArticleCard(article);
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
          Expanded(
            child: Text(
              'Admin News Management',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGreen, size: 28),
                tooltip: 'Post New Article',
                onPressed: _showPostDialog,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGreen),
                tooltip: 'Refresh News',
                onPressed: _loadAdminNews,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAuthStatus() {
    final isLoggedIn = widget.controller.isAdminLoggedIn;
    final token = widget.controller.adminToken;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.xs),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLoggedIn ? Colors.green.shade50.withValues(alpha: 0.8) : Colors.amber.shade50.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isLoggedIn ? Colors.green.shade300 : Colors.amber.shade400),
      ),
      child: Row(
        children: [
          Icon(
            isLoggedIn ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
            color: isLoggedIn ? Colors.green.shade800 : Colors.amber.shade900,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isLoggedIn
                  ? 'Admin Token Active: ${token != null && token.length > 15 ? "${token.substring(0, 15)}..." : token}'
                  : 'Admin Token Required: Please log in as admin.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isLoggedIn ? Colors.green.shade900 : Colors.amber.shade900,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (isLoggedIn) {
                widget.controller.logoutAdmin();
                setState(() => _adminArticles = []);
              } else {
                await _promptAdminLogin();
              }
            },
            child: Text(
              isLoggedIn ? 'Logout' : 'Login',
              style: TextStyle(
                color: isLoggedIn ? Colors.red.shade700 : AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.xs),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() => _searchQuery = val.trim());
        },
        decoration: InputDecoration(
          hintText: 'Search articles by title or category...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.6),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.xs),
      child: Row(
        children: [
          _buildFilterChip('ALL', 'All Articles'),
          const SizedBox(width: 8),
          _buildFilterChip('PUBLISHED', 'Published Only'),
          const SizedBox(width: 8),
          _buildFilterChip('DRAFT', 'Drafts Only'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen,
      backgroundColor: Colors.white.withValues(alpha: 0.5),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = value);
        }
      },
    );
  }

  Widget _buildAdminArticleCard(NewsArticleModel article) {
    final isPublished = article.status == 'PUBLISHED';

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.m),
      child: InkWell(
        onTap: () => _showViewDialog(article),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPublished ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    article.status,
                    style: TextStyle(
                      color: isPublished ? Colors.green.shade800 : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  article.category.name,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMedium, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0)),
                  icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.textDark),
                  label: const Text('View', style: TextStyle(fontSize: 11, color: AppColors.textDark)),
                  onPressed: () => _showViewDialog(article),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0)),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryGreen),
                  label: const Text('Edit', style: TextStyle(fontSize: 11, color: AppColors.primaryGreen)),
                  onPressed: () => _showEditDialog(article),
                ),
                if (!isPublished)
                  TextButton.icon(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0)),
                    icon: const Icon(Icons.publish_rounded, size: 16, color: Colors.blue),
                    label: const Text('Publish', style: TextStyle(fontSize: 11, color: Colors.blue)),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await widget.controller.publishAdminArticle(article.id);
                      messenger.showSnackBar(
                        SnackBar(content: Text(success ? 'Article published!' : 'Failed to publish.')),
                      );
                      if (success && mounted) _loadAdminNews();
                    },
                  ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                  tooltip: 'Delete Article',
                  onPressed: () => _confirmDelete(article),
                ),
              ],
            ),
            AppSizes.spaceS,
            Text(
              article.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              article.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMedium),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (article.createdBy != null)
                  Text(
                    'By ${article.createdBy}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMedium),
                  ),
                if (article.createdAt != null)
                  Text(
                    article.createdAt!.toLocal().toString().split(' ').first,
                    style: const TextStyle(fontSize: 10, color: AppColors.textMedium),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
