class DailyUsageTrend {
  final String date;
  final int cropQueries;
  final int fertilizerQueries;

  DailyUsageTrend({
    required this.date,
    required this.cropQueries,
    required this.fertilizerQueries,
  });

  factory DailyUsageTrend.fromJson(Map<String, dynamic> json) {
    return DailyUsageTrend(
      date: json['date'] ?? '',
      cropQueries: (json['crop_queries'] as num?)?.toInt() ?? 0,
      fertilizerQueries: (json['fertilizer_queries'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'crop_queries': cropQueries,
      'fertilizer_queries': fertilizerQueries,
    };
  }
}
