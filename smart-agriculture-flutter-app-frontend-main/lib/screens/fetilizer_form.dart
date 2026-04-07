import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../bloc/fertilizer/fertilizer_bloc.dart';
import '../bloc/fertilizer/fertilizer_event.dart';
import '../bloc/fertilizer/fertilizer_state.dart';

class FertilizerForm extends StatefulWidget {
  @override
  _FertilizerFormState createState() => _FertilizerFormState();
}

class _FertilizerFormState extends State<FertilizerForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _organicCarbonController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();

  String _selectedCrop = '';
  String _selectedStage = '';
  String _selectedSoilType = '';

  @override
  void initState() {
    super.initState();
    context.read<FertilizerBloc>().add(FetchDropdowns());
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    final formData = {
      'crop': _selectedCrop,
      'stage': _selectedStage,
      'soil_type': _selectedSoilType,
      'N': double.parse(_nController.text),
      'P': double.parse(_pController.text),
      'K': double.parse(_kController.text),
      'pH': double.parse(_phController.text),
      'organic_carbon': double.parse(_organicCarbonController.text),
      'temp': double.parse(_tempController.text),
      'rainfall': double.parse(_rainfallController.text),
    };
    context.read<FertilizerBloc>().add(GetRecommendation(formData));
  }

  void _showRecommendationDialog(BuildContext context, String recommendation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('⚗️', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            const Text('Recommendation', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: Text(recommendation, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFFB300)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('OK', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FertilizerBloc, FertilizerState>(
      listener: (context, state) {
        if (state is FertilizerRecommendationSuccess) {
          _showRecommendationDialog(context, state.recommendation);
        } else if (state is FertilizerError) {
          _showRecommendationDialog(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        List<String> crops = [];
        List<String> stages = [];
        List<String> soilTypes = [];

        if (state is FertilizerDropdownsLoaded) {
          crops = state.crops;
          stages = state.stages;
          soilTypes = state.soilTypes;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: const Text('Fertilizer Recommendation'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(child: Text('⚗️', style: TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Enter your soil and crop details to get personalized fertilizer recommendations.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                _sectionLabel('CROP INFORMATION'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _buildDropdown('Crop', crops, _selectedCrop, (val) => setState(() => _selectedCrop = val!))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDropdown('Stage', stages, _selectedStage, (val) => setState(() => _selectedStage = val!))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDropdown('Soil', soilTypes, _selectedSoilType, (val) => setState(() => _selectedSoilType = val!))),
                  ],
                ),

                const SizedBox(height: 28),
                _sectionLabel('SOIL PROPERTIES'),
                const SizedBox(height: 12),

                _buildField(_nController, 'Nitrogen (N) kg/ha', Icons.water_drop_outlined),
                const SizedBox(height: 12),
                _buildField(_pController, 'Phosphorus (P) kg/ha', Icons.water_drop_outlined),
                const SizedBox(height: 12),
                _buildField(_kController, 'Potassium (K) kg/ha', Icons.water_drop_outlined),
                const SizedBox(height: 12),
                _buildField(_phController, 'Soil pH', Icons.science_outlined),
                const SizedBox(height: 12),
                _buildField(_organicCarbonController, 'Organic Carbon (%)', Icons.grass_outlined),

                const SizedBox(height: 28),
                _sectionLabel('WEATHER CONDITIONS'),
                const SizedBox(height: 12),

                _buildField(_tempController, 'Temperature (°C)', Icons.device_thermostat_outlined),
                const SizedBox(height: 12),
                _buildField(_rainfallController, 'Rainfall (mm)', Icons.cloudy_snowing),

                const SizedBox(height: 32),

                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFFB300)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: state is FertilizerLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: state is FertilizerLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.background))
                        : const Text('Get Recommendation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.background)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      dropdownColor: AppColors.surfaceAlt,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      icon: const Icon(Icons.expand_more, color: AppColors.textSecondary, size: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
      onChanged: onChanged,
      isExpanded: true,
      validator: (val) => val == null ? 'Required' : null,
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Required';
        if (double.tryParse(val) == null) return 'Invalid number';
        return null;
      },
    );
  }
}