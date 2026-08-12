class CropLeaderboardItem {
  final int rank;
  final String cropName;
  final int totalRecommendations;
  final double avgConfidencePct;

  CropLeaderboardItem({
    required this.rank,
    required this.cropName,
    required this.totalRecommendations,
    required this.avgConfidencePct,
  });

  factory CropLeaderboardItem.fromJson(Map<String, dynamic> json) {
    return CropLeaderboardItem(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      cropName: json['crop_name'] ?? json['crop'] ?? '',
      totalRecommendations: (json['total_recommendations'] as num?)?.toInt() ?? (json['count'] as num?)?.toInt() ?? 0,
      avgConfidencePct: (json['avg_confidence_pct'] as num?)?.toDouble() ?? (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'crop_name': cropName,
      'total_recommendations': totalRecommendations,
      'avg_confidence_pct': avgConfidencePct,
    };
  }
}

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
      crop: json['crop'] ?? json['crop_name'] ?? '',
      count: (json['count'] as num?)?.toInt() ?? (json['total_recommendations'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? (json['avg_confidence_pct'] as num?)?.toDouble() ?? 0.0,
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
      totalRecommendations: (json['total_recommendations'] as num?)?.toInt() ?? (json['count'] as num?)?.toInt() ?? 0,
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

class CropDistributionResponse {
  final String status;
  final List<CropLeaderboardItem> topCropsLeaderboard;
  final List<SeasonalCropDistribution> seasonalDistribution;

  CropDistributionResponse({
    this.status = 'success',
    required this.topCropsLeaderboard,
    required this.seasonalDistribution,
  });

  factory CropDistributionResponse.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'success';

    final rawLeaderboard = (json['top_crops_leaderboard'] as List<dynamic>?) ??
        (json['crop_distribution'] is Map
            ? (json['crop_distribution']['top_crops_leaderboard'] as List<dynamic>?)
            : null) ??
        [];

    final rawSeasonal = (json['crop_distribution'] is List
            ? json['crop_distribution'] as List<dynamic>
            : null) ??
        (json['seasonal_distribution'] as List<dynamic>?) ??
        (json['data'] as List<dynamic>?) ??
        [];

    return CropDistributionResponse(
      status: statusStr,
      topCropsLeaderboard: rawLeaderboard
          .whereType<Map<String, dynamic>>()
          .map((item) => CropLeaderboardItem.fromJson(item))
          .toList(),
      seasonalDistribution: rawSeasonal
          .whereType<Map<String, dynamic>>()
          .map((item) => SeasonalCropDistribution.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'top_crops_leaderboard': topCropsLeaderboard.map((e) => e.toJson()).toList(),
      'crop_distribution': seasonalDistribution.map((e) => e.toJson()).toList(),
    };
  }
}
