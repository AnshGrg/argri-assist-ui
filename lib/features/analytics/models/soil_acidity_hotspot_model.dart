class SoilAcidityHotspot {
  final String city;
  final double averagePh;
  final int totalTests;
  final int acidicTestsCount;
  final double acidicPercentage;
  final String acidityRiskLevel;
  final String? actionRequired;

  SoilAcidityHotspot({
    required this.city,
    required this.averagePh,
    required this.totalTests,
    required this.acidicTestsCount,
    required this.acidicPercentage,
    required this.acidityRiskLevel,
    this.actionRequired,
  });

  bool get isCritical => acidityRiskLevel.toUpperCase() == 'CRITICAL';
  bool get isHigh => acidityRiskLevel.toUpperCase() == 'HIGH';

  String get defaultAction {
    if (actionRequired != null && actionRequired!.isNotEmpty) {
      return actionRequired!;
    }
    switch (acidityRiskLevel.toUpperCase()) {
      case 'CRITICAL':
        return 'Subsidy Lime 200kg/ha';
      case 'HIGH':
        return 'Subsidy Lime 150kg/ha';
      default:
        return 'Normal Monitoring';
    }
  }

  factory SoilAcidityHotspot.fromJson(Map<String, dynamic> json) {
    return SoilAcidityHotspot(
      city: json['city'] ?? '',
      averagePh: (json['average_ph'] as num?)?.toDouble() ?? 0.0,
      totalTests: (json['total_tests'] as num?)?.toInt() ?? 0,
      acidicTestsCount: (json['acidic_tests_count'] as num?)?.toInt() ?? 0,
      acidicPercentage: (json['acidic_percentage'] as num?)?.toDouble() ?? 0.0,
      acidityRiskLevel: json['acidity_risk_level'] ?? 'LOW',
      actionRequired: json['action_required'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'average_ph': averagePh,
      'total_tests': totalTests,
      'acidic_tests_count': acidicTestsCount,
      'acidic_percentage': acidicPercentage,
      'acidity_risk_level': acidityRiskLevel,
      'action_required': defaultAction,
    };
  }
}
