import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/screens/main_screen.dart';
import 'package:smart_agri_app/screens/registration_screen.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'package:smart_agri_app/utils/custom_widgets.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'package:smart_agri_app/screens/forgot_password_screen.dart';
import 'package:smart_agri_app/screens/qr_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(Locale)? onLocaleChange;
  final Function(bool)? onThemeChange;
  final ValueNotifier<bool>? isDarkNotifier;

  const LoginScreen({
    super.key,
    this.onLocaleChange,
    this.onThemeChange,
    this.isDarkNotifier,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _currentLang = 'EN';

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _currentLang = prefs.getString('language') ?? 'EN');
  }

  Future<void> _changeLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => _currentLang = lang);
    final localeMap = {'EN': const Locale('en'), 'FR': const Locale('fr'), 'AR': const Locale('ar')};
    widget.onLocaleChange?.call(localeMap[lang]!);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Traduit les messages d'erreur backend selon la langue active
  String _translateError(String backendMsg, AppLocalizations l) {
    final msg = backendMsg.toLowerCase();
    if (msg.contains('invalid credentials') ||
        msg.contains('invalid username') ||
        msg.contains('wrong password') ||
        msg.contains('incorrect')) {
      return l.invalidCredentials;
    }
    if (msg.contains('not found') || msg.contains('does not exist')) {
      return l.invalidCredentials;
    }
    if (msg.contains('username already exists') || msg.contains('already exists')) {
      return l.usernameRequired; // fallback — shouldn't happen on login
    }
    return l.anErrorOccurred;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkNotifier = widget.isDarkNotifier ?? ValueNotifier(true);

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkNotifier,
      builder: (context, isDark, _) {
        final l = AppLocalizations.of(context)!;
        final bg            = isDark ? AppColors.background    : AppColorsLight.background;
        final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
        final primary       = isDark ? AppColors.primary       : AppColorsLight.primary;
        final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
        final border        = isDark ? AppColors.border        : AppColorsLight.border;

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainScreen(
                  onLocaleChange: widget.onLocaleChange ?? (_) {},
                  onThemeChange:  widget.onThemeChange  ?? (_) {},
                  isDarkNotifier: isDarkNotifier,
                )),
              );
            } else if (state is AuthFailure) {
              final translated = _translateError(state.error, l);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(translated),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: bg,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Language selector ─────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: ['EN', 'FR', 'AR'].map((lang) {
                        final selected = _currentLang == lang;
                        return GestureDetector(
                          onTap: () => _changeLang(lang),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected ? primary.withOpacity(0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? primary : border,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(lang, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w500, color: selected ? primary : textSecondary)),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // ── Logo ─────────────────────────────────────────
                    Center(
                      child: Column(children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset('assets/icons/agriscan_logo.png', fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(l.appName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: 3)),
                        const SizedBox(height: 4),
                        Text(l.tagline, style: TextStyle(fontSize: 12, color: textSecondary, letterSpacing: 0.5)),
                      ]),
                    ),
                    const SizedBox(height: 52),

                    Text(l.welcomeBack, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary)),
                    const SizedBox(height: 4),
                    Text(l.signInToAccount, style: TextStyle(fontSize: 13, color: textSecondary)),
                    const SizedBox(height: 32),

                    Form(
                      key: _formKey,
                      child: Column(children: [

                        // ── Username ──────────────────────────────────
                        CustomTextField(
                          controller: _usernameController,
                          label: l.username,
                          prefixIcon: Icon(Icons.person_outline, color: textSecondary, size: 20),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return l.required;
                            if (v.trim().length < 3) return l.usernameMin;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Password ──────────────────────────────────
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: textPrimary, fontSize: 14),
                          validator: (v) {
                            if (v == null || v.isEmpty) return l.required;
                            if (v.length < 6) return l.passwordMin;
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: l.password,
                            labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                            prefixIcon: Icon(Icons.lock_outline, color: textSecondary, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: textSecondary, size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true, fillColor: surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400)),
                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Login button ──────────────────────────────
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => CustomButton(
                            text: l.signIn,
                            isLoading: state is AuthLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(LoginEvent(
                                  username: _usernameController.text.trim(),
                                  password: _passwordController.text,
                                ));
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Forgot password ───────────────────────────
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                            child: Text(l.forgotPassword, style: TextStyle(color: textSecondary, fontSize: 13)),
                          ),
                        ),

                        // ── QR Login ──────────────────────────────────
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => QrScreen(
                                isDarkNotifier: isDarkNotifier,
                                onLocaleChange: widget.onLocaleChange ?? (_) {},
                                onThemeChange:  widget.onThemeChange  ?? (_) {},
                              )),
                            ),
                            icon: Icon(Icons.qr_code_scanner, color: primary),
                            label: Text(l.loginWithQr, style: TextStyle(color: primary, fontSize: 13)),
                          ),
                        ),

                        // ── Register link ─────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l.noAccount, style: TextStyle(color: textSecondary, fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => RegistrationScreen(
                                  isDarkNotifier: isDarkNotifier,
                                  onLocaleChange: widget.onLocaleChange,
                                  onThemeChange:  widget.onThemeChange,
                                )),
                              ),
                              child: Text(l.register, style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ],
                        ),
                      ]),
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
}