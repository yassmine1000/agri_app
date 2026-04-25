class CropPlanning {
  final int id;
  final int userId;
  final int cropId;
  final String startDate;
  final String expectedHarvestDate;
  final String? notes;
  final bool irrigationReminder;
  final bool fertilizerReminder;
  final String? planName;     // Custom plan name
  final String? cropName;     // English — fallback
  final String? cropNameFr;   // French
  final String? cropNameAr;   // Arabic
  final String? createdAt;

  CropPlanning({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.startDate,
    required this.expectedHarvestDate,
    this.notes,
    required this.irrigationReminder,
    required this.fertilizerReminder,
    this.planName,
    this.cropName,
    this.cropNameFr,
    this.cropNameAr,
    this.createdAt,
  });

  /// Returns the crop name in the given language code ('EN', 'FR', 'AR')
  String localizedName(String lang) {
    if (lang == 'FR' && cropNameFr != null && cropNameFr!.isNotEmpty) return cropNameFr!;
    if (lang == 'AR' && cropNameAr != null && cropNameAr!.isNotEmpty) return cropNameAr!;
    return cropName ?? '';
  }

  factory CropPlanning.fromJson(Map<String, dynamic> json) {
    return CropPlanning(
      id: json['id'],
      userId: json['user_id'],
      cropId: json['crop_id'],
      startDate: json['start_date'],
      expectedHarvestDate: json['expected_harvest_date'],
      notes: json['notes'],
      irrigationReminder: json['irrigation_reminder'],
      fertilizerReminder: json['fertilizer_reminder'],
      planName:   json['plan_name'],
      cropName:   json['crop_name'],
      cropNameFr: json['crop_name_fr'],
      cropNameAr: json['crop_name_ar'],
      createdAt:  json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_id': cropId,
      'plan_name': planName,
      'start_date': startDate,
      'expected_harvest_date': expectedHarvestDate,
      'notes': notes,
      'irrigation_reminder': irrigationReminder,
      'fertilizer_reminder': fertilizerReminder,
    };
  }
}