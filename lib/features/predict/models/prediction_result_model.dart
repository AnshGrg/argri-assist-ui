class PredictionResultModel {
  final String cropName;
  final double confidenceScore;
  final String description;
  final String imageUrl;

  const PredictionResultModel({
    required this.cropName,
    required this.confidenceScore,
    required this.description,
    required this.imageUrl,
  });

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) {
    return PredictionResultModel(
      cropName: json['cropName'] as String,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'confidenceScore': confidenceScore,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
