import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../bloc/fertilizer/fertilizer_bloc.dart';
import 'fertilizer_guide_screen.dart';
import '../bloc/fertilizer/fertilizer_event.dart';
import '../bloc/fertilizer/fertilizer_state.dart';

// ── Translation maps — backend English key → translated display ───
const Map<String, Map<String, String>> _cropTr = {
  'Cotton':  {'fr': 'Coton',          'ar': 'قطن'},
  'Maize':   {'fr': 'Maïs',           'ar': 'ذرة'},
  'Mustard': {'fr': 'Moutarde',       'ar': 'خردل'},
  'Rice':    {'fr': 'Riz',            'ar': 'أرز'},
  'Wheat':   {'fr': 'Blé',            'ar': 'قمح'},
};

const Map<String, Map<String, String>> _stageTr = {
  'Boll Formation': {'fr': 'Formation des capsules', 'ar': 'تكوين القوزة'},
  'Flowering':      {'fr': 'Floraison',              'ar': 'الإزهار'},
  'Grain Fill':     {'fr': 'Remplissage des grains', 'ar': 'امتلاء الحبوب'},
  'Sowing':         {'fr': 'Semis',                  'ar': 'البذر'},
  'Tillering':      {'fr': 'Tallage',                'ar': 'التفريخ'},
  'Vegetative':     {'fr': 'Végétative',             'ar': 'النمو الخضري'},
};

const Map<String, Map<String, String>> _soilTr = {
  'Alluvial':   {'fr': 'Sol alluvial',       'ar': 'تربة رسوبية'},
  'Black Soil': {'fr': 'Sol noir',           'ar': 'تربة سوداء'},
  'Clay Loam':  {'fr': 'Argile limoneuse',   'ar': 'طمي طيني'},
  'Loamy':      {'fr': 'Limoneux',           'ar': 'طمي'},
  'Sandy Loam': {'fr': 'Limon sableux',      'ar': 'طمي رملي'},
};

String _tr(String val, Map<String, Map<String, String>> map, String lang) {
  if (lang == 'EN') return val;
  return map[val]?[lang.toLowerCase()] ?? val;
}

// ─────────────────────────────────────────────────────────────────
class FertilizerForm extends StatefulWidget {
  final ValueNotifier<bool>? isDarkNotifier;
  const FertilizerForm({super.key, this.isDarkNotifier});

  @override
  State<FertilizerForm> createState() => _FertilizerFormState();
}

class _FertilizerFormState extends State<FertilizerForm> {
  final _formKey           = GlobalKey<FormState>();
  final _nCtrl             = TextEditingController();
  final _pCtrl             = TextEditingController();
  final _kCtrl             = TextEditingController();
  final _phCtrl            = TextEditingController();
  final _ocCtrl            = TextEditingController();
  final _tempCtrl          = TextEditingController();
  final _rainCtrl          = TextEditingController();

  String _crop  = '';
  String _stage = '';
  String _soil  = '';
  bool   _isDark = true;

  List<String> _crops     = [];
  List<String> _stages    = [];
  List<String> _soilTypes = [];

  String get _lang => Localizations.localeOf(context).languageCode.toUpperCase();

  @override
  void initState() {
    super.initState();
    if (widget.isDarkNotifier != null) {
      _isDark = widget.isDarkNotifier!.value;
      widget.isDarkNotifier!.addListener(_onTheme);
    } else {
      SharedPreferences.getInstance().then((p) {
        if (mounted) setState(() => _isDark = p.getBool('is_dark_mode') ?? true);
      });
    }
    context.read<FertilizerBloc>().add(FetchDropdowns());
  }

  void _onTheme() { if (mounted) setState(() => _isDark = widget.isDarkNotifier!.value); }

