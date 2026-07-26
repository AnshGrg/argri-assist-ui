import '../../predict/models/prediction_result_model.dart';

class NpkAnalysis {
  final String nitrogenStatus;
  final String phosphorusStatus;
  final String potassiumStatus;
  final String phStatus;

  const NpkAnalysis({
    required this.nitrogenStatus,
    required this.phosphorusStatus,
    required this.potassiumStatus,
    required this.phStatus,
  });

  factory NpkAnalysis.fromJson(Map<String, dynamic> json) {
    return NpkAnalysis(
      nitrogenStatus: json['nitrogen_status'] as String,
      phosphorusStatus: json['phosphorus_status'] as String,
      potassiumStatus: json['potassium_status'] as String,
      phStatus: json['ph_status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nitrogen_status': nitrogenStatus,
      'phosphorus_status': phosphorusStatus,
      'potassium_status': potassiumStatus,
      'ph_status': phStatus,
    };
  }
}

class FertilizerResultModel {
  final String recommendedFertilizer;
  final double confidence;
  final NpkAnalysis npkAnalysis;
  final ClimateData climateData;
  final String explanation;
  final String applicationAdvice;

  // Backward compatibility fields
  String get dosage => 'As recommended';
  List<String> get instructions => [applicationAdvice];
  List<String> get notes => [explanation];

  const FertilizerResultModel({
    required this.recommendedFertilizer,
    required this.confidence,
    required this.npkAnalysis,
    required this.climateData,
    required this.explanation,
    required this.applicationAdvice,
  });

  factory FertilizerResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return FertilizerResultModel(
      recommendedFertilizer: data['recommended_fertilizer'] as String,
      confidence: (data['confidence'] as num).toDouble(),
      npkAnalysis: NpkAnalysis.fromJson(data['npk_analysis'] as Map<String, dynamic>),
      climateData: ClimateData.fromJson(data['climate_data'] as Map<String, dynamic>),
      explanation: data['explanation'] as String,
      applicationAdvice: data['application_advice'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': 'success',
      'data': {
        'recommended_fertilizer': recommendedFertilizer,
        'confidence': confidence,
        'npk_analysis': npkAnalysis.toJson(),
        'climate_data': climateData.toJson(),
        'explanation': explanation,
        'application_advice': applicationAdvice,
      }
    };
  }
}
