import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../service/crop_service.dart';

class CreateTaskDialog extends StatefulWidget {
  final CropService taskService;
  final int planningId;
  final VoidCallback onTaskCreated;
  final bool isDarkMode;
  final String lang;

  const CreateTaskDialog({
    super.key,
    required this.taskService,
    required this.planningId,
    required this.onTaskCreated,
    this.isDarkMode = true,
    this.lang = 'EN',
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _taskTypes = ['Sowing', 'Irrigation', 'Fertilizing', 'Weeding', 'Pruning', 'Harvesting', 'Inspection'];
  final Map<String, String> _taskTypesFr = {
    'Sowing': 'Semis', 'Irrigation': 'Irrigation', 'Fertilizing': 'Fertilisation',
    'Weeding': 'Désherbage', 'Pruning': 'Taille', 'Harvesting': 'Récolte', 'Inspection': 'Inspection',
  };

  String? _selectedTaskType;
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = widget.isDarkMode;
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final surfaceAlt = isDark ? AppColors.surfaceAlt : AppColorsLight.surfaceAlt;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return AlertDialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
      title: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.add_task, color: primary, size: 18)),
        const SizedBox(width: 10),
        Text(l.newTask, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            value: _selectedTaskType,
            dropdownColor: surfaceAlt,
            style: TextStyle(color: textPrimary, fontSize: 13),
            decoration: InputDecoration(
              labelText: l.taskType, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
              prefixIcon: Icon(Icons.category_outlined, color: textSecondary, size: 18),
              filled: true, fillColor: surfaceAlt,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
            ),
            items: _taskTypes.map((t) => DropdownMenuItem(value: t, child: Text(widget.lang == 'FR' ? (_taskTypesFr[t] ?? t) : t))).toList(),
            onChanged: (v) => setState(() => _selectedTaskType = v),
            validator: (v) => v == null ? l.required : null,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (d != null) setState(() => _selectedDate = d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
              child: Row(children: [
                Icon(Icons.calendar_today, color: primary, size: 16),
                const SizedBox(width: 10),
                Text(
                  _selectedDate == null ? l.selectDate : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                  style: TextStyle(color: _selectedDate == null ? textSecondary : textPrimary, fontSize: 13),
                ),
              ]),
            ),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: Text(l.cancel, style: TextStyle(color: textSecondary))),
        Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(10)),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: _isSubmitting
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: bg))
                : Text(l.create, style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.selectDate))); return; }
    setState(() => _isSubmitting = true);
    try {
      await widget.taskService.createCropTask(widget.planningId, _selectedTaskType!, DateFormat('yyyy-MM-dd').format(_selectedDate!));
      if (mounted) { Navigator.pop(context); widget.onTaskCreated(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.taskCreated))); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}