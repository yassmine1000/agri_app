class Crop {
  final int id;
  final String name;
  final String? nameFr;
  final String idealSeason;
  final String? idealSeasonFr;
  final int durationDays;
  final String idealSowingPeriod;
  final String? idealSowingPeriodFr;

  Crop({
    required this.id,
    required this.name,
    this.nameFr,
    required this.idealSeason,
    this.idealSeasonFr,
    required this.durationDays,
    required this.idealSowingPeriod,
    this.idealSowingPeriodFr,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
  return Crop(
    id: int.tryParse(json['id'].toString()) ?? 0,
    name: json['name'] ?? '',
    nameFr: json['name_fr'],
    idealSeason: json['ideal_season'] ?? '',
    idealSeasonFr: json['ideal_season_fr'],
    durationDays: int.tryParse(json['duration_days'].toString()) ?? 0,
    idealSowingPeriod: json['ideal_sowing_period'] ?? '',
    idealSowingPeriodFr: json['ideal_sowing_period_fr'],
  );
}

  String displayName(String lang) => lang == 'FR' && nameFr != null ? nameFr! : name;
  String displaySeason(String lang) => lang == 'FR' && idealSeasonFr != null ? idealSeasonFr! : idealSeason;
  String displaySowingPeriod(String lang) => lang == 'FR' && idealSowingPeriodFr != null ? idealSowingPeriodFr! : idealSowingPeriod;
}