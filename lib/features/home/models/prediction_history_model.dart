class PredictionHistoryModel {
  final String id;
  final String cropName;
  final String date;
  final String recommendation;
  final String imageUrl; // Placeholder for image asset/network path

  const PredictionHistoryModel({
    required this.id,
    required this.cropName,
    required this.date,
    required this.recommendation,
    required this.imageUrl,
  });

  factory PredictionHistoryModel.fromJson(Map<String, dynamic> json) {
    return PredictionHistoryModel(
      id: json['id'] as String,
      cropName: json['cropName'] as String,
      date: json['date'] as String,
      recommendation: json['recommendation'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'date': date,
      'recommendation': recommendation,
      'imageUrl': imageUrl,
    };
  }
}
