import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../local/pref_helper.dart';
import '../models/planning/crop_planning.dart';
import '../models/planning/crop_task.dart';
import '../service/crop_service.dart';
import '../utils/create_task_dialog.dart';

class PlanningDetailsScreen extends StatefulWidget {
  final CropPlanning planning;
  final bool isDarkMode;
  final String lang;

  const PlanningDetailsScreen({
    super.key,
    required this.planning,
    this.isDarkMode = true,
    this.lang = 'EN',
  });

  @override
  State<PlanningDetailsScreen> createState() => _PlanningDetailsScreenState();
}

class _PlanningDetailsScreenState extends State<PlanningDetailsScreen> {
  late CropService _cropService;
  late Future<List<CropTask>> _futureTasks;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final savedToken = await PrefHelper.getToken();
    if (!mounted) return;
    setState(() {
      token = savedToken;
      _cropService = CropService(authToken: token!);
      _futureTasks = _cropService.getTaskByPlanningId(widget.planning.id);
    });
  }

  void _refreshTasks() {
    if (!mounted) return;
    setState(() { _futureTasks = _cropService.getTaskByPlanningId(widget.planning.id); });
  }

  void _showCreateTaskDialog() {
    showDialog(context: context, builder: (_) => CreateTaskDialog(
      taskService: _cropService,
      planningId: widget.planning.id,
      onTaskCreated: _refreshTasks,
      isDarkMode: widget.isDarkMode,
      lang: widget.lang,
    ));
  }

  Future<void> _updateTaskStatus(CropTask task, String status) async {
    try {
      await _cropService.updateTaskStatus(task.id, status);
      _refreshTasks();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task marked as $status')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _deleteTask(CropTask task) async {
    final l = AppLocalizations.of(context)!;
    final isDark = widget.isDarkMode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : AppColorsLight.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isDark ? AppColors.border : AppColorsLight.border)),
        title: Text(l.deleteTask, style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(l.deleteTaskConfirm, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: isDark ? AppColors.error : AppColorsLight.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(l.delete, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _cropService.deleteTask(task.id);
        _refreshTasks();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  String _formatDate(String d) {
    try { return DateFormat('MMM dd, yyyy').format(DateTime.parse(d)); } catch (e) { return d; }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = widget.planning;
    final isDark = widget.isDarkMode;
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
        title: Text(p.cropName ?? (widget.lang == 'FR' ? 'Détails du planning' : 'Planning Details')),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: border)),
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: primary.withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.cropName ?? (widget.lang == 'FR' ? 'Culture inconnue' : 'Unknown Crop'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.play_circle_outline, size: 14, color: textSecondary),
              const SizedBox(width: 6),
              Text('${widget.lang == 'FR' ? 'Début' : 'Start'}: ${_formatDate(p.startDate)}', style: TextStyle(color: textSecondary, fontSize: 13)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.calendar_month, size: 14, color: textSecondary),
              const SizedBox(width: 6),
              Text('${widget.lang == 'FR' ? 'Récolte' : 'Harvest'}: ${_formatDate(p.expectedHarvestDate)}', style: TextStyle(color: textSecondary, fontSize: 13)),
            ]),
            if (p.notes != null && p.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(p.notes!, style: TextStyle(color: textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
            ],
            if (p.irrigationReminder || p.fertilizerReminder) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [
                if (p.irrigationReminder) _badge('💧 ${widget.lang == 'FR' ? 'Irrigation' : 'Irrigation'}', cyan),
                if (p.fertilizerReminder) _badge('🌿 ${widget.lang == 'FR' ? 'Engrais' : 'Fertilizer'}', primary),
              ]),
            ],
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [Text(l.tasks, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 1.5))]),
        ),
        Expanded(
          child: FutureBuilder<List<CropTask>>(
            future: _futureTasks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primary));
              if (snapshot.hasError) return Center(child: Text('${snapshot.error}', style: TextStyle(color: textSecondary)));
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.task_outlined, color: textSecondary, size: 48),
                  const SizedBox(height: 12),
                  Text(l.noTasksYet, style: TextStyle(color: textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _showCreateTaskDialog, style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l.addFirstTask, style: TextStyle(color: bg, fontWeight: FontWeight.w700))),
                ]));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => _buildTaskItem(snapshot.data![index], primary, textPrimary, textSecondary, surface, border, bg, l),
              );
            },
          ),
        ),
      ]),
      floatingActionButton: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(16)),
        child: FloatingActionButton(onPressed: _showCreateTaskDialog, backgroundColor: Colors.transparent, elevation: 0, child: Icon(Icons.add, color: bg)),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );

  Widget _buildTaskItem(CropTask task, Color primary, Color textPrimary, Color textSecondary, Color surface, Color border, Color bg, AppLocalizations l) {
    final isCompleted = task.status == 'completed';
    final statusColor = isCompleted ? primary : (widget.isDarkMode ? AppColors.gold : AppColorsLight.gold);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: (widget.isDarkMode ? AppColors.surfaceAlt : AppColorsLight.surfaceAlt), borderRadius: BorderRadius.circular(10)), child: Center(child: _getTaskIcon(task.taskType, primary))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.taskType, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary, decoration: isCompleted ? TextDecoration.lineThrough : null)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.calendar_today, size: 11, color: textSecondary),
            const SizedBox(width: 4),
            Text('${widget.lang == 'FR' ? 'Échéance' : 'Due'}: ${_formatDate(task.taskDate)}', style: TextStyle(color: textSecondary, fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)), child: Text(task.status, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600))),
        ])),
        PopupMenuButton<String>(
          color: widget.isDarkMode ? AppColors.surfaceAlt : AppColorsLight.surfaceAlt,
          icon: Icon(Icons.more_vert, color: textSecondary, size: 18),
          onSelected: (value) => value == 'delete' ? _deleteTask(task) : _updateTaskStatus(task, value),
          itemBuilder: (_) => [
            if (!isCompleted) PopupMenuItem(value: 'completed', child: Text(l.markCompleted, style: TextStyle(color: textPrimary, fontSize: 13))),
            if (task.status != 'pending') PopupMenuItem(value: 'pending', child: Text(l.markPending, style: TextStyle(color: textPrimary, fontSize: 13))),
            PopupMenuItem(value: 'delete', child: Text(l.delete, style: TextStyle(color: widget.isDarkMode ? AppColors.error : AppColorsLight.error, fontSize: 13))),
          ],
        ),
      ]),
    );
  }

  Icon _getTaskIcon(String taskType, Color primary) {
    switch (taskType.toLowerCase()) {
      case 'sowing': return Icon(Icons.agriculture, color: primary, size: 20);
      case 'irrigation': return Icon(Icons.water_drop, color: widget.isDarkMode ? AppColors.cyan : AppColorsLight.cyan, size: 20);
      case 'fertilizing': return Icon(Icons.eco, color: widget.isDarkMode ? AppColors.gold : AppColorsLight.gold, size: 20);
      case 'harvesting': return Icon(Icons.forest, color: primary, size: 20);
      default: return Icon(Icons.task_outlined, color: widget.isDarkMode ? AppColors.textSecondary : AppColorsLight.textSecondary, size: 20);
    }
  }
}