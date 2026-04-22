import 'package:flutter/material.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class FertilizerGuideScreen extends StatelessWidget {
  final bool isDarkMode;
  const FertilizerGuideScreen({super.key, this.isDarkMode = true});

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context)!;
    final isDark = isDarkMode;
    final isAr   = Localizations.localeOf(context).languageCode == 'ar';

    final bg            = isDark ? AppColors.background    : AppColorsLight.background;
    final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
    final border        = isDark ? AppColors.border        : AppColorsLight.border;
    final gold          = isDark ? AppColors.gold          : AppColorsLight.gold;
    final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    final entries = [
      _FertInfo(
        abbrev: 'UREA',
        emoji: '💧',
        color: const Color(0xFF2196F3),
        fullName: l.ureFullName,
        element: l.ureElement,
        usage: l.ureUsage,
      ),
      _FertInfo(
        abbrev: 'DAP',
        emoji: '🟠',
        color: const Color(0xFFFF9800),
        fullName: l.dapFullName,
        element: l.dapElement,
        usage: l.dapUsage,
      ),
      _FertInfo(
        abbrev: 'MOP',
        emoji: '🟣',
        color: const Color(0xFF9C27B0),
        fullName: l.mopFullName,
        element: l.mopElement,
        usage: l.mopUsage,
      ),
      _FertInfo(
        abbrev: 'SSP',
        emoji: '🟡',
        color: const Color(0xFFFFC107),
        fullName: l.sspFullName,
        element: l.sspElement,
        usage: l.sspUsage,
      ),
      _FertInfo(
        abbrev: '🌿',
        emoji: '🌿',
        color: const Color(0xFF4CAF50),
        fullName: l.compostFullName,
        element: l.compostElement,
        usage: l.compostUsage,
      ),
    ];

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          title: Text(l.fertilizerGuide, style: TextStyle(color: textPrimary)),
          iconTheme: IconThemeData(color: textPrimary),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: border),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ── Header info ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: gold.withOpacity(0.25)),
              ),
              child: Row(children: [
                const Text('⚗️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  l.cropLimitNote,
                  style: TextStyle(color: textSecondary, fontSize: 12, height: 1.5),
                )),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Cards layout — better for mobile ──────────────
            ...entries.asMap().entries.map((entry) {
              final i    = entry.key;
              final fert = entry.value;
              final rowBg = i.isEven
                  ? surface
                  : (isDark ? AppColors.surfaceAlt : AppColorsLight.surfaceAlt);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: rowBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: fert.color.withOpacity(0.25)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // Row 1: emoji + abbrev + full name
                    Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: fert.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text(fert.emoji, style: const TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (fert.abbrev.length <= 4)
                          Text(fert.abbrev, style: TextStyle(color: fert.color, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                        Text(fert.fullName, style: TextStyle(color: fert.color, fontWeight: FontWeight.w600, fontSize: 13)),
                      ])),
                    ]),

                    const SizedBox(height: 10),
                    Divider(height: 1, color: fert.color.withOpacity(0.15)),
                    const SizedBox(height: 10),

                    // Row 2: element badge
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.science_outlined, size: 14, color: fert.color),
                      const SizedBox(width: 6),
                      Expanded(child: Text(fert.element,
                        style: TextStyle(color: fert.color, fontSize: 12, fontWeight: FontWeight.w600))),
                    ]),

                    const SizedBox(height: 8),

                    // Row 3: usage description
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.info_outline, size: 14, color: textSecondary),
                      const SizedBox(width: 6),
                      Expanded(child: Text(fert.usage,
                        style: TextStyle(color: textSecondary, fontSize: 12, height: 1.55))),
                    ]),
                  ]),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // ── Color legend ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NPK', style: TextStyle(color: gold, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  _legendRow('🔵 N', 'Azote / Nitrogen / النيتروجين', textSecondary),
                  _legendRow('🟠 P', 'Phosphore / Phosphorus / الفوسفور', textSecondary),
                  _legendRow('🟣 K', 'Potassium / Potassium / البوتاسيوم', textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(String label, String desc, Color textSecondary) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
      const SizedBox(width: 8),
      Expanded(child: Text(desc, style: TextStyle(color: textSecondary, fontSize: 11))),
    ]),
  );
}

class _FertInfo {
  final String abbrev, emoji, fullName, element, usage;
  final Color color;
  const _FertInfo({
    required this.abbrev,
    required this.emoji,
    required this.color,
    required this.fullName,
    required this.element,
    required this.usage,
  });
}