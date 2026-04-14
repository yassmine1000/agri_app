import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'package:smart_agri_app/screens/planning_details_screen.dart';
import '../models/planning/crop_planning.dart';
import '../service/crop_service.dart';
import '../utils/create_planning_dialog.dart';

class PlanningTab extends StatefulWidget {
  final CropService cropService;
  final bool isDarkMode;

  const PlanningTab({
    super.key,
    required this.cropService,
    this.isDarkMode = true,
  });

  @override
  State<PlanningTab> createState() => _PlanningTabState();
}

class _PlanningTabState extends State<PlanningTab> {
  Future<List<CropPlanning>>? futurePlanning;
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
      futurePlanning = widget.cropService.getCropPlannings();
    });
  }

  void _refreshPlanning() {
    if (!mounted) return;
    _initWithLang();
  }

  void _showCreatePlanningDialog() {
    showDialog(
      context: context,
      builder: (_) => CreatePlanningDialog(
        cropService: widget.cropService,
        onPlanningCreated: _refreshPlanning,
        isDarkMode: widget.isDarkMode,
        lang: _lang,
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) { return dateString; }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = widget.isDarkMode;
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return Stack(children: [
      RefreshIndicator(
        color: primary,
        onRefresh: () async { _refreshPlanning(); },
        child: FutureBuilder<List<CropPlanning>>(
          future: futurePlanning ?? Future.value([]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primary));
            } else if (snapshot.hasError) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.error_outline, color: textSecondary, size: 48),
                const SizedBox(height: 12),
                Text('${snapshot.error}', style: TextStyle(color: textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshPlanning,
                  style: ElevatedButton.styleFrom(backgroundColor: primary),
                  child: Text(l.retry, style: TextStyle(color: bg)),
                ),
              ]));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.event_note_outlined, color: textSecondary, size: 60),
                const SizedBox(height: 12),
                Text(l.noPlanningYet, style: TextStyle(color: textSecondary, fontSize: 15)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showCreatePlanningDialog,
                  style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(l.createFirstPlan, style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
                ),
              ]));
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final p = snapshot.data![index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlanningDetailsScreen(planning: p, isDarkMode: isDark, lang: _lang)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.eco_outlined, color: primary, size: 18)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(
                          p.cropName ?? (_lang == 'FR' ? 'Culture inconnue' : 'Unknown Crop'),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
                        )),
                        Icon(Icons.arrow_forward_ios, size: 12, color: textSecondary),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Icon(Icons.play_circle_outline, size: 11, color: textSecondary),
                        const SizedBox(width: 4),
                        Text('${_lang == 'FR' ? 'Début' : 'Start'}: ${_formatDate(p.startDate)}', style: TextStyle(color: textSecondary, fontSize: 11)),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_month, size: 11, color: textSecondary),
                        const SizedBox(width: 4),
                        Text('${_lang == 'FR' ? 'Récolte' : 'Harvest'}: ${_formatDate(p.expectedHarvestDate)}', style: TextStyle(color: textSecondary, fontSize: 11)),
                      ]),
                      if (p.notes != null && p.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(p.notes!, style: TextStyle(fontSize: 12, color: textSecondary, fontStyle: FontStyle.italic)),
                      ],
                      if (p.irrigationReminder || p.fertilizerReminder) ...[
                        const SizedBox(height: 10),
                        Wrap(spacing: 8, children: [
                          if (p.irrigationReminder) _badge('💧 ${_lang == 'FR' ? 'Irrigation' : 'Irrigation'}', cyan),
                          if (p.fertilizerReminder) _badge('🌿 ${_lang == 'FR' ? 'Engrais' : 'Fertilizer'}', primary),
                        ]),
                      ],
                    ]),
                  ),
                );
              },
            );
          },
        ),
      ),
      Positioned(
        bottom: 16, right: 16,
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(16)),
          child: FloatingActionButton(
            onPressed: _showCreatePlanningDialog,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(Icons.add, color: bg),
          ),
        ),
      ),
    ]);
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );
}