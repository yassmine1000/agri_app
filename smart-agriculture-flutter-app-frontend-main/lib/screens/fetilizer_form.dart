import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.eco, color: Colors.green[700], size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Fertilizer Recommendation',
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(recommendation, style: TextStyle(fontSize: 16, height: 1.5)),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('OK'),
                ),
              ),
            ],
          ),
        ),
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
          appBar: AppBar(
            title: Text('Fertilizer Recommendation', style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green[50]!, Colors.white],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // 🌱 Header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.eco, color: Colors.green[800], size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Enter your soil and crop details to get personalized fertilizer recommendations',
                              style: TextStyle(color: Colors.green[900], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Crop Info
                    Text('Crop Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green[800])),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown('Crop', crops, _selectedCrop,
                                  (val) => setState(() => _selectedCrop = val!)),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: _buildDropdown('Growth Stage', stages, _selectedStage,
                                  (val) => setState(() => _selectedStage = val!)),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: _buildDropdown('Soil Type', soilTypes, _selectedSoilType,
                                  (val) => setState(() => _selectedSoilType = val!)),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Soil properties
                    Text('Soil Properties',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green[800])),
                    SizedBox(height: 16),
                    _buildTextField(_nController, 'Nitrogen (N) kg/ha', Icons.water_drop),
                    SizedBox(height: 16),
                    _buildTextField(_pController, 'Phosphorus (P) kg/ha', Icons.water_drop),
                    SizedBox(height: 16),
                    _buildTextField(_kController, 'Potassium (K) kg/ha', Icons.water_drop),
                    SizedBox(height: 16),
                    _buildTextField(_phController, 'Soil pH', Icons.thermostat),
                    SizedBox(height: 16),
                    _buildTextField(_organicCarbonController, 'Organic Carbon (%)', Icons.grass),

                    SizedBox(height: 24),

                    // Weather
                    Text('Weather Conditions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green[800])),
                    SizedBox(height: 16),
                    _buildTextField(_tempController, 'Temperature (°C)', Icons.device_thermostat),
                    SizedBox(height: 16),
                    _buildTextField(_rainfallController, 'Rainfall (mm)', Icons.cloudy_snowing),

                    SizedBox(height: 32),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state is FertilizerLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: state is FertilizerLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                            : Text('Get Recommendation',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      isExpanded: true,
      validator: (val) => val == null ? 'Please select $label' : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Please enter a value';
        if (double.tryParse(val) == null) return 'Please enter a valid number';
        return null;
      },
    );
  }
}
