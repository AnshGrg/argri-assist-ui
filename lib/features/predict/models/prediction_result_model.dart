class AlternativeCrop {
  final String crop;
  final double confidence;

  const AlternativeCrop({
    required this.crop,
    required this.confidence,
  });

  factory AlternativeCrop.fromJson(Map<String, dynamic> json) {
    return AlternativeCrop(
      crop: json['crop'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop': crop,
      'confidence': confidence,
    };
  }
}

class ClimateData {
  final double temperature;
  final double humidity;
  final double rainfall;
  final String season;
  final String source;

  const ClimateData({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.season,
    required this.source,
  });

  factory ClimateData.fromJson(Map<String, dynamic> json) {
    return ClimateData(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      rainfall: (json['rainfall'] as num).toDouble(),
      season: json['season'] as String,
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      'season': season,
      'source': source,
    };
  }
}

class PredictionResultModel {
  final String recommendedCrop;
  final double confidence;
  final List<AlternativeCrop> alternativeCrops;
  final ClimateData climateData;
  final String explanation;
  final String advice;

  // Helper properties for backward compatibility
  String get cropName => recommendedCrop;
  double get confidenceScore => confidence / 100.0;
  String get description => explanation;
  String get imageUrl => 'assets/images/${recommendedCrop.toLowerCase()}.png';

  const PredictionResultModel({
    required this.recommendedCrop,
    required this.confidence,
    required this.alternativeCrops,
    required this.climateData,
    required this.explanation,
    required this.advice,
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PredictionResultModel(
      recommendedCrop: data['recommended_crop'] as String,
      confidence: (data['confidence'] as num).toDouble(),
      alternativeCrops: (data['alternative_crops'] as List)
          .map((e) => AlternativeCrop.fromJson(e as Map<String, dynamic>))
          .toList(),
      climateData: ClimateData.fromJson(data['climate_data'] as Map<String, dynamic>),
      explanation: data['explanation'] as String,
      advice: data['advice'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': 'success',
      'data': {
        'recommended_crop': recommendedCrop,
        'confidence': confidence,
        'alternative_crops': alternativeCrops.map((e) => e.toJson()).toList(),
        'climate_data': climateData.toJson(),
        'explanation': explanation,
        'advice': advice,
      }
    };
  }
}
