import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../news/controllers/news_controller.dart';
import '../../news/models/news_article_model.dart';

/// Web-style News & Advisories Management view, extracted into its own modular view file.
class AdminNewsManagementView extends StatefulWidget {
  final NewsController newsController;
  final List<NewsArticleModel> articles;
  final bool isLoading;
  final String newsFilter;
  final String newsSearchQuery;
  final Function(String filter) onFilterChanged;
  final Function(String search) onSearchChanged;
  final VoidCallback onRefresh;
  final VoidCallback onCreateNews;
  final Function(NewsArticleModel article) onViewArticle;
  final Function(NewsArticleModel article) onEditArticle;
  final Function(NewsArticleModel article) onPublishArticle;
  final Function(NewsArticleModel article) onDeleteArticle;

  const AdminNewsManagementView({
    super.key,
    required this.newsController,
    required this.articles,
    required this.isLoading,
    required this.newsFilter,
    required this.newsSearchQuery,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onCreateNews,
    required this.onViewArticle,
    required this.onEditArticle,
    required this.onPublishArticle,
    required this.onDeleteArticle,
  });

  @override
  State<AdminNewsManagementView> createState() => _AdminNewsManagementViewState();
}

class _AdminNewsManagementViewState extends State<AdminNewsManagementView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title & Header Banner
        _buildHeaderCard(context),
        const SizedBox(height: 20),

        // Data Table Card
        _buildTableContainer(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'News & Farmer Advisories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage, publish, edit, and filter news articles and advisories in web data table format.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Post News Article',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: widget.onCreateNews,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search and Filter Bar
          Row(
            children: [
              // Search Input
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: TextField(
                    onChanged: widget.onSearchChanged,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search by title, summary, category...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Status Filter Tabs
              Row(
                children: [
                  _buildFilterTab('ALL', 'All'),
                  const SizedBox(width: 6),
                  _buildFilterTab('PUBLISHED', 'Published'),
                  const SizedBox(width: 6),
                  _buildFilterTab('DRAFT', 'Drafts'),
                ],
              ),
              const SizedBox(width: 12),

              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
                tooltip: 'Refresh Articles',
                onPressed: widget.onRefresh,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String value, String label) {
    final isSelected = widget.newsFilter == value;
    return GestureDetector(
      onTap: () => widget.onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildTableContainer(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: widget.isLoading
          ? const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
            )
          : widget.articles.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 300),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      headingRowHeight: 44,
                      dataRowMinHeight: 64,
                      dataRowMaxHeight: 64,
                      columnSpacing: 20,
                      dividerThickness: 1,
                      border: TableBorder.all(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      columns: const [
                        DataColumn(label: Text('Preview', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                        DataColumn(label: Text('Title & Summary', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                        DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                        DataColumn(label: Text('Published Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF475569)))),
                      ],
                      rows: widget.articles.map((article) => _buildDataRow(context, article)).toList(),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(60.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.newspaper_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              widget.newsSearchQuery.isNotEmpty
                  ? 'No articles match "${widget.newsSearchQuery}"'
                  : 'No articles found.',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, NewsArticleModel article) {
    final isPublished = article.status == 'PUBLISHED';
    final dateStr = article.publishedAt != null
        ? '${article.publishedAt!.day.toString().padLeft(2, '0')}/${article.publishedAt!.month.toString().padLeft(2, '0')}/${article.publishedAt!.year}'
        : (article.createdAt != null
            ? '${article.createdAt!.day.toString().padLeft(2, '0')}/${article.createdAt!.month.toString().padLeft(2, '0')}/${article.createdAt!.year}'
            : '-');

    return DataRow(
      cells: [
        // Image Preview
        DataCell(
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 48,
              height: 40,
              child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                  ? Image.network(
                      article.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _fallbackThumbnail(),
                    )
                  : _fallbackThumbnail(),
            ),
          ),
        ),

        // Title & Summary (Truncated)
        DataCell(
          SizedBox(
            width: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  article.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Category Badge
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              article.category.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ),

        // Status Badge
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isPublished ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              article.status,
              style: TextStyle(
                color: isPublished ? const Color(0xFF15803D) : const Color(0xFFB45309),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),

        // Date
        DataCell(
          Text(
            dateStr,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF0284C7)),
                tooltip: 'View Details',
                onPressed: () => widget.onViewArticle(article),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF475569)),
                tooltip: 'Edit Article',
                onPressed: () => widget.onEditArticle(article),
              ),
              if (!isPublished)
                IconButton(
                  icon: const Icon(Icons.publish_rounded, size: 18, color: Color(0xFF16A34A)),
                  tooltip: 'Publish Now',
                  onPressed: () => widget.onPublishArticle(article),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                tooltip: 'Delete Article',
                onPressed: () => widget.onDeleteArticle(article),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fallbackThumbnail() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.newspaper_rounded, size: 20, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
