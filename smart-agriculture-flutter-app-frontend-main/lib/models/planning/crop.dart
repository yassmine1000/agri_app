class Crop {
  final int id;
  final String name;
  final String? nameFr;
  final String? nameAr;
  final String idealSeason;
  final String? idealSeasonFr;
  final String? idealSeasonAr;
  final int durationDays;
  final String? durationLabelEn;
  final String? durationLabelFr;
  final String? durationLabelAr;
  final String idealSowingPeriod;
  final String? idealSowingPeriodFr;
  final String? idealSowingPeriodAr;

  Crop({
    required this.id,
    required this.name,
    this.nameFr,
    this.nameAr,
    required this.idealSeason,
    this.idealSeasonFr,
    this.idealSeasonAr,
    required this.durationDays,
    this.durationLabelEn,
    this.durationLabelFr,
    this.durationLabelAr,
    required this.idealSowingPeriod,
    this.idealSowingPeriodFr,
    this.idealSowingPeriodAr,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      nameFr: json['name_fr'],
      nameAr: json['name_ar'],
      idealSeason: json['ideal_season'] ?? '',
      idealSeasonFr: json['ideal_season_fr'],
      idealSeasonAr: json['ideal_season_ar'],
      durationDays: int.tryParse(json['duration_days'].toString()) ?? 0,
      durationLabelEn: json['duration_label_en'],
      durationLabelFr: json['duration_label_fr'],
      durationLabelAr: json['duration_label_ar'],
      idealSowingPeriod: json['ideal_sowing_period'] ?? '',
      idealSowingPeriodFr: json['ideal_sowing_period_fr'],
      idealSowingPeriodAr: json['ideal_sowing_period_ar'],
    );
  }

  String displayName(String lang) {
    if (lang == 'FR' && nameFr != null) return nameFr!;
    if (lang == 'AR' && nameAr != null) return nameAr!;
    return name;
  }

  String displaySeason(String lang) {
    if (lang == 'FR' && idealSeasonFr != null) return idealSeasonFr!;
    if (lang == 'AR' && idealSeasonAr != null) return idealSeasonAr!;
    return idealSeason;
  }

  String displaySowingPeriod(String lang) {
    if (lang == 'FR' && idealSowingPeriodFr != null) return idealSowingPeriodFr!;
    if (lang == 'AR' && idealSowingPeriodAr != null) return idealSowingPeriodAr!;
    return idealSowingPeriod;
  }

  String displayDuration(String lang) {
    if (lang == 'FR' && durationLabelFr != null) return durationLabelFr!;
    if (lang == 'AR' && durationLabelAr != null) return durationLabelAr!;
    if (durationLabelEn != null) return durationLabelEn!;
    return '$durationDays days';
  }
}