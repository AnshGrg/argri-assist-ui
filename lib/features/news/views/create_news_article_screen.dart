// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/image_picker_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/news_controller.dart';

class CreateNewsArticleScreen extends StatefulWidget {
  final NewsController controller;

  const CreateNewsArticleScreen({
    super.key,
    required this.controller,
  });

  @override
  State<CreateNewsArticleScreen> createState() => _CreateNewsArticleScreenState();
}

class _CreateNewsArticleScreenState extends State<CreateNewsArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  int? _selectedCategoryId;
  String _status = 'PUBLISHED';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller.categories.isNotEmpty) {
      _selectedCategoryId = widget.controller.categories.first.id;
    } else {
      widget.controller.fetchCategories().then((_) {
        if (mounted && widget.controller.categories.isNotEmpty) {
          setState(() {
            _selectedCategoryId = widget.controller.categories.first.id;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePickerService.pickImage();
    if (picked != null && mounted) {
      setState(() {
        _imageBytes = picked.bytes;
        _imageName = picked.name;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a news category.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await widget.controller.createAdminArticle(
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        content: _contentController.text.trim(),
        categoryId: _selectedCategoryId!,
        imageBytes: _imageBytes,
        imageName: _imageName,
        status: _status,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('News article posted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.controller.errorMessage ?? 'Failed to post news article.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          // Backdrop blur & green overlay
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
                child: Container(
                  color: AppColors.backgroundGreen.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : AppSizes.l,
                      vertical: AppSizes.l,
                    ),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: GlassCard(
                          padding: EdgeInsets.all(isDesktop ? AppSizes.xl : AppSizes.l),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Article Details',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                ),
                                Text(
                                  'Fill out the advisory details and upload an image file for farmers.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textMedium,
                                      ),
                                ),
                                AppSizes.spaceL,

                                // Title Field
                                TextFormField(
                                  controller: _titleController,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Article Title *',
                                    hintText: 'e.g., Fall Armyworm Outbreak Alert in Terai',
                                    prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primaryGreen),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                                ),
                                AppSizes.spaceL,

                                // Category Dropdown & Status Segment
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AnimatedBuilder(
                                        animation: widget.controller,
                                        builder: (context, _) {
                                          final categories = widget.controller.categories;

                                          return DropdownButtonFormField<int>(
                                            value: (categories.isNotEmpty && categories.any((c) => c.id == _selectedCategoryId))
                                                ? _selectedCategoryId
                                                : (categories.isNotEmpty ? categories.first.id : null),
                                            isExpanded: true,
                                            items: categories.map((cat) {
                                              return DropdownMenuItem<int>(
                                                value: cat.id,
                                                child: Text(
                                                  cat.name,
                                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(() => _selectedCategoryId = val);
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Category *',
                                              prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primaryGreen),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                              filled: true,
                                              fillColor: Colors.white.withValues(alpha: 0.7),
                                            ),
                                            validator: (val) => val == null ? 'Select a category' : null,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.m),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _status,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'PUBLISHED',
                                            child: Text('Publish Immediately', style: TextStyle(fontWeight: FontWeight.w600)),
                                          ),
                                          DropdownMenuItem(
                                            value: 'DRAFT',
                                            child: Text('Save as Draft', style: TextStyle(fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => _status = val);
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Publication Status *',
                                          prefixIcon: const Icon(Icons.publish_rounded, color: AppColors.primaryGreen),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          filled: true,
                                          fillColor: Colors.white.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                AppSizes.spaceL,

                                // Summary Field
                                TextFormField(
                                  controller: _summaryController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: 'Short Summary *',
                                    hintText: 'Brief summary displayed on news feed cards',
                                    alignLabelWithHint: true,
                                    prefixIcon: const Icon(Icons.short_text_rounded, color: AppColors.primaryGreen),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a summary' : null,
                                ),
                                AppSizes.spaceL,

                                // Full Content Body
                                TextFormField(
                                  controller: _contentController,
                                  maxLines: 8,
                                  decoration: InputDecoration(
                                    labelText: 'Full Content Body *',
                                    hintText: 'Write detailed advice, recommendations, steps, or official notice...',
                                    alignLabelWithHint: true,
                                    prefixIcon: const Icon(Icons.article_outlined, color: AppColors.primaryGreen),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter content body' : null,
                                ),
                                AppSizes.spaceL,

                                // Image File Picker Section
                                const Text(
                                  'Cover Image File (Optional)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                                ),
                                const SizedBox(height: 8),
                                _buildImagePickerBox(),
                                AppSizes.spaceXl,

                                // Submit Actions Bar
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel', style: TextStyle(color: AppColors.textDark)),
                                    ),
                                    const SizedBox(width: AppSizes.m),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryGreen,
                                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: _isSubmitting ? null : _handleSubmit,
                                      icon: _isSubmitting
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                      label: Text(
                                        _isSubmitting ? 'Posting...' : 'Post News Article',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildImagePickerBox() {
    if (_imageBytes != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGreen),
          color: Colors.white,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.memory(
                _imageBytes!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.image_rounded, color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _imageName ?? 'selected_image.jpg',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: const Text('Change'),
                  ),
                  IconButton(
                    onPressed: _removeImage,
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    tooltip: 'Remove Image',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.5),
            width: 1.5,
          ),
          color: Colors.white.withValues(alpha: 0.6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primaryGreen,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Click to select cover image file',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Supports PNG, JPG, WEBP formats',
              style: TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _pickImage,
              icon: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 18),
              label: const Text('Browse Image File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.l,
        vertical: AppSizes.m,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.7),
        border: Border(
          bottom: BorderSide(
            color: AppColors.white.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: AppSizes.s),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.post_add_rounded,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSizes.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload News & Advisory',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                ),
                Text(
                  'Post official guidelines, pest alerts, or weather notices',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                      ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isSubmitting ? null : _handleSubmit,
            icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
            label: const Text(
              'Publish Post',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
