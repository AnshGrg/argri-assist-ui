import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/news_controller.dart';
import '../models/news_article_model.dart';
import '../models/news_category_model.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();

  NewsCategoryModel? _selectedCategory;
  String _status = 'PUBLISHED';
  List<NewsArticleModel> _adminArticles = [];
  bool _isLoadingList = false;

  @override
  void initState() {
    super.initState();
    _loadAdminNews();
    if (widget.controller.categories.isNotEmpty) {
      _selectedCategory = widget.controller.categories.first;
    } else {
      widget.controller.fetchCategories().then((_) {
        if (widget.controller.categories.isNotEmpty && mounted) {
          setState(() {
            _selectedCategory = widget.controller.categories.first;
          });
        }
      });
    }
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
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundGreen,
              title: const Text('Publish / Draft News Article', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title *'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Enter title' : null,
                      ),
                      AppSizes.spaceS,
                      TextFormField(
                        controller: _summaryController,
                        decoration: const InputDecoration(labelText: 'Summary *'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Enter summary' : null,
                      ),
                      AppSizes.spaceS,
                      TextFormField(
                        controller: _contentController,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Full Content *'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Enter content' : null,
                      ),
                      AppSizes.spaceS,
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(labelText: 'Image URL (Optional)'),
                      ),
                      AppSizes.spaceS,
                      DropdownButtonFormField<NewsCategoryModel>(
                        initialValue: _selectedCategory,
                        items: widget.controller.categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat.name));
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() => _selectedCategory = val);
                        },
                        decoration: const InputDecoration(labelText: 'Category *'),
                      ),
                      AppSizes.spaceS,
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        items: const [
                          DropdownMenuItem(value: 'PUBLISHED', child: Text('Publish Immediately')),
                          DropdownMenuItem(value: 'DRAFT', child: Text('Save as Draft')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => _status = val);
                        },
                        decoration: const InputDecoration(labelText: 'Publication Status'),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (_selectedCategory == null) return;
                      Navigator.pop(dialogCtx);
                      final success = await widget.controller.createAdminArticle(
                        title: _titleController.text.trim(),
                        summary: _summaryController.text.trim(),
                        content: _contentController.text.trim(),
                        categoryId: _selectedCategory!.id,
                        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
                        status: _status,
                      );
                      if (success) {
                        _titleController.clear();
                        _summaryController.clear();
                        _contentController.clear();
                        _imageUrlController.clear();
                        _loadAdminNews();
                      }
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: AppColors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add_rounded, color: AppColors.white),
      ),
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
                Expanded(
                  child: _isLoadingList
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                      : _adminArticles.isEmpty
                          ? const Center(child: Text('No articles posted yet.'))
                          : ListView.separated(
                              padding: const EdgeInsets.all(AppSizes.l),
                              itemCount: _adminArticles.length,
                              separatorBuilder: (context, index) => AppSizes.spaceM,
                              itemBuilder: (context, index) {
                                final article = _adminArticles[index];
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
          Text(
            'Admin News Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGreen),
            onPressed: _loadAdminNews,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminArticleCard(NewsArticleModel article) {
    final isPublished = article.status == 'PUBLISHED';

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPublished ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
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
                style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
              ),
              const Spacer(),
              if (!isPublished)
                TextButton.icon(
                  onPressed: () async {
                    final success = await widget.controller.publishAdminArticle(article.id);
                    if (success) _loadAdminNews();
                  },
                  icon: const Icon(Icons.publish_rounded, size: 16, color: AppColors.primaryGreen),
                  label: const Text('Publish', style: TextStyle(color: AppColors.primaryGreen)),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Article'),
                      content: const Text('Are you sure you want to delete this news article?'),
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
                    if (success) _loadAdminNews();
                  }
                },
              ),
            ],
          ),
          AppSizes.spaceS,
          Text(
            article.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
        ],
      ),
    );
  }
}
