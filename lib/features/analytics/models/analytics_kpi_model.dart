class AnalyticsKpiModel {
  final int totalFarmers;
  final int totalCropPredictions;
  final int totalFertilizerPredictions;
  final int totalAcidicSoilAlerts;
  final double acidicSoilPercentage;
  final double nitrogenDeficiencyRate;
  final double phosphorusDeficiencyRate;
  final double potassiumDeficiencyRate;

  AnalyticsKpiModel({
    required this.totalFarmers,
    required this.totalCropPredictions,
    required this.totalFertilizerPredictions,
    required this.totalAcidicSoilAlerts,
    required this.acidicSoilPercentage,
    this.nitrogenDeficiencyRate = 42.0,
    this.phosphorusDeficiencyRate = 38.0,
    this.potassiumDeficiencyRate = 21.0,
  });

  factory AnalyticsKpiModel.fromJson(Map<String, dynamic> json) {
    final kpiJson = json['kpis'] as Map<String, dynamic>? ?? json;

    final npkObj = kpiJson['npk_deficiencies'] as Map<String, dynamic>? ??
        (json['npk_deficiencies'] as Map<String, dynamic>?);

    final nRate = npkObj != null
        ? (npkObj['nitrogen_deficiency_pct'] as num?)?.toDouble()
        : (kpiJson['nitrogen_deficiency_rate'] as num?)?.toDouble();

    final pRate = npkObj != null
        ? (npkObj['phosphorus_deficiency_pct'] as num?)?.toDouble()
        : (kpiJson['phosphorus_deficiency_rate'] as num?)?.toDouble();

    final kRate = npkObj != null
        ? (npkObj['potassium_deficiency_pct'] as num?)?.toDouble()
        : (kpiJson['potassium_deficiency_rate'] as num?)?.toDouble();

    return AnalyticsKpiModel(
      totalFarmers: (kpiJson['total_farmers'] as num?)?.toInt() ?? 0,
      totalCropPredictions: (kpiJson['total_crop_predictions'] as num?)?.toInt() ?? 0,
      totalFertilizerPredictions: (kpiJson['total_fertilizer_predictions'] as num?)?.toInt() ?? 0,
      totalAcidicSoilAlerts: (kpiJson['total_acidic_soil_alerts'] as num?)?.toInt() ?? 0,
      acidicSoilPercentage: (kpiJson['acidic_soil_percentage'] as num?)?.toDouble() ?? 0.0,
      nitrogenDeficiencyRate: nRate ?? 42.0,
      phosphorusDeficiencyRate: pRate ?? 38.0,
      potassiumDeficiencyRate: kRate ?? 21.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_farmers': totalFarmers,
      'total_crop_predictions': totalCropPredictions,
      'total_fertilizer_predictions': totalFertilizerPredictions,
      'total_acidic_soil_alerts': totalAcidicSoilAlerts,
      'acidic_soil_percentage': acidicSoilPercentage,
      'npk_deficiencies': {
        'nitrogen_deficiency_pct': nitrogenDeficiencyRate,
        'phosphorus_deficiency_pct': phosphorusDeficiencyRate,
        'potassium_deficiency_pct': potassiumDeficiencyRate,
      },
    };
  }
}
