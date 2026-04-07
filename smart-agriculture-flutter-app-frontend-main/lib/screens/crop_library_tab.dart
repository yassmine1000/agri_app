import 'package:flutter/material.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../models/planning/crop.dart';
import '../service/crop_service.dart';

class CropLibraryTab extends StatefulWidget {
  final CropService cropService;
  const CropLibraryTab({super.key, required this.cropService});

  @override
  State<CropLibraryTab> createState() => _CropLibraryTabState();
}

class _CropLibraryTabState extends State<CropLibraryTab> {
  late Future<List<Crop>> futureCrops;

  @override
  void initState() {
    super.initState();
    futureCrops = widget.cropService.getCropLibrary();
  }

  void _refreshCrops() => setState(() { futureCrops = widget.cropService.getCropLibrary(); });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async { _refreshCrops(); await futureCrops; },
      child: FutureBuilder<List<Crop>>(
        future: futureCrops,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.error_outline, color: AppColors.textSecondary, size: 48),
                const SizedBox(height: 12),
                Text('${snapshot.error}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _refreshCrops, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Retry', style: TextStyle(color: AppColors.background))),
              ]),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No crops available', style: TextStyle(color: AppColors.textSecondary)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final crop = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(crop.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(crop.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.calendar_today, size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(crop.idealSeason, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.timelapse, size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${crop.durationDays} days', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ]),
                        const SizedBox(height: 3),
                        Row(children: [
                          const Icon(Icons.grass, size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(crop.idealSowingPeriod, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ]),
                      ]),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}