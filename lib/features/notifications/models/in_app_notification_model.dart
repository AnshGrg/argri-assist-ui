class InAppNotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? readAt;
  final int? newsId;
  final String? newsCategory;

  const InAppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
    this.readAt,
    this.newsId,
    this.newsCategory,
  });

  factory InAppNotificationModel.fromJson(Map<String, dynamic> json) {
    return InAppNotificationModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      newsId: json['news_id'] != null
          ? (json['news_id'] is int
              ? json['news_id'] as int
              : int.tryParse(json['news_id'].toString()))
          : null,
      newsCategory: json['news_category'] as String?,
    );
  }

  InAppNotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    int? newsId,
    String? newsCategory,
  }) {
    return InAppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      newsId: newsId ?? this.newsId,
      newsCategory: newsCategory ?? this.newsCategory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (readAt != null) 'read_at': readAt?.toIso8601String(),
      if (newsId != null) 'news_id': newsId,
      if (newsCategory != null) 'news_category': newsCategory,
    };
  }
}
