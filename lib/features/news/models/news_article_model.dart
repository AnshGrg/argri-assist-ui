import 'news_category_model.dart';

class NewsArticleModel {
  final int id;
  final String title;
  final String summary;
  final String? content;
  final String? imageUrl;
  final NewsCategoryModel category;
  final String? createdBy;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String status;

  const NewsArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    this.content,
    this.imageUrl,
    required this.category,
    this.createdBy,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.status = 'PUBLISHED',
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    NewsCategoryModel parsedCategory;
    if (json['category'] is Map<String, dynamic>) {
      parsedCategory = NewsCategoryModel.fromJson(json['category'] as Map<String, dynamic>);
    } else if (json['category'] is int) {
      parsedCategory = NewsCategoryModel(id: json['category'] as int, name: 'Category ${json['category']}', description: '');
    } else if (json['category'] is String) {
      parsedCategory = NewsCategoryModel(id: 0, name: json['category'] as String, description: '');
    } else {
      parsedCategory = NewsCategoryModel(
        id: json['category_id'] is int
            ? json['category_id'] as int
            : int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
        name: json['news_category'] as String? ?? 'General',
        description: '',
      );
    }

    return NewsArticleModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String?,
      imageUrl: (json['image'] as String?) ?? (json['image_url'] as String?),
      category: parsedCategory,
      createdBy: (json['created_by_username'] as String?) ?? (json['created_by'] as String?),
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      status: json['status'] as String? ?? 'PUBLISHED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      if (content != null) 'content': content,
      if (imageUrl != null) 'image_url': imageUrl,
      'category': category.toJson(),
      if (createdBy != null) 'created_by': createdBy,
      if (publishedAt != null) 'published_at': publishedAt?.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
      'status': status,
    };
  }
}
