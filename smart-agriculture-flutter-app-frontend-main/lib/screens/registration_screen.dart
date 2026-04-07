import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'package:smart_agri_app/utils/custom_widgets.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _role = 'farmer';
  String _gender = 'male';
  String? _dob;

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _altPhoneCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _regNoCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose(); _passwordCtrl.dispose(); _nameCtrl.dispose();
    _addressCtrl.dispose(); _phoneCtrl.dispose(); _altPhoneCtrl.dispose();
    _farmNameCtrl.dispose(); _regNoCtrl.dispose(); _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dob = '${picked.year}-${picked.month}-${picked.day}';
        _dobCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
  );

  Widget _themedDropdown<T>({required String label, required T value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: AppColors.surfaceAlt,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      icon: const Icon(Icons.expand_more, color: AppColors.textSecondary, size: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        filled: true, fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
          Navigator.pop(context);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Create Account'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.cyan]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Text('🌿', style: TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Join AgriScan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text('Create your farmer account', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                _sectionLabel('ACCOUNT TYPE'),

                _themedDropdown<String>(
                  label: 'Role',
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                    DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  ],
                  onChanged: (val) => setState(() => _role = val!),
                ),

                const SizedBox(height: 24),
                _sectionLabel('CREDENTIALS'),

                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: _usernameCtrl, label: 'Username', validator: (v) => v!.isEmpty ? 'Required' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(controller: _passwordCtrl, label: 'Password', obscureText: true, validator: (v) => v!.isEmpty ? 'Required' : null)),
                  ],
                ),

                const SizedBox(height: 24),
                _sectionLabel('PERSONAL INFO'),

                CustomTextField(controller: _nameCtrl, label: 'Full Name'),
                const SizedBox(height: 12),
                CustomTextField(controller: _addressCtrl, label: 'Address'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: CustomTextField(controller: _phoneCtrl, label: 'Phone')),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(controller: _altPhoneCtrl, label: 'Alt Phone')),
                  ],
                ),
                const SizedBox(height: 12),

                // DOB
                TextFormField(
                  controller: _dobCtrl,
                  readOnly: true,
                  onTap: _pickDOB,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                    filled: true, fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender
                const Text('Gender', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['male', 'female', 'other'].map((g) {
                    final selected = _gender == g;
                    return GestureDetector(
                      onTap: () => setState(() => _gender = g),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                        ),
                        child: Text(g, style: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
                      ),
                    );
                  }).toList(),
                ),

                if (_role == 'farmer') ...[
                  const SizedBox(height: 24),
                  _sectionLabel('FARM DETAILS'),
                  CustomTextField(controller: _farmNameCtrl, label: 'Farm Name'),
                  const SizedBox(height: 12),
                  CustomTextField(controller: _regNoCtrl, label: 'Registration Number'),
                ],

                const SizedBox(height: 32),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: 'Create Account',
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final userData = {
                            'username': _usernameCtrl.text,
                            'password': _passwordCtrl.text,
                            'role': _role,
                            'name': _nameCtrl.text,
                            'address': _addressCtrl.text,
                            'phone_no': _phoneCtrl.text,
                            'alt_contact_no': _altPhoneCtrl.text,
                            'gender': _gender,
                            'dob': _dob,
                            if (_role == 'farmer') ...{
                              'farm_name': _farmNameCtrl.text,
                              'farmer_registration_no': _regNoCtrl.text,
                            }
                          };
                          context.read<AuthBloc>().add(RegisterEvent(userDate: userData));
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}