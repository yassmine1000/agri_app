import 'package:flutter/material.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'history_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Function(bool) onThemeChange;
  final ValueNotifier<bool> isDarkNotifier;

  const SettingsScreen({
    super.key,
    required this.onLocaleChange,
    required this.onThemeChange,
    required this.isDarkNotifier,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'EN';
  String _imageQuality = 'high';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'EN';
      _imageQuality = prefs.getString('image_quality') ?? 'high';
    });
  }

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => _selectedLanguage = lang);
    final localeMap = {'EN': const Locale('en'), 'FR': const Locale('fr')};
    widget.onLocaleChange(localeMap[lang]!);
  }

  Future<void> _saveImageQuality(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('image_quality', quality);
    setState(() => _imageQuality = quality);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDarkNotifier,
      builder: (context, isDark, _) {
        final l = AppLocalizations.of(context)!;
        final bg = isDark ? AppColors.background : AppColorsLight.background;
        final surface = isDark ? AppColors.surface : AppColorsLight.surface;
        final border = isDark ? AppColors.border : AppColorsLight.border;
        final primary = isDark ? AppColors.primary : AppColorsLight.primary;
        final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
        final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            title: Text(l.settings),
            bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: border)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Language
              _sectionLabel(l.language, textSecondary),
              _card(surface, border, child: Row(
                children: ['EN', 'FR'].map((lang) {
                  final selected = _selectedLanguage == lang;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _saveLanguage(lang),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? primary.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? primary : border),
                        ),
                        child: Column(children: [
                          Text(lang == 'EN' ? '🇬🇧' : '🇫🇷', style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(lang == 'EN' ? 'English' : 'Français',
                            style: TextStyle(fontSize: 12, color: selected ? primary : textSecondary, fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              )),

              const SizedBox(height: 20),

              // Dark Mode
              _sectionLabel(l.appearance, textSecondary),
              _card(surface, border, child: Row(children: [
                Icon(Icons.dark_mode_outlined, color: textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.darkMode, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(l.darkModeDesc, style: TextStyle(color: textSecondary, fontSize: 12)),
                ])),
                Switch(
                  value: isDark,
                  activeColor: primary,
                  onChanged: (val) {
                    widget.isDarkNotifier.value = val;
                    widget.onThemeChange(val);
                  },
                ),
              ])),

              const SizedBox(height: 20),

              // Image Quality
              _sectionLabel(l.imageQuality, textSecondary),
              _card(surface, border, child: Column(children: [
                _qualityOption(l.low, l.lowDesc, Icons.image_outlined, 'low', primary, textPrimary, textSecondary),
                Divider(height: 16, color: border, thickness: 0.5),
                _qualityOption(l.medium, l.mediumDesc, Icons.image, 'medium', primary, textPrimary, textSecondary),
                Divider(height: 16, color: border, thickness: 0.5),
                _qualityOption(l.high, l.highDesc, Icons.hd_outlined, 'high', primary, textPrimary, textSecondary),
              ])),

              const SizedBox(height: 20),

              // History
              _sectionLabel(l.data, textSecondary),
              _card(surface, border, child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen(isDarkMode: isDark))),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: cyan.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.history, color: cyan, size: 18)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.detectionHistory, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(l.detectionHistoryDesc, style: TextStyle(color: textSecondary, fontSize: 12)),
                  ])),
                  Icon(Icons.arrow_forward_ios, size: 14, color: textSecondary),
                ]),
              )),

              const SizedBox(height: 20),

              // About
              _sectionLabel(l.about, textSecondary),
              _card(surface, border, child: Column(children: [
                _infoRow(l.appNameLabel, 'AgriScan', textPrimary, textSecondary),
                Divider(height: 16, color: border, thickness: 0.5),
                _infoRow(l.version, '1.0.0', textPrimary, textSecondary),
                Divider(height: 16, color: border, thickness: 0.5),
                _infoRow(l.developer, 'Jarray Agro', textPrimary, textSecondary),
                Divider(height: 16, color: border, thickness: 0.5),
                _infoRow(l.technology, 'Flutter + Node.js + AI', textPrimary, textSecondary),
              ])),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.5)),
  );

  Widget _card(Color surface, Color border, {required Widget child}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
    child: child,
  );

  Widget _qualityOption(String label, String subtitle, IconData icon, String value, Color primary, Color textPrimary, Color textSecondary) {
    final selected = _imageQuality == value;
    return GestureDetector(
      onTap: () => _saveImageQuality(value),
      child: Row(children: [
        Icon(icon, color: selected ? primary : textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: selected ? primary : textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 12)),
        ])),
        if (selected) Icon(Icons.check_circle, color: primary, size: 18),
      ]),
    );
  }

  Widget _infoRow(String label, String value, Color textPrimary, Color textSecondary) => Row(children: [
    Text(label, style: TextStyle(color: textSecondary, fontSize: 13)),
    const Spacer(),
    Text(value, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
  ]);
}