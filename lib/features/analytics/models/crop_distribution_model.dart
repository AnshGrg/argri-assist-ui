class CropShare {
  final String crop;
  final int count;
  final double percentage;

  CropShare({
    required this.crop,
    required this.count,
    required this.percentage,
  });

  factory CropShare.fromJson(Map<String, dynamic> json) {
    return CropShare(
      crop: json['crop'] ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop': crop,
      'count': count,
      'percentage': percentage,
    };
  }
}

class SeasonalCropDistribution {
  final String season;
  final int totalRecommendations;
  final List<CropShare> topCrops;

  SeasonalCropDistribution({
    required this.season,
    required this.totalRecommendations,
    required this.topCrops,
  });

  factory SeasonalCropDistribution.fromJson(Map<String, dynamic> json) {
    final rawCrops = json['top_crops'] as List<dynamic>? ?? [];
    return SeasonalCropDistribution(
      season: json['season'] ?? '',
      totalRecommendations: (json['total_recommendations'] as num?)?.toInt() ?? 0,
      topCrops: rawCrops.map((item) => CropShare.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season': season,
      'total_recommendations': totalRecommendations,
      'top_crops': topCrops.map((c) => c.toJson()).toList(),
    };
  }
}
