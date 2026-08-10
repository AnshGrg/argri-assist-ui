enum HistoryType { crop, fertilizer }

class HistoryItemModel {
  final String id;
  final String cropName;
  final double confidenceScore;
  final String date;
  
  // Input parameters
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double ph;
  final double temperature;
  final double humidity;
  final double rainfall;

  // Additional API fields
  final String? advice;
  final DateTime? createdAt;
  final List<dynamic>? alternativeCrops;

  // Fertilizer Recommendation (optional, if user went through fertilizer flow)
  final String? recommendedFertilizer;
  final String? fertilizerDosage;

  // Type to distinguish crop vs fertilizer history items
  final HistoryType historyType;

  const HistoryItemModel({
    required this.id,
    required this.cropName,
    required this.confidenceScore,
    required this.date,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
    required this.temperature,
    this.humidity = 0.0,
    required this.rainfall,
    this.advice,
    this.createdAt,
    this.alternativeCrops,
    this.recommendedFertilizer,
    this.fertilizerDosage,
    this.historyType = HistoryType.crop,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json, {HistoryType type = HistoryType.crop}) {
    // If the response is wrapped inside a status/record map structure
    final recordJson = json['record'] is Map<String, dynamic>
        ? json['record'] as Map<String, dynamic>
        : json;

    final rawDate = recordJson['created_at']?.toString();
    DateTime? dt = rawDate != null ? DateTime.tryParse(rawDate) : null;
    String dateStr = dt != null
        ? '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'
        : 'Recent';

    final crop = recordJson['recommended_crop'] as String? ?? recordJson['crop_name'] as String? ?? 'Crop';
    final conf = (recordJson['confidence'] as num?)?.toDouble() ?? (recordJson['confidence_score'] as num?)?.toDouble() ?? 0.95;

    return HistoryItemModel(
      id: recordJson['id']?.toString() ?? '',
      cropName: crop,
      confidenceScore: conf > 1.0 ? conf / 100.0 : conf,
      date: dateStr,
      nitrogen: (recordJson['nitrogen'] as num?)?.toDouble() ?? (recordJson['n'] as num?)?.toDouble() ?? 0.0,
      phosphorus: (recordJson['phosphorus'] as num?)?.toDouble() ?? (recordJson['p'] as num?)?.toDouble() ?? 0.0,
      potassium: (recordJson['potassium'] as num?)?.toDouble() ?? (recordJson['k'] as num?)?.toDouble() ?? 0.0,
      ph: (recordJson['ph'] as num?)?.toDouble() ?? 7.0,
      temperature: (recordJson['temperature'] as num?)?.toDouble() ?? 25.0,
      humidity: (recordJson['humidity'] as num?)?.toDouble() ?? 60.0,
      rainfall: (recordJson['rainfall'] as num?)?.toDouble() ?? 100.0,
      advice: recordJson['application_advice'] as String? ?? recordJson['advice'] as String?,
      createdAt: dt,
      alternativeCrops: recordJson['alternative_crops'] is List
          ? recordJson['alternative_crops'] as List<dynamic>
          : null,
      recommendedFertilizer: recordJson['recommended_fertilizer'] as String?,
      fertilizerDosage: recordJson['fertilizer_dosage'] as String?,
      historyType: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recommended_crop': cropName,
      'confidence': confidenceScore,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      if (advice != null) 'advice': advice,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }

  HistoryItemModel copyWith({
    String? recommendedFertilizer,
    String? fertilizerDosage,
    String? advice,
    List<dynamic>? alternativeCrops,
  }) {
    return HistoryItemModel(
      id: id,
      cropName: cropName,
      confidenceScore: confidenceScore,
      date: date,
      nitrogen: nitrogen,
      phosphorus: phosphorus,
      potassium: potassium,
      ph: ph,
      temperature: temperature,
      humidity: humidity,
      rainfall: rainfall,
      advice: advice ?? this.advice,
      createdAt: createdAt,
      alternativeCrops: alternativeCrops ?? this.alternativeCrops,
      recommendedFertilizer: recommendedFertilizer ?? this.recommendedFertilizer,
      fertilizerDosage: fertilizerDosage ?? this.fertilizerDosage,
      historyType: historyType,
    );
  }
}
