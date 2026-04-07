import 'package:flutter/material.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'package:smart_agri_app/screens/planning_details_screen.dart';
import '../models/planning/crop_planning.dart';
import '../service/crop_service.dart';
import '../utils/create_planning_dialog.dart';

class PlanningTab extends StatefulWidget {
  final CropService cropService;
  const PlanningTab({super.key, required this.cropService});

  @override
  State<PlanningTab> createState() => _PlanningTabState();
}

class _PlanningTabState extends State<PlanningTab> {
  late Future<List<CropPlanning>> futurePlanning;

  @override
  void initState() {
    super.initState();
    futurePlanning = widget.cropService.getCropPlannings();
  }

  void _refreshPlanning() => setState(() { futurePlanning = widget.cropService.getCropPlannings(); });

  void _showCreatePlanningDialog() {
    showDialog(
      context: context,
      builder: (_) => CreatePlanningDialog(cropService: widget.cropService, onPlanningCreated: _refreshPlanning),
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
    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async { _refreshPlanning(); await futurePlanning; },
          child: FutureBuilder<List<CropPlanning>>(
            future: futurePlanning,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              } else if (snapshot.hasError) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, color: AppColors.textSecondary, size: 48),
                  const SizedBox(height: 12),
                  Text('${snapshot.error}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _refreshPlanning, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Retry', style: TextStyle(color: AppColors.background))),
                ]));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.event_note_outlined, color: AppColors.textSecondary, size: 60),
                  const SizedBox(height: 12),
                  const Text('No planning records yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showCreatePlanningDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Create First Plan', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w700)),
                  ),
                ]));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final p = snapshot.data![index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlanningDetailsScreen(planning: p))),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.eco_outlined, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(p.cropName ?? 'Unknown Crop', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          _infoChip(Icons.play_circle_outline, 'Start: ${_formatDate(p.startDate)}'),
                          const SizedBox(width: 8),
                          _infoChip(Icons.calendar_month, 'Harvest: ${_formatDate(p.expectedHarvestDate)}'),
                        ]),
                        if (p.notes != null && p.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(p.notes!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                        ],
                        if (p.irrigationReminder || p.fertilizerReminder) ...[
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, children: [
                            if (p.irrigationReminder) _badge('💧 Irrigation', AppColors.cyan),
                            if (p.fertilizerReminder) _badge('🌿 Fertilizer', AppColors.primary),
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
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.cyan]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: FloatingActionButton(
              onPressed: _showCreatePlanningDialog,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add, color: AppColors.background),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 11, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
    ]);
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}