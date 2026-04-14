import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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

  @override
  void initState() { super.initState(); _loadHistory(); }

  Future<void> _loadHistory() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await PrefHelper.getToken();
      final response = await _dio.get('${Config.baseUrl}/history', options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}));
      setState(() { _history = response.data['data'] ?? []; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load history'; _loading = false; });
    }
  }

  Future<void> _clearHistory(AppLocalizations l, bool isDark) async {
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final errorColor = isDark ? AppColors.error : AppColorsLight.error;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: border)),
        title: Text(l.clearHistory, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Text(l.clearHistoryConfirm, style: TextStyle(color: textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel, style: TextStyle(color: textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: errorColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(l.clear, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final token = await PrefHelper.getToken();
      await _dio.delete('${Config.baseUrl}/history', options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}));
      _loadHistory();
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) { return dateStr; }
  }

  String _formatDisease(String disease) => disease.replaceAll('___', ' — ').replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = widget.isDarkMode;
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final textMuted = isDark ? AppColors.textMuted : AppColorsLight.textMuted;
    final errorColor = isDark ? AppColors.error : AppColorsLight.error;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(l.history),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: border)),
        actions: [
          if (_history.isNotEmpty)
            IconButton(icon: Icon(Icons.delete_outline, color: errorColor, size: 20), onPressed: () => _clearHistory(l, isDark)),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.error_outline, color: textSecondary, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadHistory, style: ElevatedButton.styleFrom(backgroundColor: primary), child: Text(l.retry, style: TextStyle(color: bg))),
                ]))
              : _history.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.history, color: textSecondary, size: 60),
                      const SizedBox(height: 12),
                      Text(l.noHistoryYet, style: TextStyle(color: textSecondary, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(l.noHistoryDesc, style: TextStyle(color: textMuted, fontSize: 13)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _loadHistory, color: primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          final confidence = double.tryParse(item['confidence'].toString()) ?? 0.0;
                          final isHealthy = item['disease'].toString().contains('healthy');
                          final statusColor = isHealthy ? primary : errorColor;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Container(width: 36, height: 36, decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                                  child: Icon(isHealthy ? Icons.check_circle_outline : Icons.warning_amber_outlined, color: statusColor, size: 18)),
                                const SizedBox(width: 10),
                                Expanded(child: Text(_formatDisease(item['disease']), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isHealthy ? primary : textPrimary))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                                  child: Text('${(confidence * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                                ),
                              ]),
                              const SizedBox(height: 8),
                              Text(item['advice'], style: TextStyle(color: textSecondary, fontSize: 12, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Row(children: [
                                Icon(Icons.access_time, size: 11, color: textMuted),
                                const SizedBox(width: 4),
                                Text(_formatDate(item['detected_at']), style: TextStyle(color: textMuted, fontSize: 11)),
                              ]),
                            ]),
                          );
                        },
                      ),
                    ),
    );
  }
}