import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'package:smart_agri_app/screens/qr_display_screen.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'package:smart_agri_app/utils/custom_widgets.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class RegistrationScreen extends StatefulWidget {
  final ValueNotifier<bool>? isDarkNotifier;
  final Function(Locale)? onLocaleChange;
  final Function(bool)? onThemeChange;

  const RegistrationScreen({
    super.key,
    this.isDarkNotifier,
    this.onLocaleChange,
    this.onThemeChange,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _role   = 'farmer';
  String _gender = 'male';
  String? _dob;
  bool _isDark   = true;

  final _usernameCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _nameCtrl      = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _altPhoneCtrl  = TextEditingController();
  final _farmNameCtrl  = TextEditingController();
  final _regNoCtrl     = TextEditingController();
  final _dobCtrl       = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isDarkNotifier != null) {
      _isDark = widget.isDarkNotifier!.value;
      widget.isDarkNotifier!.addListener(_onThemeChanged);
    } else {
      _loadPrefs();
    }
  }

  void _onThemeChanged() {
    if (mounted) setState(() => _isDark = widget.isDarkNotifier!.value);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _isDark = prefs.getBool('is_dark_mode') ?? true);
  }

  @override
  void dispose() {
    widget.isDarkNotifier?.removeListener(_onThemeChanged);
    _usernameCtrl.dispose(); _passwordCtrl.dispose(); _emailCtrl.dispose();
    _nameCtrl.dispose(); _addressCtrl.dispose(); _phoneCtrl.dispose();
    _altPhoneCtrl.dispose(); _farmNameCtrl.dispose(); _regNoCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDOB() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: _isDark
            ? ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface))
            : ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: AppColorsLight.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dob = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        _dobCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  /// Traduit les messages d'erreur backend
  String _translateError(String backendMsg, AppLocalizations l) {
    final msg = backendMsg.toLowerCase();
    if (msg.contains('username already exists') || msg.contains('already exists')) {
      return l.usernameRequired; // "Username already exists" → clé dédiée
    }
    if (msg.contains('invalid') && msg.contains('email')) return l.invalidEmail;
    if (msg.contains('phone')) return l.phoneInvalid;
    if (msg.contains('missing') || msg.contains('required')) return l.required;
    return l.anErrorOccurred;
  }

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context)!;
    final isDark = _isDark;
    final isDarkNotifier = widget.isDarkNotifier ?? ValueNotifier(isDark);

    final bg            = isDark ? AppColors.background    : AppColorsLight.background;
    final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
    final surfaceAlt    = isDark ? AppColors.surfaceAlt    : AppColorsLight.surfaceAlt;
    final border        = isDark ? AppColors.border        : AppColorsLight.border;
    final primary       = isDark ? AppColors.primary       : AppColorsLight.primary;
    final cyan          = isDark ? AppColors.cyan          : AppColorsLight.cyan;
    final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          final qrToken = await PrefHelper.getQrToken();
          if (!mounted) return;
          if (qrToken != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => QrDisplayScreen(
                qrToken: qrToken,
                isDarkNotifier: isDarkNotifier,
                onLocaleChange: widget.onLocaleChange ?? (_) {},
                onThemeChange:  widget.onThemeChange  ?? (_) {},
              )),
            );
          } else {
            Navigator.pop(context);
          }
        } else if (state is AuthFailure) {
          final translated = _translateError(state.error, l);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translated), backgroundColor: Colors.red.shade700),
          );
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          title: Text(l.createAccount, style: TextStyle(color: textPrimary)),
          iconTheme: IconThemeData(color: textPrimary),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: border)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Header ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: primary.withOpacity(0.2))),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(12)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/icons/agriscan_logo.png', fit: BoxFit.cover))),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AgriScan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
                    Text(l.tagline, style: TextStyle(fontSize: 12, color: textSecondary)),
                  ]),
                ]),
              ),

              const SizedBox(height: 28),

              // ── Role ─────────────────────────────────────────────
              _sectionLabel(l.accountType, textSecondary),
              _themedDropdown<String>(
                label: l.role, value: _role,
                items: [
                  DropdownMenuItem(value: 'farmer',   child: Text(l.farmer)),
                  DropdownMenuItem(value: 'customer', child: Text(l.customer)),
                ],
                surface: surface, border: border, surfaceAlt: surfaceAlt,
                textPrimary: textPrimary, textSecondary: textSecondary, primary: primary,
                onChanged: (val) => setState(() => _role = val!),
              ),

              const SizedBox(height: 24),

              // ── Credentials ───────────────────────────────────────
              _sectionLabel(l.credentials, textSecondary),
              Row(children: [
                Expanded(child: CustomTextField(
                  controller: _usernameCtrl,
                  label: l.username,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l.required;
                    if (v.trim().length < 3) return l.usernameMin;
                    return null;
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(
                  controller: _passwordCtrl,
                  label: l.password,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l.required;
                    if (v.length < 6) return l.passwordMin;
                    return null;
                  },
                )),
              ]),
              const SizedBox(height: 12),

              // ── Email ─────────────────────────────────────────────
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: textPrimary, fontSize: 14),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.emailRequired;
                  if (!v.contains('@') || !v.contains('.')) return l.invalidEmail;
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'exemple@gmail.com',
                  hintStyle: TextStyle(color: textSecondary, fontSize: 12),
                  labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                  prefixIcon: Icon(Icons.email_outlined, color: textSecondary, size: 18),
                  filled: true, fillColor: surface,
                  border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
                  errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
                ),
              ),

              const SizedBox(height: 24),

              // ── Personal info ─────────────────────────────────────
              _sectionLabel(l.personalInfo, textSecondary),
              CustomTextField(
                controller: _nameCtrl,
                label: l.fullName,
                validator: (v) => (v == null || v.trim().isEmpty) ? l.nameRequired : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addressCtrl,
                label: l.address,
                validator: (v) => (v == null || v.trim().isEmpty) ? l.addressRequired : null,
              ),
              const SizedBox(height: 12),

              // ── Phone ─────────────────────────────────────────────
              Row(children: [
                Expanded(child: CustomTextField(
                  controller: _phoneCtrl,
                  label: l.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l.phoneRequired;
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 8) return l.phoneInvalid;
                    return null;
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(
                  controller: _altPhoneCtrl,
                  label: l.altPhone,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    // Alt phone est optionnel — valide seulement si rempli
                    if (v != null && v.trim().isNotEmpty) {
                      final digits = v.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 8) return l.phoneInvalid;
                    }
                    return null;
                  },
                )),
              ]),
              const SizedBox(height: 12),

              // ── Date of birth ─────────────────────────────────────
              TextFormField(
                controller: _dobCtrl,
                readOnly: true,
                onTap: _pickDOB,
                style: TextStyle(color: textPrimary, fontSize: 14),
                validator: (v) => (v == null || v.isEmpty) ? l.required : null,
                decoration: InputDecoration(
                  labelText: l.dateOfBirth,
                  labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                  suffixIcon: Icon(Icons.calendar_today, color: primary, size: 18),
                  filled: true, fillColor: surface,
                  border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
                  errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
                ),
              ),
              const SizedBox(height: 16),

              // ── Gender ────────────────────────────────────────────
              Text(l.gender, style: TextStyle(fontSize: 13, color: textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['male', 'female'].map((g) {
                  final selected = _gender == g;
                  final label = g == 'male' ? l.male : l.female;
                  return GestureDetector(
                    onTap: () => setState(() => _gender = g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? primary.withOpacity(0.15) : surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? primary : border),
                      ),
                      child: Text(label, style: TextStyle(color: selected ? primary : textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),

              // ── Farm details (farmer only) ────────────────────────
              if (_role == 'farmer') ...[
                const SizedBox(height: 24),
                _sectionLabel(l.farmDetails, textSecondary),
                CustomTextField(
                  controller: _farmNameCtrl,
                  label: l.farmName,
                  validator: (v) => (v == null || v.trim().isEmpty) ? l.farmNameRequired : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _regNoCtrl,
                  label: l.registrationNumber,
                  validator: (v) => (v == null || v.trim().isEmpty) ? l.regNoRequired : null,
                ),
              ],

              const SizedBox(height: 32),

              // ── Submit ────────────────────────────────────────────
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => CustomButton(
                  text: l.createAccount,
                  isLoading: state is AuthLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final userData = {
                        'username':       _usernameCtrl.text.trim(),
                        'password':       _passwordCtrl.text,
                        'email':          _emailCtrl.text.trim(),
                        'role':           _role,
                        'name':           _nameCtrl.text.trim(),
                        'address':        _addressCtrl.text.trim(),
                        'phone_no':       _phoneCtrl.text.trim(),
                        'alt_contact_no': _altPhoneCtrl.text.trim().isEmpty ? null : _altPhoneCtrl.text.trim(),
                        'gender':         _gender,
                        'dob':            _dob,
                        if (_role == 'farmer') ...{
                          'farm_name':              _farmNameCtrl.text.trim(),
                          'farmer_registration_no': _regNoCtrl.text.trim(),
                        },
                      };
                      context.read<AuthBloc>().add(RegisterEvent(userDate: userData));
                    }
                  },
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.5)),
  );

  Widget _themedDropdown<T>({
    required String label, required T value,
    required List<DropdownMenuItem<T>> items,
    required Color surface, required Color border, required Color surfaceAlt,
    required Color textPrimary, required Color textSecondary, required Color primary,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value, dropdownColor: surfaceAlt,
      style: TextStyle(color: textPrimary, fontSize: 14),
      icon: Icon(Icons.expand_more, color: textSecondary, size: 18),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
        filled: true, fillColor: surface,
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
      ),
      items: items, onChanged: onChanged,
    );
  }
}