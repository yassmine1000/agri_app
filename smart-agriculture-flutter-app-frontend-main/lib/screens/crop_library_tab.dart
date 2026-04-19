import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../models/planning/crop.dart';
import '../service/crop_service.dart';

class CropLibraryTab extends StatefulWidget {
  final CropService cropService;
  final bool isDarkMode;

  const CropLibraryTab({
    super.key,
    required this.cropService,
    this.isDarkMode = true,
  });

  @override
  State<CropLibraryTab> createState() => _CropLibraryTabState();
}

class _CropLibraryTabState extends State<CropLibraryTab> {
  Future<List<Crop>>? futureCrops;
  String _lang = 'EN';

  @override
  void initState() {
    super.initState();
    _initWithLang();
  }

  Future<void> _initWithLang() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _lang = prefs.getString('language') ?? 'EN';
      futureCrops = widget.cropService.getCropLibrary();
    });
  }

  void _refreshCrops() {
    if (!mounted) return;
    _initWithLang();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = widget.isDarkMode;
    final isAr = _lang == 'AR';
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: RefreshIndicator(
        color: primary,
        onRefresh: () async { _refreshCrops(); },
        child: FutureBuilder<List<Crop>>(
          future: futureCrops ?? Future.value([]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primary));
            } else if (snapshot.hasError) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.error_outline, color: textSecondary, size: 48),
                const SizedBox(height: 12),
                Text('${snapshot.error}', style: TextStyle(color: textSecondary, fontSize: 13), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshCrops,
                  style: ElevatedButton.styleFrom(backgroundColor: primary),
                  child: Text(l.retry, style: TextStyle(color: bg)),
                ),
              ]));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(l.noCropsAvailable, style: TextStyle(color: textSecondary)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final crop = snapshot.data![index];
                final name = crop.displayName(_lang);
                final season = crop.displaySeason(_lang);
                final sowingPeriod = crop.displaySowingPeriod(_lang);
                final duration = crop.displayDuration(_lang);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(
                        name[0].toUpperCase(),
                        style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 20),
                      )),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                      Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: isAr ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Icon(Icons.calendar_today, size: 11, color: textSecondary),
                          const SizedBox(width: 4),
                          Flexible(child: Text(season, style: TextStyle(color: textSecondary, fontSize: 11))),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: isAr ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Icon(Icons.timelapse, size: 11, color: textSecondary),
                          const SizedBox(width: 4),
                          Text(duration, style: TextStyle(color: textSecondary, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: isAr ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Icon(Icons.grass, size: 11, color: textSecondary),
                          const SizedBox(width: 4),
                          Flexible(child: Text(sowingPeriod, style: TextStyle(color: textSecondary, fontSize: 11))),
                        ],
                      ),
                    ])),
                  ]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}         