import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_assist/features/analytics/models/crop_distribution_model.dart';

void main() {
  group('CropDistributionResponse', () {
    test('parses new API payload structure with status, top_crops_leaderboard, and seasonal crop_distribution', () {
      const jsonStr = '''
      {
        "status": "success",
        "top_crops_leaderboard": [
          {
            "rank": 1,
            "crop_name": "Rice",
            "total_recommendations": 1420,
            "avg_confidence_pct": 94.2
          }
        ],
        "crop_distribution": [
          {
            "season": "Monsoon",
            "total_recommendations": 2310,
            "top_crops": [
              { "crop": "rice", "count": 1420, "percentage": 61.47 },
              { "crop": "maize", "count": 890, "percentage": 38.53 }
            ]
          },
          {
            "season": "Winter",
            "total_recommendations": 1170,
            "top_crops": [
              { "crop": "chickpea", "count": 650, "percentage": 55.56 },
              { "crop": "lentil", "count": 520, "percentage": 44.44 }
            ]
          }
        ]
      }
      ''';

      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final response = CropDistributionResponse.fromJson(decoded);

      expect(response.status, equals('success'));

      // Verify Leaderboard
      expect(response.topCropsLeaderboard.length, equals(1));
      final topCrop = response.topCropsLeaderboard.first;
      expect(topCrop.rank, equals(1));
      expect(topCrop.cropName, equals('Rice'));
      expect(topCrop.totalRecommendations, equals(1420));
      expect(topCrop.avgConfidencePct, equals(94.2));

      // Verify Seasonal Crop Distribution
      expect(response.seasonalDistribution.length, equals(2));
      
      final monsoon = response.seasonalDistribution[0];
      expect(monsoon.season, equals('Monsoon'));
      expect(monsoon.totalRecommendations, equals(2310));
      expect(monsoon.topCrops.length, equals(2));
      expect(monsoon.topCrops[0].crop, equals('rice'));
      expect(monsoon.topCrops[0].count, equals(1420));
      expect(monsoon.topCrops[0].percentage, equals(61.47));

      final winter = response.seasonalDistribution[1];
      expect(winter.season, equals('Winter'));
      expect(winter.totalRecommendations, equals(1170));
      expect(winter.topCrops.length, equals(2));
      expect(winter.topCrops[0].crop, equals('chickpea'));
      expect(winter.topCrops[0].count, equals(650));
      expect(winter.topCrops[0].percentage, equals(55.56));
    });
  });
}
