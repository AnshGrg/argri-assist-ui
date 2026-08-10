import 'news_category_model.dart';

class SubscriptionModel {
  final int id;
  final NewsCategoryModel category;
  final int categoryId;
  final DateTime? createdAt;

  const SubscriptionModel({
    required this.id,
    required this.category,
    required this.categoryId,
    this.createdAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] is Map<String, dynamic>
        ? NewsCategoryModel.fromJson(json['category'] as Map<String, dynamic>)
        : NewsCategoryModel(
            id: json['category_id'] is int
                ? json['category_id'] as int
                : int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
            name: 'General',
            description: '',
          );
    return SubscriptionModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      category: cat,
      categoryId: json['category_id'] is int
          ? json['category_id'] as int
          : (json['category_id'] != null
              ? int.tryParse(json['category_id'].toString()) ?? cat.id
              : cat.id),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.toJson(),
      'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }
}
