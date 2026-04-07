import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../models/planning/crop.dart';
import '../models/planning/crop_planning.dart';
import '../service/crop_service.dart';

class CreatePlanningDialog extends StatefulWidget {
  final CropService cropService;
  final VoidCallback onPlanningCreated;
  const CreatePlanningDialog({super.key, required this.cropService, required this.onPlanningCreated});

  @override
  State<CreatePlanningDialog> createState() => _CreatePlanningDialogState();
}

class _CreatePlanningDialogState extends State<CreatePlanningDialog> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<Crop>> futureCrops;
  int? _selectedCropId;
  DateTime? _startDate;
  DateTime? _expectedHarvestDate;
  String _notes = '';
  bool _irrigationReminder = false;
  bool _fertilizerReminder = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    futureCrops = widget.cropService.getCropLibrary();
  }

  Widget _dateTile(IconData icon, Color color, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
      title: const Text('Create Crop Plan', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      content: FutureBuilder<List<Crop>>(
        future: futureCrops,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
          if (snapshot.hasError) return SizedBox(height: 200, child: Center(child: Text('${snapshot.error}', style: const TextStyle(color: AppColors.textSecondary))));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No crops available', style: TextStyle(color: AppColors.textSecondary))));

          return SizedBox(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: ListView(shrinkWrap: true, children: [
                DropdownButtonFormField<int>(
                  value: _selectedCropId,
                  dropdownColor: AppColors.surfaceAlt,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Select Crop',
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    filled: true, fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                  items: snapshot.data!.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedCropId = v),
                  validator: (v) => v == null ? 'Select a crop' : null,
                ),
                const SizedBox(height: 12),
                _dateTile(Icons.play_circle_outline, AppColors.cyan, _startDate == null ? 'Select Start Date' : 'Start: ${DateFormat('dd/MM/yyyy').format(_startDate!)}', () async {
                  final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (d != null) setState(() => _startDate = d);
                }),
                const SizedBox(height: 8),
                _dateTile(Icons.agriculture, AppColors.gold, _expectedHarvestDate == null ? 'Select Harvest Date' : 'Harvest: ${DateFormat('dd/MM/yyyy').format(_expectedHarvestDate!)}', () async {
                  final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime(2100));
                  if (d != null) setState(() => _expectedHarvestDate = d);
                }),
                const SizedBox(height: 12),
                TextFormField(
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    filled: true, fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                  maxLines: 2,
                  onChanged: (v) => _notes = v,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('💧 Irrigation Reminder', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  value: _irrigationReminder,
                  activeColor: AppColors.cyan,
                  onChanged: (v) => setState(() => _irrigationReminder = v),
                ),
                SwitchListTile(
                  title: const Text('🌿 Fertilizer Reminder', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  value: _fertilizerReminder,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _fertilizerReminder = v),
                ),
              ]),
            ),
          );
        },
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
                : const Text('Create Plan', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select start date'))); return; }
    if (_expectedHarvestDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select harvest date'))); return; }
    setState(() => _isSubmitting = true);
    final planning = CropPlanning(id: 0, userId: 0, cropId: _selectedCropId!, startDate: _startDate!.toIso8601String(), expectedHarvestDate: _expectedHarvestDate!.toIso8601String(), notes: _notes.isNotEmpty ? _notes : null, irrigationReminder: _irrigationReminder, fertilizerReminder: _fertilizerReminder, cropName: '');
    try {
      await widget.cropService.createCropPlanning(planning);
      if (mounted) { Navigator.pop(context); widget.onPlanningCreated(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan created!'))); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}