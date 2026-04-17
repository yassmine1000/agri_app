import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _loading = false;
  bool _codeSent = false;
  bool _codeVerified = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isDark = true;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _isDark = prefs.getBool('is_dark_mode') ?? true);
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _codeCtrl.dispose();
    _newPasswordCtrl.dispose(); _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Veuillez entrer un email valide');
      return;
    }
    setState(() { _loading = true; _error = null; _success = null; });
    try {
      await Dio().post(
        '${Config.baseUrl}/auth/forgot-password',
        data: {'email': email},
        options: Options(headers: {'ngrok-skip-browser-warning': 'true'}),
      );
      setState(() {
        _codeSent = true;
        _success = 'Code envoyé ! Vérifiez votre email.';
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Erreur lors de l\'envoi. Réessayez.'; _loading = false; });
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final newPass = _newPasswordCtrl.text;
    final confirmPass = _confirmPasswordCtrl.text;

    setState(() { _error = null; });

    if (code.isEmpty) { setState(() => _error = 'Entrez le code reçu par email'); return; }
    if (newPass.isEmpty) { setState(() => _error = 'Entrez le nouveau mot de passe'); return; }
    if (newPass != confirmPass) { setState(() => _error = 'Les mots de passe ne correspondent pas'); return; }
    if (newPass.length < 6) { setState(() => _error = 'Mot de passe trop court (min 6 caractères)'); return; }

    setState(() { _loading = true; });
    try {
      await Dio().post(
        '${Config.baseUrl}/auth/reset-password',
        data: {'email': email, 'code': code, 'newPassword': newPass},
        options: Options(headers: {'ngrok-skip-browser-warning': 'true'}),
      );
      setState(() { _codeVerified = true; _success = 'Mot de passe réinitialisé !'; _loading = false; });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Code invalide ou expiré';
      setState(() { _error = msg; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
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
        title: Text('Mot de passe oublié', style: TextStyle(color: textPrimary)),
        iconTheme: IconThemeData(color: textPrimary),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: border)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),

          Center(child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(22)),
            child: const Center(child: Text('🔐', style: TextStyle(fontSize: 38))),
          )),
          const SizedBox(height: 20),
          Center(child: Text('Réinitialiser le mot de passe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary))),
          const SizedBox(height: 8),
          Center(child: Text(
            _codeSent ? 'Entrez le code reçu par email' : 'Entrez votre email pour recevoir un code de réinitialisation',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: textSecondary, height: 1.5),
          )),

          const SizedBox(height: 28),

          // Messages
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: errorColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: errorColor.withOpacity(0.3))),
              child: Row(children: [Icon(Icons.error_outline, color: errorColor, size: 16), const SizedBox(width: 8), Expanded(child: Text(_error!, style: TextStyle(color: errorColor, fontSize: 13)))]),
            ),
            const SizedBox(height: 16),
          ],
          if (_success != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: primary.withOpacity(0.3))),
              child: Row(children: [Icon(Icons.check_circle_outline, color: primary, size: 16), const SizedBox(width: 8), Expanded(child: Text(_success!, style: TextStyle(color: primary, fontSize: 13)))]),
            ),
            const SizedBox(height: 16),
          ],

          // Step 1: Email
          Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailCtrl,
            enabled: !_codeSent,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: _codeSent ? textSecondary : textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'exemple@gmail.com',
              hintStyle: TextStyle(color: textSecondary, fontSize: 13),
              prefixIcon: Icon(Icons.email_outlined, color: textSecondary, size: 18),
              filled: true,
              fillColor: _codeSent ? surface.withOpacity(0.5) : surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border.withOpacity(0.5))),
            ),
          ),
          const SizedBox(height: 16),

          if (!_codeSent) _gradientButton(text: 'Envoyer le code', loading: _loading, onPressed: _sendCode, primary: primary, cyan: cyan, bg: bg),

          // Step 2: Code + new password
          if (_codeSent && !_codeVerified) ...[
            const SizedBox(height: 20),
            Text('Code reçu par email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textPrimary, fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: '• • • • • •',
                hintStyle: TextStyle(color: textSecondary, fontSize: 20, letterSpacing: 8),
                counterText: '',
                filled: true, fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Nouveau mot de passe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordCtrl,
              obscureText: _obscureNew,
              style: TextStyle(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Min. 6 caractères',
                hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                prefixIcon: Icon(Icons.lock_outline, color: textSecondary, size: 18),
                suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: textSecondary, size: 18), onPressed: () => setState(() => _obscureNew = !_obscureNew)),
                filled: true, fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Confirmer le mot de passe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirm,
              style: TextStyle(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Répétez le mot de passe',
                hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                prefixIcon: Icon(Icons.lock_outline, color: textSecondary, size: 18),
                suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: textSecondary, size: 18), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                filled: true, fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            _gradientButton(text: 'Réinitialiser le mot de passe', loading: _loading, onPressed: _resetPassword, primary: primary, cyan: cyan, bg: bg),
            const SizedBox(height: 12),
            Center(child: TextButton(
              onPressed: () => setState(() { _codeSent = false; _error = null; _success = null; _codeCtrl.clear(); }),
              child: Text('Renvoyer le code', style: TextStyle(color: textSecondary, fontSize: 13)),
            )),
          ],

          if (_codeVerified) ...[
            const SizedBox(height: 40),
            Center(child: Column(children: [
              Icon(Icons.check_circle, color: primary, size: 70),
              const SizedBox(height: 16),
              Text('Succès !', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: primary)),
              const SizedBox(height: 8),
              Text('Redirection vers la connexion...', style: TextStyle(color: textSecondary, fontSize: 13)),
            ])),
          ],
        ]),
      ),
    );
  }

  Widget _gradientButton({required String text, required bool loading, required VoidCallback onPressed, required Color primary, required Color cyan, required Color bg}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(14)),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: loading
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: bg))
            : Text(text, style: TextStyle(color: bg, fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}