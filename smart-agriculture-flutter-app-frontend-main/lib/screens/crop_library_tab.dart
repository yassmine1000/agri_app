import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../models/planning/crop.dart';
import '../service/crop_service.dart';

// ── Category enum ────────────────────────────────────────────
enum CropCategory { vegetable, fruit, cereal, herb }

extension CropCategoryExtension on CropCategory {
  String get key {
    switch (this) {
      case CropCategory.vegetable: return 'vegetable';
      case CropCategory.fruit:     return 'fruit';
      case CropCategory.cereal:    return 'cereal';
      case CropCategory.herb:      return 'herb';
    }
  }

  String label(String lang) {
    switch (this) {
      case CropCategory.vegetable:
        if (lang == 'FR') return 'Légumes';
        if (lang == 'AR') return 'خضروات';
        return 'Vegetables';
      case CropCategory.fruit:
        if (lang == 'FR') return 'Fruits';
        if (lang == 'AR') return 'فواكه';
        return 'Fruits';
      case CropCategory.cereal:
        if (lang == 'FR') return 'Céréales';
        if (lang == 'AR') return 'حبوب';
        return 'Cereals';
      case CropCategory.herb:
        if (lang == 'FR') return 'Herbes';
        if (lang == 'AR') return 'أعشاب';
        return 'Herbs';
    }
  }

  IconData get icon {
    switch (this) {
      case CropCategory.vegetable: return Icons.eco;
      case CropCategory.fruit:     return Icons.park;
      case CropCategory.cereal:    return Icons.grain;
      case CropCategory.herb:      return Icons.spa;
    }
  }
}

// ── Widget ───────────────────────────────────────────────────
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

class _CropLibraryTabState extends State<CropLibraryTab>
    with SingleTickerProviderStateMixin {
  Future<List<Crop>>? futureCrops;
  String _lang = 'EN';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: CropCategory.values.length, vsync: this);
    _initWithLang();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  String _localizeError(String error, AppLocalizations l) {
    final msg = error.toLowerCase();
    if (msg.contains('farmer') || msg.contains('access only') || msg.contains('403')) {
      return l.farmerAccessOnly;
    }
    if (msg.contains('admin')) return l.adminAccessOnly;
    return l.anErrorOccurred;
  }

  List<Crop> _filterByCategory(List<Crop> crops, CropCategory cat) {
    return crops.where((c) => c.category == cat.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l    = AppLocalizations.of(context)!;
    final isDark = widget.isDarkMode;
    final isAr   = _lang == 'AR';

    final bg          = isDark ? AppColors.background       : AppColorsLight.background;
    final surface     = isDark ? AppColors.surface          : AppColorsLight.surface;
    final border      = isDark ? AppColors.border           : AppColorsLight.border;
    final primary     = isDark ? AppColors.primary          : AppColorsLight.primary;
    final textPrimary = isDark ? AppColors.textPrimary      : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary  : AppColorsLight.textSecondary;
    final surfaceAlt  = isDark ? AppColors.surfaceAlt       : AppColorsLight.surfaceAlt;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        children: [
          // ── Tab bar ────────────────────────────────────────
          Container(
            color: bg,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: primary,
              indicatorWeight: 2.5,
              labelColor: primary,
              unselectedLabelColor: textSecondary,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              dividerColor: border,
              tabs: CropCategory.values.map((cat) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 14),
                    const SizedBox(width: 5),
                    Text(cat.label(_lang)),
                  ],
                ),
              )).toList(),
            ),
          ),
          // ── Content ────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Crop>>(
              future: futureCrops ?? Future.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primary));
                }

                if (snapshot.hasError) {
                  return Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, color: textSecondary, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _localizeError('${snapshot.error}', l),
                        style: TextStyle(color: textSecondary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshCrops,
                        style: ElevatedButton.styleFrom(backgroundColor: primary),
                        child: Text(l.retry, style: TextStyle(color: bg)),
                      ),
                    ],
                  ));
                }

                final allCrops = snapshot.data ?? [];

                return TabBarView(
                  controller: _tabController,
                  children: CropCategory.values.map((cat) {
                    final filtered = _filterByCategory(allCrops, cat);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          l.noCropsAvailable,
                          style: TextStyle(color: textSecondary),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: primary,
                      onRefresh: () async { _refreshCrops(); },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final crop        = filtered[index];
                          final name        = crop.displayName(_lang);
                          final season      = crop.displaySeason(_lang);
                          final sowingPeriod = crop.displaySowingPeriod(_lang);
                          final duration    = crop.displayDuration(_lang);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: border),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ── Colored left accent bar ──
                                  Container(
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color: primary.withOpacity(0.7),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(14),
                                        bottomLeft: Radius.circular(14),
                                      ),
                                    ),
                                  ),
                                  // ── Icon ──
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    child: Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                        color: primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Icon(cat.icon, color: primary, size: 20),
                                      ),
                                    ),
                                  ),
                                  // ── Info ──
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                      child: Column(
                                        crossAxisAlignment: isAr
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          _InfoRow(
                                            icon: Icons.wb_sunny_outlined,
                                            text: season,
                                            textSecondary: textSecondary,
                                            isAr: isAr,
                                          ),
                                          const SizedBox(height: 3),
                                          _InfoRow(
                                            icon: Icons.timelapse,
                                            text: duration,
                                            textSecondary: textSecondary,
                                            isAr: isAr,
                                          ),
                                          const SizedBox(height: 3),
                                          _InfoRow(
                                            icon: Icons.grass,
                                            text: sowingPeriod,
                                            textSecondary: textSecondary,
                                            isAr: isAr,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // ── Category chip ──
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12, top: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: surfaceAlt,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: border),
                                      ),
                                      child: Text(
                                        cat.label(_lang),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable info row ─────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color textSecondary;
  final bool isAr;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.textSecondary,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isAr ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Icon(icon, size: 11, color: textSecondary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: textSecondary, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}