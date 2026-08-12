import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/image_picker_service.dart';
import '../controllers/news_controller.dart';
import '../models/news_article_model.dart';

/// Clean web portal style screen for creating OR editing a news article/advisory.
class CreateNewsArticleScreen extends StatefulWidget {
  final NewsController controller;
  final NewsArticleModel? articleToEdit;

  const CreateNewsArticleScreen({
    super.key,
    required this.controller,
    this.articleToEdit,
  });

  bool get isEditing => articleToEdit != null;

  @override
  State<CreateNewsArticleScreen> createState() =>
      _CreateNewsArticleScreenState();
}

class _CreateNewsArticleScreenState extends State<CreateNewsArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _contentController;

  Uint8List? _imageBytes;
  String? _imageName;

  int? _selectedCategoryId;
  late String _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final article = widget.articleToEdit;

    _titleController = TextEditingController(text: article?.title ?? '');
    _summaryController = TextEditingController(text: article?.summary ?? '');
    _contentController = TextEditingController(text: article?.content ?? '');
    _status = article?.status ?? 'PUBLISHED';

    if (article != null) {
      _selectedCategoryId = article.category.id;
    } else if (widget.controller.categories.isNotEmpty) {
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
      const maxSizeBytes = 5 * 1024 * 1024; // 5 MB limit
      if (picked.bytes.length > maxSizeBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selected image exceeds the 5 MB limit. Please choose a smaller file.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
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
      final bool success;
      if (widget.isEditing) {
        success = await widget.controller.updateAdminArticle(
          widget.articleToEdit!.id,
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          content: _contentController.text.trim(),
          categoryId: _selectedCategoryId,
          imageBytes: _imageBytes,
          imageName: _imageName,
          status: _status,
        );
      } else {
        success = await widget.controller.createAdminArticle(
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          content: _contentController.text.trim(),
          categoryId: _selectedCategoryId!,
          imageBytes: _imageBytes,
          imageName: _imageName,
          status: _status,
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEditing
                    ? 'News article updated successfully!'
                    : 'News article posted successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.controller.errorMessage ??
                    (widget.isEditing
                        ? 'Failed to update article.'
                        : 'Failed to post news article.'),
              ),
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
    final titleText = widget.isEditing
        ? 'Edit News Article'
        : 'Post News Article or Advisory';
    final buttonText = widget.isEditing ? 'Save Changes' : 'Save';
    final submitText = 'Saving...';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF475569),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEditing
                        ? 'Edit News Details'
                        : 'News Article Information',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.isEditing
                        ? 'Update the fields below to modify the published article or draft.'
                        : 'Fill in the fields below to publish a new advisory or agricultural notice.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildInputLabel('News Title *'),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _inputDecoration(
                      'e.g., Fall Armyworm Outbreak Alert in Terai Region',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Category & Status Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Category *'),
                            AnimatedBuilder(
                              animation: widget.controller,
                              builder: (context, _) {
                                final categories = widget.controller.categories;
                                return DropdownButtonFormField<int>(
                                  initialValue:
                                      (categories.isNotEmpty &&
                                          categories.any(
                                            (c) => c.id == _selectedCategoryId,
                                          ))
                                      ? _selectedCategoryId
                                      : (categories.isNotEmpty
                                            ? categories.first.id
                                            : null),
                                  isExpanded: true,
                                  items: categories.map((cat) {
                                    return DropdownMenuItem<int>(
                                      value: cat.id,
                                      child: Text(
                                        cat.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null)
                                      setState(() => _selectedCategoryId = val);
                                  },
                                  decoration: _inputDecoration(
                                    'Select category',
                                  ),
                                  validator: (val) =>
                                      val == null ? 'Select a category' : null,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Publication Status *'),
                            DropdownButtonFormField<String>(
                              initialValue: _status,
                              items: const [
                                DropdownMenuItem(
                                  value: 'PUBLISHED',
                                  child: Text(
                                    'Publish Immediately',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'DRAFT',
                                  child: Text(
                                    'Save as Draft',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _status = val);
                              },
                              decoration: _inputDecoration('Select status'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Short Summary
                  _buildInputLabel('Short Summary *'),
                  TextFormField(
                    controller: _summaryController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14),
                    decoration: _inputDecoration(
                      'Brief summary displayed in the news feed tables...',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter a summary'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Content Body
                  _buildInputLabel('Full Content Body *'),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 8,
                    style: const TextStyle(fontSize: 14),
                    decoration: _inputDecoration(
                      'Write detailed advisory notes, guidelines, chemical treatments, etc...',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter content body'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Image File Picker Section
                  _buildInputLabel('Cover Image File (Optional)'),
                  const SizedBox(height: 4),
                  _buildImagePickerBox(),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : SizedBox(),
                        label: Text(
                          _isSubmitting ? submitText : buttonText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
    );
  }

  Widget _buildImagePickerBox() {
    final existingImageUrl = widget.articleToEdit?.imageUrl;

    if (_imageBytes != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
          color: const Color(0xFFF8FAFC),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.memory(
                _imageBytes!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.image_rounded,
                    color: AppColors.primaryGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _imageName ?? 'selected_image.jpg',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: const Text('Change', style: TextStyle(fontSize: 12)),
                  ),
                  IconButton(
                    onPressed: _removeImage,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    tooltip: 'Remove Image',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
          color: const Color(0xFFF8FAFC),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.network(
                existingImageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(
                      Icons.newspaper_rounded,
                      size: 36,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    color: AppColors.primaryGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Current Attached Image',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 0,
                    ),
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file_rounded, size: 14),
                    label: const Text(
                      'Upload New Image',
                      style: TextStyle(fontSize: 12),
                    ),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
          color: const Color(0xFFF8FAFC),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              color: Color(0xFF64748B),
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'Click to select cover image file',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Supports PNG, JPG, WEBP formats (Max 5 MB)',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
