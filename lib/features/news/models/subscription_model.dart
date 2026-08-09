import 'news_category_model.dart';

class SubscriptionModel {
  final int id;
  final NewsCategoryModel category;
  final DateTime? createdAt;

  const SubscriptionModel({
    required this.id,
    required this.category,
    this.createdAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      category: NewsCategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.toJson(),
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }
}