  @override
  void dispose() {
    widget.isDarkNotifier?.removeListener(_onTheme);
    for (final c in [_nCtrl,_pCtrl,_kCtrl,_phCtrl,_ocCtrl,_tempCtrl,_rainCtrl]) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<FertilizerBloc>().add(GetRecommendation({
      'crop':           _crop,
      'stage':          _stage,
      'soil_type':      _soil,
      'N':              double.parse(_nCtrl.text),
      'P':              double.parse(_pCtrl.text),
      'K':              double.parse(_kCtrl.text),
      'pH':             double.parse(_phCtrl.text),
      'organic_carbon': double.parse(_ocCtrl.text),
      'temp':           double.parse(_tempCtrl.text),
      'rainfall':       double.parse(_rainCtrl.text),
    }));
  }

  void _showDialog(String rec, bool isError, AppLocalizations l) {
    final isDark        = _isDark;
    final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
    final border        = isDark ? AppColors.border        : AppColorsLight.border;
    final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final gold          = isDark ? AppColors.gold          : AppColorsLight.gold;
    final bg            = isDark ? AppColors.background    : AppColorsLight.background;
    final errColor      = isDark ? AppColors.error         : AppColorsLight.error;
    final lang          = _lang;

    List<_FertEntry> entries = [];
    if (!isError) try { entries = _parse(rec, l); } catch (_) {}

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isError ? errColor.withOpacity(0.4) : gold.withOpacity(0.3)),
        ),
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: (isError ? errColor : gold).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(isError ? '⚠️' : '⚗️', style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(isError ? l.anErrorOccurred : l.fertilizerResult,
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 15))),
        ]),
        content: isError
            ? Text(rec, style: TextStyle(color: errColor, fontSize: 14, height: 1.6))
            : entries.isEmpty
                ? Text(rec, style: TextStyle(color: textSecondary, fontSize: 14, height: 1.6))
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    // Context chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: gold.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: gold.withOpacity(0.2))),
                      child: Row(children: [
                        const Text('🌾', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(
                          '${_tr(_crop, _cropTr, lang)} · ${_tr(_stage, _stageTr, lang)} · ${_tr(_soil, _soilTr, lang)}',
                          style: TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.w700),
                        )),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    ...entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 7),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(color: e.color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: e.color.withOpacity(0.25))),
                      child: Row(children: [
                        Text(e.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e.name, style: TextStyle(color: e.color, fontWeight: FontWeight.w800, fontSize: 13)),
                          Text(e.desc, style: TextStyle(color: textSecondary, fontSize: 10)),
                        ])),
                        Text('${e.amount} kg\n${l.perAcre}', textAlign: TextAlign.right,
                          style: TextStyle(color: e.color, fontWeight: FontWeight.w900, fontSize: 12)),
                      ]),
                    )).toList(),
                  ]),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: isError ? [errColor, errColor] : [gold, const Color(0xFFFFB300)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('OK', style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  List<_FertEntry> _parse(String raw, AppLocalizations l) {
    final entries = <_FertEntry>[];
    for (final part in raw.split('+').map((s) => s.trim())) {
      final m = RegExp(r'([\d.]+)\s*kg\s+(\w+)').firstMatch(part);
      if (m == null) continue;
      final amt = double.tryParse(m.group(1) ?? '0') ?? 0;
      final name = m.group(2)?.toLowerCase() ?? '';
      if (amt <= 0) continue;
      if (name.contains('urea'))    entries.add(_FertEntry('💧', l.ureaLabel,    amt.toStringAsFixed(1), const Color(0xFF2196F3), 'N: 46%'));
      else if (name == 'dap')       entries.add(_FertEntry('🟠', l.dapLabel,     amt.toStringAsFixed(1), const Color(0xFFFF9800), 'N: 18%, P: 46%'));
      else if (name == 'mop')       entries.add(_FertEntry('🟣', l.mopLabel,     amt.toStringAsFixed(1), const Color(0xFF9C27B0), 'K: 60%'));
      else if (name == 'ssp')       entries.add(_FertEntry('🟡', l.sspLabel,     amt.toStringAsFixed(1), const Color(0xFFFFC107), 'P: 16%, Ca, S'));
      else if (name.contains('compost')) entries.add(_FertEntry('🌿', l.compostLabel, amt.toStringAsFixed(1), const Color(0xFF4CAF50), 'Organique'));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final l    = AppLocalizations.of(context)!;
    final lang = _lang;
    final isAr = lang == 'AR';
    final isDark = _isDark;

    final bg      = isDark ? AppColors.background    : AppColorsLight.background;
    final surface = isDark ? AppColors.surface       : AppColorsLight.surface;
    final sAlt    = isDark ? AppColors.surfaceAlt    : AppColorsLight.surfaceAlt;
    final border  = isDark ? AppColors.border        : AppColorsLight.border;
    final gold    = isDark ? AppColors.gold          : AppColorsLight.gold;
    final tPri    = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
    final tSec    = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return BlocConsumer<FertilizerBloc, FertilizerState>(
      listener: (ctx, state) {
        if (state is FertilizerDropdownsLoaded) {
          setState(() { _crops = state.crops; _stages = state.stages; _soilTypes = state.soilTypes; });
        } else if (state is FertilizerRecommendationSuccess) {
          _showDialog(state.recommendation, false, l);
        } else if (state is FertilizerError) {
          final msg = state.errorMessage.contains('dropdown')
              ? l.failedDropdowns
              : state.errorMessage.startsWith('server_error:')
                  ? state.errorMessage.replaceFirst('server_error: ', '')
                  : l.failedRecommendation;
          _showDialog(msg, true, l);
        }
      },
      builder: (ctx, state) {
        final loading = state is FertilizerLoading;
        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: bg,
              title: Text(l.fertilizerRecommendation, style: TextStyle(color: tPri)),
              iconTheme: IconThemeData(color: tPri),
              actions: [
                IconButton(
                  tooltip: l.fertilizerGuide,
                  icon: Icon(Icons.info_outline_rounded, color: gold, size: 22),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FertilizerGuideScreen(isDarkMode: isDark)),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: border)),
            ),
            body: Form(
              key: _formKey,
              child: ListView(padding: const EdgeInsets.all(20), children: [

                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: gold.withOpacity(0.25))),
                  child: Row(children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: gold.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: Text('⚗️', style: TextStyle(fontSize: 24)))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.fertilizerDesc, style: TextStyle(color: tSec, fontSize: 12, height: 1.5))),
                  ]),
                ),

                const SizedBox(height: 28),
                _sec(l.cropInformation, tSec),
                const SizedBox(height: 12),

                // Dropdowns — display translated, send English
                Row(children: [
                  Expanded(child: _drop(label: l.crop, items: _crops, val: _crop, trMap: _cropTr, lang: lang,
                    onChange: (v) => setState(() => _crop = v!), validator: (v) => v == null ? l.selectCrop : null,
                    surface: surface, sAlt: sAlt, border: border, tPri: tPri, tSec: tSec, gold: gold)),
                  const SizedBox(width: 8),
                  Expanded(child: _drop(label: l.stage, items: _stages, val: _stage, trMap: _stageTr, lang: lang,
                    onChange: (v) => setState(() => _stage = v!), validator: (v) => v == null ? l.selectStage : null,
                    surface: surface, sAlt: sAlt, border: border, tPri: tPri, tSec: tSec, gold: gold)),
                  const SizedBox(width: 8),
                  Expanded(child: _drop(label: l.soilType, items: _soilTypes, val: _soil, trMap: _soilTr, lang: lang,
                    onChange: (v) => setState(() => _soil = v!), validator: (v) => v == null ? l.selectSoil : null,
                    surface: surface, sAlt: sAlt, border: border, tPri: tPri, tSec: tSec, gold: gold)),
                ]),

                const SizedBox(height: 28),
                _sec(l.soilProperties, tSec),
                const SizedBox(height: 12),

                _field(_nCtrl, l.nitrogenLabel, Icons.water_drop_outlined, surface, border, tPri, tSec, gold,
                  (v) { if (v==null||v.isEmpty) return l.required; final n=double.tryParse(v); if(n==null) return l.invalidNumber; if(n<0||n>80) return l.nitrogenRange; return null; }),
                const SizedBox(height: 12),
                _field(_pCtrl, l.phosphorusLabel, Icons.water_drop_outlined, surface, border, tPri, tSec, gold,
                  (v) { if (v==null||v.isEmpty) return l.required; final n=double.tryParse(v); if(n==null) return l.invalidNumber; if(n<0||n>50) return l.phosphorusRange; return null; }),
                const SizedBox(height: 12),
                _field(_kCtrl, l.potassiumLabel, Icons.water_drop_outlined, surface, border, tPri, tSec, gold,
                  (v) { if (v==null||v.isEmpty) return l.required; final n=double.tryParse(v); if(n==null) return l.invalidNumber; if(n<0||n>50) return l.potassiumRange; return null; }),
                const SizedBox(height: 12),
                _field(_phCtrl, l.soilPh, Icons.science_outlined, surface, border, tPri, tSec, gold,
                  (v) { if (v==null||v.isEmpty) return l.required; final n=double.tryParse(v); if(n==null) return l.invalidNumber; if(n<5.5||n>8.0) return l.phRange; return null; }),
                const SizedBox(height: 12),
                _field(_ocCtrl, l.organicCarbon, Icons.grass_outlined, surface, border, tPri, tSec, gold,
                  (v) { if (v==null||v.isEmpty) return l.required; final n=double.tryParse(v); if(n==null) return l.invalidNumber; if(n<0||n>1.5) return l.carbonRange; return null; }),

                const SizedBox(height: 28),
                _sec(l.weatherConditions, tSec),
                const SizedBox(height: 12),

                _field(_tempCtrl, l.temperature, Icons.device_thermostat_outlined, surface, border, tPri, tSec, gold,
                  (v) { if (v==null||v.isEmpty) return l.required; final n=double.tryParse(v); if(n==null) return l.invalidNumber; if(n<18||n>38) return l.tempRange; return null; }),
                const SizedBox(height: 12),
                _field(_rainCtrl, l.rainfall, Icons.cloudy_snowing, surface, border, tPri, tSec, gold,
                  (v) { if (v==null||v.isEmpty) return l.required; final n=double.tryParse(v); if(n==null) return l.invalidNumber; if(n<0||n>120) return l.rainfallRange; return null; }),

                const SizedBox(height: 32),

                Container(
                  width: double.infinity, height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [gold, const Color(0xFFFFB300)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: gold.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: loading
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: bg))
                        : Text(l.getRecommendation, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: bg)),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _sec(String label, Color c) => Text(label.toUpperCase(),
    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c, letterSpacing: 1.5));

  Widget _drop({
    required String label, required List<String> items, required String val,
    required Map<String, Map<String, String>> trMap, required String lang,
    required Function(String?) onChange, required String? Function(String?) validator,
    required Color surface, required Color sAlt, required Color border,
    required Color tPri, required Color tSec, required Color gold,
  }) {
    return DropdownButtonFormField<String>(
      value: val.isEmpty ? null : val,
      dropdownColor: sAlt,
      style: TextStyle(color: tPri, fontSize: 12),
      icon: Icon(Icons.expand_more, color: tSec, size: 16),
      isExpanded: true,
      validator: validator,
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: tSec, fontSize: 11),
        filled: true, fillColor: surface,
        border:             OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
        enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
        focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: gold, width: 1.5)),
        errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade400)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      items: items.map((eng) => DropdownMenuItem<String>(
        value: eng,                              // ← English sent to backend
        child: Text(_tr(eng, trMap, lang),       // ← Translated shown to user
          style: TextStyle(fontSize: 12, color: tPri), overflow: TextOverflow.ellipsis),
      )).toList(),
      onChanged: onChange,
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
    Color surface, Color border, Color tPri, Color tSec, Color gold,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      controller: ctrl,
      style: TextStyle(color: tPri, fontSize: 14),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: tSec, fontSize: 13),
        prefixIcon: Icon(icon, color: tSec, size: 18),
        filled: true, fillColor: surface,
        border:             OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: gold, width: 1.5)),
        errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
      ),
    );
  }
}

class _FertEntry {
  final String emoji, name, amount, desc;
  final Color color;
  const _FertEntry(this.emoji, this.name, this.amount, this.color, this.desc);
}