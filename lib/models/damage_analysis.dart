// models/damage_analysis.dart
class DamageAnalysis {
  final bool hasDamage;
  final double confidence;
  final String? damageType;
  final DamageDetails? damageDetails;
  final double? estimatedCost;
  final String? message;

  DamageAnalysis({
    required this.hasDamage,
    required this.confidence,
    this.damageType,
    this.damageDetails,
    this.estimatedCost,
    this.message,
  });

  factory DamageAnalysis.fromJson(Map<String, dynamic> json) {
    return DamageAnalysis(
      hasDamage: json['hasDamage'] ?? false,
      confidence: json['confidence']?.toDouble() ?? 0.0,
      damageType: json['damageType'],
      damageDetails: json['damageDetails'] != null
          ? DamageDetails.fromJson(json['damageDetails'])
          : null,
      estimatedCost: json['estimatedCost']?.toDouble(),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'hasDamage': hasDamage,
      'confidence': confidence,
    };
    
    if (damageType != null) data['damageType'] = damageType;
    if (damageDetails != null) data['damageDetails'] = damageDetails!.toJson();
    if (estimatedCost != null) data['estimatedCost'] = estimatedCost;
    if (message != null) data['message'] = message;
    
    return data;
  }
}

class DamageDetails {
  final String location;
  final String severity;
  final String affectedParts;
  final String repairRecommendation;

  DamageDetails({
    required this.location,
    required this.severity,
    required this.affectedParts,
    required this.repairRecommendation,
  });

  factory DamageDetails.fromJson(Map<String, dynamic> json) {
    return DamageDetails(
      location: json['location'] ?? '',
      severity: json['severity'] ?? '',
      affectedParts: json['affectedParts'] ?? '',
      repairRecommendation: json['repairRecommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'severity': severity,
      'affectedParts': affectedParts,
      'repairRecommendation': repairRecommendation,
    };
  }
}