import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ValueNotifier<bool> isDarkNotifier;
  final Function(Locale) onLocaleChange;
  final Function(bool) onThemeChange;

  const ProfileScreen({
    super.key,
    required this.isDarkNotifier,
    required this.onLocaleChange,
    required this.onThemeChange,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Dio _dio = Dio();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _altPhoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _regNoCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _addressCtrl.dispose(); _phoneCtrl.dispose();
    _altPhoneCtrl.dispose(); _emailCtrl.dispose(); _farmNameCtrl.dispose();
    _regNoCtrl.dispose(); _newPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await PrefHelper.getToken();
      final response = await _dio.get(
        '${Config.baseUrl}/profile',
        options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
      );
      final data = response.data['data'];
      if (!mounted) return;
      setState(() {
        _profile = data;
        _loading = false;
        _nameCtrl.text = data['name'] ?? '';
        _addressCtrl.text = data['address'] ?? '';
        _phoneCtrl.text = data['phone_no'] ?? '';
        _altPhoneCtrl.text = data['alt_contact_no'] ?? '';
        _emailCtrl.text = data['email'] ?? '';
        _farmNameCtrl.text = data['farm_name'] ?? '';
        _regNoCtrl.text = data['farmer_registration_no'] ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Failed to load profile'; _loading = false; });
    }
  }

  Future<void> _saveProfile(bool isDark) async {
    setState(() => _saving = true);
    try {
      final token = await PrefHelper.getToken();
      final body = {
        'name': _nameCtrl.text,
        'address': _addressCtrl.text,
        'phone_no': _phoneCtrl.text,
        'alt_contact_no': _altPhoneCtrl.text,
        'email': _emailCtrl.text,
        'farm_name': _farmNameCtrl.text,
        'farmer_registration_no': _regNoCtrl.text,
        'dob': _profile?['dob'],
        'gender': _profile?['gender'],
      };
      if (_newPasswordCtrl.text.isNotEmpty) {
        body['newPassword'] = _newPasswordCtrl.text;
      }
      await _dio.put(
        '${Config.baseUrl}/profile',
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
      );
      if (!mounted) return;
      setState(() { _editing = false; _saving = false; });
      _newPasswordCtrl.clear();
      _loadProfile();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.profileUpdated),
        backgroundColor: isDark ? AppColors.primary : AppColorsLight.primary,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteAccount(bool isDark, AppLocalizations l) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface : AppColorsLight.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isDark ? AppColors.border : AppColorsLight.border)),
        title: Text(l.deleteAccount, style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(l.deleteAccountConfirm, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: isDark ? AppColors.error : AppColorsLight.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(l.delete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final token = await PrefHelper.getToken();
        await _dio.delete(
          '${Config.baseUrl}/profile',
          options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
        );
        await PrefHelper.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen(
            onLocaleChange: widget.onLocaleChange,
            onThemeChange: widget.onThemeChange,
            isDarkNotifier: widget.isDarkNotifier,
          )),
          (route) => false,
        );
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDarkNotifier,
      builder: (context, isDark, _) {
        final l = AppLocalizations.of(context)!;
        final bg = isDark ? AppColors.background : AppColorsLight.background;
        final surface = isDark ? AppColors.surface : AppColorsLight.surface;
        final border = isDark ? AppColors.border : AppColorsLight.border;
        final primary = isDark ? AppColors.primary : AppColorsLight.primary;
        final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
        final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
        final errorColor = isDark ? AppColors.error : AppColorsLight.error;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            title: Text(l.profile, style: TextStyle(color: textPrimary)),
            iconTheme: IconThemeData(color: textPrimary),
            actions: [
              if (!_editing && !_loading && _profile != null)
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: primary, size: 20),
                  onPressed: () => setState(() => _editing = true),
                ),
              if (_editing)
                IconButton(
                  icon: Icon(Icons.close, color: textSecondary, size: 20),
                  onPressed: () { setState(() => _editing = false); _loadProfile(); },
                ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: border)),
          ),
          body: _loading
              ? Center(child: CircularProgressIndicator(color: primary))
              : _error != null
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.error_outline, color: textSecondary, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadProfile, style: ElevatedButton.styleFrom(backgroundColor: primary), child: Text(l.retry, style: TextStyle(color: bg))),
                    ]))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Avatar + info
                        Center(child: Column(children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(24)),
                            child: Center(child: Text(
                              (_profile?['name'] ?? _profile?['username'] ?? 'U')[0].toUpperCase(),
                              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: bg),
                            )),
                          ),
                          const SizedBox(height: 12),
                          Text(_profile?['username'] ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: primary.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                            child: Text(_profile?['role']?.toUpperCase() ?? '', style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w700)),
                          ),
                        ])),

                        const SizedBox(height: 28),

                        // Personal info section
                        _sectionLabel(l.personalInfo, textSecondary),
                        _card(surface, border, child: Column(children: [
                          _field(l.fullName, _nameCtrl, Icons.person_outline, _editing, textPrimary, textSecondary, primary, surface, border),
                          _divider(border),
                          _field('Email', _emailCtrl, Icons.email_outlined, _editing, textPrimary, textSecondary, primary, surface, border, keyboard: TextInputType.emailAddress),
                          _divider(border),
                          _field(l.phone, _phoneCtrl, Icons.phone_outlined, _editing, textPrimary, textSecondary, primary, surface, border, keyboard: TextInputType.phone),
                          _divider(border),
                          _field(l.altPhone, _altPhoneCtrl, Icons.phone_callback_outlined, _editing, textPrimary, textSecondary, primary, surface, border, keyboard: TextInputType.phone),
                          _divider(border),
                          _field(l.address, _addressCtrl, Icons.location_on_outlined, _editing, textPrimary, textSecondary, primary, surface, border),
                        ])),

                        if (_profile?['role'] == 'farmer') ...[
                          const SizedBox(height: 20),
                          _sectionLabel(l.farmDetails, textSecondary),
                          _card(surface, border, child: Column(children: [
                            _field(l.farmName, _farmNameCtrl, Icons.agriculture_outlined, _editing, textPrimary, textSecondary, primary, surface, border),
                            _divider(border),
                            _field(l.registrationNumber, _regNoCtrl, Icons.badge_outlined, _editing, textPrimary, textSecondary, primary, surface, border),
                          ])),
                        ],

                        if (_editing) ...[
                          const SizedBox(height: 20),
                          _sectionLabel(l.changePassword, textSecondary),
                          _card(surface, border, child: _field(
                            l.newPassword, _newPasswordCtrl, Icons.lock_outline, true,
                            textPrimary, textSecondary, primary, surface, border, obscure: true,
                            hint: l.leaveBlank,
                          )),

                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(14)),
                            child: ElevatedButton(
                              onPressed: _saving ? null : () => _saveProfile(isDark),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              child: _saving
                                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: bg))
                                  : Text(l.saveChanges, style: TextStyle(color: bg, fontWeight: FontWeight.w700, fontSize: 15)),
                            ),
                          ),
                        ],

                        if (!_editing) ...[
                          const SizedBox(height: 20),
                          _sectionLabel(l.accountInfo, textSecondary),
                          _card(surface, border, child: Column(children: [
                            _infoRow(l.gender, _profile?['gender'] ?? '-', textPrimary, textSecondary),
                            _divider(border),
                            _infoRow(l.dateOfBirth, _formatDate(_profile?['dob']), textPrimary, textSecondary),
                            _divider(border),
                            _infoRow(l.memberSince, _formatDate(_profile?['created_at']), textPrimary, textSecondary),
                          ])),
                        ],

                        const SizedBox(height: 28),

                        // Delete account
                        GestureDetector(
                          onTap: () => _deleteAccount(isDark, l),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: errorColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: errorColor.withOpacity(0.3)),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.delete_forever_outlined, color: errorColor, size: 20),
                              const SizedBox(width: 8),
                              Text(l.deleteAccount, style: TextStyle(color: errorColor, fontWeight: FontWeight.w700, fontSize: 14)),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ]),
                    ),
        );
      },
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) { return dateStr.toString(); }
  }

  Widget _sectionLabel(String label, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 1.5)),
  );

  Widget _card(Color surface, Color border, {required Widget child}) => Container(
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
    child: child,
  );

  Widget _divider(Color border) => Divider(height: 1, thickness: 0.5, color: border);

  Widget _field(String label, TextEditingController ctrl, IconData icon, bool enabled,
      Color textPrimary, Color textSecondary, Color primary, Color surface, Color border,
      {bool obscure = false, TextInputType? keyboard, String? hint}) {
    if (!enabled) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(icon, color: textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
            const SizedBox(height: 2),
            Text(ctrl.text.isEmpty ? '-' : ctrl.text, style: TextStyle(fontSize: 14, color: textPrimary, fontWeight: FontWeight.w500)),
          ])),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        style: TextStyle(color: textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: textSecondary, fontSize: 12),
          labelStyle: TextStyle(color: textSecondary, fontSize: 12),
          prefixIcon: Icon(icon, color: textSecondary, size: 18),
          filled: true, fillColor: surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color textPrimary, Color textSecondary) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      Text(label, style: TextStyle(color: textSecondary, fontSize: 13)),
      const Spacer(),
      Text(value, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );
}