import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../models/planning/crop.dart';
import '../service/notification_service.dart';
import '../models/planning/crop_planning.dart';
import '../service/crop_service.dart';

class CreatePlanningDialog extends StatefulWidget {
  final CropService cropService;
  final VoidCallback onPlanningCreated;
  final bool isDarkMode;
  final String lang;

  const CreatePlanningDialog({
    super.key,
    required this.cropService,
    required this.onPlanningCreated,
    this.isDarkMode = true,
    this.lang = 'EN',
  });

  @override
  State<CreatePlanningDialog> createState() => _CreatePlanningDialogState();
}

class _CreatePlanningDialogState extends State<CreatePlanningDialog> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<Crop>> futureCrops;
  int? _selectedCropId;
  String? _selectedCropName;
  DateTime? _startDate;
  DateTime? _expectedHarvestDate;
  String _notes = '';
  bool _irrigationReminder = false;
  bool _fertilizerReminder = false;
  DateTime? _irrigationReminderDate;
  DateTime? _fertilizerReminderDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    futureCrops = widget.cropService.getCropLibrary();
  }

  Widget _dateTile(IconData icon, Color color, String text, VoidCallback onTap, Color surface, Color border, Color textPrimary) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
        child: Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: textPrimary, fontSize: 13)),
        ]),
      ),
    );
  }

  String _formatPlanDate(DateTime date) {
    if (widget.lang == 'AR') {
      const months = ['جانفي','فيفري','مارس','أفريل','ماي','جوان','جويلية','أوت','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
    if (widget.lang == 'FR') {
      const months = ['jan.','fév.','mar.','avr.','mai','juin','juil.','août','sep.','oct.','nov.','déc.'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

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
    final gold = isDark ? AppColors.gold : AppColorsLight.gold;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return AlertDialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
      title: Text(l.createCropPlan, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
      content: FutureBuilder<List<Crop>>(
        future: futureCrops,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: primary)));
          if (snapshot.hasError) return SizedBox(height: 200, child: Center(child: Text('${snapshot.error}', style: TextStyle(color: textSecondary))));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return SizedBox(height: 200, child: Center(child: Text(l.noCropsAvailable, style: TextStyle(color: textSecondary))));

          return SizedBox(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: ListView(shrinkWrap: true, children: [
                DropdownButtonFormField<int>(
                  value: _selectedCropId,
                  dropdownColor: surfaceAlt,
                  style: TextStyle(color: textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: l.selectCrop, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                    filled: true, fillColor: surfaceAlt,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
                  ),
                  items: snapshot.data!.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.displayName(widget.lang)))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedCropId = v;
                      _selectedCropName = snapshot.data!.firstWhere((c) => c.id == v).displayName('EN');
                    });
                  },
                  validator: (v) => v == null ? l.required : null,
                ),
                const SizedBox(height: 12),
                _dateTile(Icons.play_circle_outline, cyan,
                  _startDate == null ? l.selectStartDate : '${widget.lang == 'FR' ? 'Début' : widget.lang == 'AR' ? 'بداية' : 'Start'}: ${_formatPlanDate(_startDate!)}',
                  () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                    if (d != null) {
                    if (d.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(widget.lang == 'AR' ? 'تاريخ البداية لا يمكن أن يكون في الماضي' : widget.lang == 'FR' ? 'La date de début ne peut pas être dans le passé' : 'Start date cannot be in the past'),
                        backgroundColor: Colors.red,
                      ));
                    } else {
                      setState(() => _startDate = d);
                    }
                  }
                  }, surfaceAlt, border, textPrimary,
                ),
                const SizedBox(height: 8),
                _dateTile(Icons.agriculture, gold,
                  _expectedHarvestDate == null ? l.selectHarvestDate : '${widget.lang == 'FR' ? 'Récolte' : widget.lang == 'AR' ? 'حصاد' : 'Harvest'}: ${_formatPlanDate(_expectedHarvestDate!)}',
                  () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime(2100));
                    if (d != null) setState(() => _expectedHarvestDate = d);
                  }, surfaceAlt, border, textPrimary,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  style: TextStyle(color: textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: l.notes, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                    filled: true, fillColor: surfaceAlt,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                  ),
                  maxLines: 2,
                  onChanged: (v) => _notes = v,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text('💧 ${l.irrigationReminder}', style: TextStyle(color: textPrimary, fontSize: 13)),
                  value: _irrigationReminder,
                  activeColor: cyan,
                  onChanged: (v) => setState(() {
                    _irrigationReminder = v;
                    if (!v) _irrigationReminderDate = null;
                  }),
                ),
                if (_irrigationReminder)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(Icons.alarm, color: cyan, size: 20),
                    title: Text(
                      _irrigationReminderDate == null
                          ? (widget.lang == 'AR' ? 'اختر تاريخ ووقت الري' : widget.lang == 'FR' ? "Choisir date et heure d'irrigation" : 'Pick irrigation date & time')
                          : _formatReminderDate(_irrigationReminderDate!),
                      style: TextStyle(color: _irrigationReminderDate == null ? textSecondary : cyan, fontSize: 13),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (date == null || !mounted) return;
                      final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
                      if (time == null || !mounted) return;
                      final chosen = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      if (chosen.isBefore(DateTime.now())) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(widget.lang == 'AR' ? 'لا يمكن اختيار تاريخ في الماضي' : widget.lang == 'FR' ? 'Impossible de choisir une date passée' : 'Cannot choose a past date'),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }
                      setState(() => _irrigationReminderDate = chosen);
                    },
                  ),
                SwitchListTile(
                  title: Text('🌿 ${l.fertilizerReminder}', style: TextStyle(color: textPrimary, fontSize: 13)),
                  value: _fertilizerReminder,
                  activeColor: primary,
                  onChanged: (v) => setState(() {
                    _fertilizerReminder = v;
                    if (!v) _fertilizerReminderDate = null;
                  }),
                ),
                if (_fertilizerReminder)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(Icons.alarm, color: primary, size: 20),
                    title: Text(
                      _fertilizerReminderDate == null
                          ? (widget.lang == 'AR' ? 'اختر تاريخ ووقت التسميد' : widget.lang == 'FR' ? "Choisir date et heure d'engrais" : 'Pick fertilizer date & time')
                          : _formatReminderDate(_fertilizerReminderDate!),
                      style: TextStyle(color: _fertilizerReminderDate == null ? textSecondary : primary, fontSize: 13),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (date == null || !mounted) return;
                      final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
                      if (time == null || !mounted) return;
                      final chosen = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      if (chosen.isBefore(DateTime.now())) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(widget.lang == 'AR' ? 'لا يمكن اختيار تاريخ في الماضي' : widget.lang == 'FR' ? 'Impossible de choisir une date passée' : 'Cannot choose a past date'),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }
                      setState(() => _fertilizerReminderDate = chosen);
                    },
                  ),
              ]),
            ),
          );
        },
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
                : Text(l.createPlan, style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  String _formatReminderDate(DateTime date) {
    if (widget.lang == 'AR') {
      const months = ['جانفي','فيفري','مارس','أفريل','ماي','جوان','جويلية','أوت','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
      return '${date.day} ${months[date.month-1]} ${date.year}  ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
    }
    if (widget.lang == 'FR') {
      const months = ['jan.','fév.','mar.','avr.','mai','juin','juil.','août','sep.','oct.','nov.','déc.'];
      return '${date.day} ${months[date.month-1]} ${date.year}  ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month-1]} ${date.day}, ${date.year}  ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
  }

  void _submitForm() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.selectStartDate))); return; }
    if (_startDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      final msg = widget.lang == 'AR' ? 'تاريخ البداية لا يمكن أن يكون في الماضي' : widget.lang == 'FR' ? 'La date de début ne peut pas être dans le passé' : 'Start date cannot be in the past';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      return;
    }
    if (_expectedHarvestDate == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.selectHarvestDate))); return; }
    if (_expectedHarvestDate!.isBefore(_startDate!)) {
      final msg = widget.lang == 'AR' ? 'تاريخ الحصاد يجب أن يكون بعد تاريخ البداية' : widget.lang == 'FR' ? 'La date de récolte doit être après la date de début' : 'Harvest date must be after start date';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isSubmitting = true);
    final planning = CropPlanning(id: 0, userId: 0, cropId: _selectedCropId!, planName: _selectedCropName, startDate: _startDate!.toIso8601String(), expectedHarvestDate: _expectedHarvestDate!.toIso8601String(), notes: _notes.isNotEmpty ? _notes : null, irrigationReminder: _irrigationReminder, fertilizerReminder: _fertilizerReminder, cropName: '');
    try {
      final created = await widget.cropService.createCropPlanning(planning);
      // Schedule notifications if reminder dates chosen
      await NotificationService().requestPermissions();
      if (_irrigationReminder && _irrigationReminderDate != null) {
        await NotificationService().scheduleIrrigationReminder(
          planningId: created.id,
          scheduledDate: _irrigationReminderDate!,
          cropName: _selectedCropName ?? '',
          lang: widget.lang,
        );
      }
      if (_fertilizerReminder && _fertilizerReminderDate != null) {
        await NotificationService().scheduleFertilizerReminder(
          planningId: created.id,
          scheduledDate: _fertilizerReminderDate!,
          cropName: _selectedCropName ?? '',
          lang: widget.lang,
        );
      }
      if (mounted) { Navigator.pop(context); widget.onPlanningCreated(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.planCreated))); }
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      String errMsg;
      if (errStr.contains('farmer_access_only') || errStr.contains('farmer access')) {
        errMsg = widget.lang == 'AR' ? 'الوصول مخصص للمزارعين فقط' : widget.lang == 'FR' ? 'Accès réservé aux agriculteurs' : 'Access reserved for farmers';
      } else {
        errMsg = l.anErrorOccurred;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMsg)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}