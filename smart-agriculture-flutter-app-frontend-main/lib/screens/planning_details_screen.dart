import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../local/pref_helper.dart';
import '../models/planning/crop_planning.dart';
import '../models/planning/crop_task.dart';
import '../service/crop_service.dart';
import '../utils/create_task_dialog.dart';

class PlanningDetailsScreen extends StatefulWidget {
  final CropPlanning planning;
  const PlanningDetailsScreen({super.key, required this.planning});

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
    setState(() {
      token = savedToken;
      _cropService = CropService(authToken: token!);
      _futureTasks = _cropService.getTaskByPlanningId(widget.planning.id);
    });
  }

  void _refreshTasks() => setState(() { _futureTasks = _cropService.getTaskByPlanningId(widget.planning.id); });

  void _showCreateTaskDialog() {
    showDialog(context: context, builder: (_) => CreateTaskDialog(taskService: _cropService, planningId: widget.planning.id, onTaskCreated: _refreshTasks));
  }

  Future<void> _updateTaskStatus(CropTask task, String status) async {
    try {
      await _cropService.updateTaskStatus(task.id, status);
      _refreshTasks();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task marked as $status')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _deleteTask(CropTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
        title: const Text('Delete Task', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Delete', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _cropService.deleteTask(task.id);
        _refreshTasks();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  String _formatDate(String d) {
    try { return DateFormat('MMM dd, yyyy').format(DateTime.parse(d)); } catch (e) { return d; }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.planning;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(p.cropName ?? 'Planning Details'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: Column(
        children: [
          // Header card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.cropName ?? 'Unknown Crop', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.play_circle_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Start: ${_formatDate(p.startDate)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_month, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Harvest: ${_formatDate(p.expectedHarvestDate)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ]),
              if (p.notes != null && p.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(p.notes!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              const Text('TASKS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
            ]),
          ),

          Expanded(
            child: FutureBuilder<List<CropTask>>(
              future: _futureTasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                if (snapshot.hasError) return Center(child: Text('${snapshot.error}', style: const TextStyle(color: AppColors.textSecondary)));
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.task_outlined, color: AppColors.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    const Text('No tasks yet', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _showCreateTaskDialog, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Add First Task', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w700))),
                  ]));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => _buildTaskItem(snapshot.data![index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.cyan]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton(
          onPressed: _showCreateTaskDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: AppColors.background),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );

  Widget _buildTaskItem(CropTask task) {
    final isCompleted = task.status == 'completed';
    final statusColor = isCompleted ? AppColors.primary : AppColors.gold;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
          child: Center(child: _getTaskIcon(task.taskType)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.taskType, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, decoration: isCompleted ? TextDecoration.lineThrough : null)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today, size: 11, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Due: ${_formatDate(task.taskDate)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(task.status, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
          ),
        ])),
        PopupMenuButton<String>(
          color: AppColors.surfaceAlt,
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 18),
          onSelected: (value) => value == 'delete' ? _deleteTask(task) : _updateTaskStatus(task, value),
          itemBuilder: (_) => [
            if (!isCompleted) const PopupMenuItem(value: 'completed', child: Text('Mark Completed', style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
            if (task.status != 'pending') const PopupMenuItem(value: 'pending', child: Text('Mark Pending', style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 13))),
          ],
        ),
      ]),
    );
  }

  Icon _getTaskIcon(String taskType) {
    switch (taskType.toLowerCase()) {
      case 'sowing': return const Icon(Icons.agriculture, color: AppColors.primary, size: 20);
      case 'irrigation': return const Icon(Icons.water_drop, color: AppColors.cyan, size: 20);
      case 'fertilizing': return const Icon(Icons.eco, color: AppColors.gold, size: 20);
      case 'harvesting': return const Icon(Icons.forest, color: AppColors.primary, size: 20);
      default: return const Icon(Icons.task_outlined, color: AppColors.textSecondary, size: 20);
    }
  }
}