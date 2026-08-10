class RegionalFertilizerDemand {
  final String city;
  final int totalQueries;
  final Map<String, int> fertilizers;

  RegionalFertilizerDemand({
    required this.city,
    required this.totalQueries,
    required this.fertilizers,
  });

  factory RegionalFertilizerDemand.fromJson(Map<String, dynamic> json) {
    final rawFertilizers = json['fertilizers'] as Map<String, dynamic>? ?? {};
    final Map<String, int> parsedFertilizers = {};
    rawFertilizers.forEach((key, value) {
      if (value is num) {
        parsedFertilizers[key] = value.toInt();
      } else if (value != null) {
        parsedFertilizers[key] = int.tryParse(value.toString()) ?? 0;
      }
    });

    return RegionalFertilizerDemand(
      city: json['city'] ?? '',
      totalQueries: (json['total_queries'] as num?)?.toInt() ?? 0,
      fertilizers: parsedFertilizers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'total_queries': totalQueries,
      'fertilizers': fertilizers,
    };
  }
}
