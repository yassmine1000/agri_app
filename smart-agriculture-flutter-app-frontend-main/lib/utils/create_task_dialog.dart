import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../service/crop_service.dart';

class CreateTaskDialog extends StatefulWidget {
  final CropService taskService;
  final int planningId;
  final VoidCallback onTaskCreated;
  const CreateTaskDialog({super.key, required this.taskService, required this.planningId, required this.onTaskCreated});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _taskTypes = ['Sowing', 'Irrigation', 'Fertilizing', 'Weeding', 'Pruning', 'Harvesting', 'Inspection'];
  String? _selectedTaskType;
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
      title: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_task, color: AppColors.primary, size: 18)),
        const SizedBox(width: 10),
        const Text('New Task', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            value: _selectedTaskType,
            dropdownColor: AppColors.surfaceAlt,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Task Type',
              labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              prefixIcon: const Icon(Icons.category_outlined, color: AppColors.textSecondary, size: 18),
              filled: true, fillColor: AppColors.surfaceAlt,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
            items: _taskTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _selectedTaskType = v),
            validator: (v) => v == null ? 'Select a task type' : null,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (d != null) setState(() => _selectedDate = d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
                const SizedBox(width: 10),
                Text(
                  _selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                  style: TextStyle(color: _selectedDate == null ? AppColors.textSecondary : AppColors.textPrimary, fontSize: 13),
                ),
              ]),
            ),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
        Container(
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.cyan]), borderRadius: BorderRadius.circular(10)),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: _isSubmitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                : const Text('Create', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a date'))); return; }
    setState(() => _isSubmitting = true);
    try {
      await widget.taskService.createCropTask(widget.planningId, _selectedTaskType!, DateFormat('yyyy-MM-dd').format(_selectedDate!));
      if (mounted) { Navigator.pop(context); widget.onTaskCreated(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created!'))); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}