import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final bool isDarkMode;
  const HistoryScreen({super.key, this.isDarkMode = true});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Dio _dio = Dio();
  List<dynamic> _history = [];
  bool _loading = true;
  String? _error;
  String _lang = 'EN';

  @override
  void initState() {
    super.initState();
    _initWithLang();
  }

  Future<void> _initWithLang() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _lang = prefs.getString('language') ?? 'EN');
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await PrefHelper.getToken();
      final response = await _dio.get(
        '${Config.baseUrl}/history',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        }),
      );
      setState(() { _history = response.data['data'] ?? []; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context)!.failedToLoadHistory;
        _loading = false;
      });
    }
  }

  // ── Delete a single entry (swipe or tap) ──────────────────────
  Future<void> _deleteOne(int id, AppLocalizations l) async {
    try {
      final token = await PrefHelper.getToken();
      await _dio.delete(
        '${Config.baseUrl}/history/$id',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        }),
      );
      // Remove locally without full reload for instant UI feedback
      if (mounted) {
        setState(() => _history.removeWhere((item) => item['id'] == id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.anErrorOccurred)),
        );
        // Restore item by reloading if delete failed
        _loadHistory();
      }
    }
  }

  // ── Clear all history ─────────────────────────────────────────
  Future<void> _clearHistory(AppLocalizations l, bool isDark) async {
    final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
    final border        = isDark ? AppColors.border        : AppColorsLight.border;
    final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final errorColor    = isDark ? AppColors.error         : AppColorsLight.error;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
        title: Text(l.clearHistory,
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Text(l.clearHistoryConfirm,
            style: TextStyle(color: textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel, style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l.clear,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final token = await PrefHelper.getToken();
      await _dio.delete(
        '${Config.baseUrl}/history',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        }),
      );
      _loadHistory();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) { return dateStr; }
  }

  /// Pick the localized advice — falls back to `advice` for old rows
  String _localizedAdvice(Map item) {
    if (_lang == 'FR') {
      final v = item['advice_fr'] as String?;
      return (v != null && v.isNotEmpty) ? v : item['advice'] ?? '';
    }
    if (_lang == 'AR') {
      final v = item['advice_ar'] as String?;
      return (v != null && v.isNotEmpty) ? v : item['advice'] ?? '';
    }
    final v = item['advice_en'] as String?;
    return (v != null && v.isNotEmpty) ? v : item['advice'] ?? '';
  }

  String _localizedPlantName(Map item) {
    if (_lang == 'FR') return item['plant_name_fr'] ?? _fallbackPlant(item['disease'] ?? '');
    if (_lang == 'AR') return item['plant_name_ar'] ?? _fallbackPlant(item['disease'] ?? '');
    return item['plant_name_en'] ?? _fallbackPlant(item['disease'] ?? '');
  }

  String _localizedDiseaseLabel(Map item) {
    if (_lang == 'FR') return item['disease_label_fr'] ?? _fallbackDisease(item['disease'] ?? '');
    if (_lang == 'AR') return item['disease_label_ar'] ?? _fallbackDisease(item['disease'] ?? '');
    return item['disease_label_en'] ?? _fallbackDisease(item['disease'] ?? '');
  }

  String _fallbackPlant(String disease) {
    final parts = disease.split('___');
    return parts.isNotEmpty ? parts[0].replaceAll('_', ' ') : disease;
  }

  String _fallbackDisease(String disease) {
    final parts = disease.split('___');
    return parts.length > 1
        ? parts[1].replaceAll('_', ' ')
        : disease.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final l             = AppLocalizations.of(context)!;
    final isDark        = widget.isDarkMode;
    final isAr          = _lang == 'AR';
    final bg            = isDark ? AppColors.background    : AppColorsLight.background;
    final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
    final border        = isDark ? AppColors.border        : AppColorsLight.border;
    final primary       = isDark ? AppColors.primary       : AppColorsLight.primary;
    final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final textMuted     = isDark ? AppColors.textMuted     : AppColorsLight.textMuted;
    final errorColor    = isDark ? AppColors.error         : AppColorsLight.error;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          title: Text(l.history),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: border),
          ),
          actions: [
            if (_history.isNotEmpty)
              IconButton(
                icon: Icon(Icons.delete_outline, color: errorColor, size: 20),
                onPressed: () => _clearHistory(l, isDark),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: primary))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: textSecondary, size: 48),
                        const SizedBox(height: 12),
                        Text(_error!, style: TextStyle(color: textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadHistory,
                          style: ElevatedButton.styleFrom(backgroundColor: primary),
                          child: Text(l.retry, style: TextStyle(color: bg)),
                        ),
                      ],
                    ),
                  )
                : _history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, color: textSecondary, size: 60),
                            const SizedBox(height: 12),
                            Text(l.noHistoryYet,
                                style: TextStyle(color: textSecondary, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(l.noHistoryDesc,
                                style: TextStyle(color: textMuted, fontSize: 13)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item        = _history[index] as Map;
                            final confidence  = double.tryParse(item['confidence'].toString()) ?? 0.0;
                            final isHealthy   = (item['disease'] ?? '').toString().contains('healthy');
                            final statusColor = isHealthy ? primary : errorColor;

                            final plantName    = _localizedPlantName(item);
                            final diseaseLabel = _localizedDiseaseLabel(item);
                            final advice       = _localizedAdvice(item);
                            final itemId       = item['id'] as int;

                            return Dismissible(
                              key: Key(itemId.toString()),
                              direction: isAr
                                  ? DismissDirection.startToEnd
                                  : DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.only(
                                  left: isAr ? 20 : 0,
                                  right: isAr ? 0 : 20,
                                ),
                                decoration: BoxDecoration(
                                  color: errorColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: isAr
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Icon(Icons.delete_outline,
                                    color: errorColor, size: 22),
                              ),
                              onDismissed: (_) => _deleteOne(itemId, l),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: border),
                                ),
                                child: Column(
                                  crossAxisAlignment: isAr
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    // ── Header ──────────────────
                                    Row(
                                      children: [
                                        Container(
                                          width: 36, height: 36,
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            isHealthy
                                                ? Icons.check_circle_outline
                                                : Icons.warning_amber_outlined,
                                            color: statusColor, size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: isAr
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                plantName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                  color: textPrimary,
                                                ),
                                              ),
                                              Text(
                                                diseaseLabel,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isHealthy ? primary : errorColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // ── Confidence badge ──
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${(confidence * 100).toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // ── Advice ──────────────────
                                    Text(
                                      advice,
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                                    ),
                                    const SizedBox(height: 6),
                                    // ── Date ────────────────────
                                    Row(
                                      mainAxisAlignment: isAr
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 11, color: textMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(item['detected_at'].toString()),
                                          style: TextStyle(
                                              color: textMuted, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}