import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/screens/main_screen.dart';
import 'package:smart_agri_app/screens/registration_screen.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'package:smart_agri_app/utils/custom_widgets.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkNotifier = widget.isDarkNotifier ?? ValueNotifier(true);

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkNotifier,
      builder: (context, isDark, _) {
        final l = AppLocalizations.of(context)!;
        final bg = isDark ? AppColors.background : AppColorsLight.background;
        final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
        final primary = isDark ? AppColors.primary : AppColorsLight.primary;
        final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainScreen(
                  onLocaleChange: widget.onLocaleChange ?? (_) {},
                  onThemeChange: widget.onThemeChange ?? (_) {},
                  isDarkNotifier: isDarkNotifier,
                )),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
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
                    const SizedBox(height: 60),
                    Center(
                      child: Column(children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [primary, cyan], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(child: Text('🌿', style: TextStyle(fontSize: 36))),
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
                        CustomTextField(
                          controller: _usernameController,
                          label: l.username,
                          prefixIcon: Icon(Icons.person_outline, color: textSecondary, size: 20),
                          validator: (v) => v!.isEmpty ? l.required : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: textPrimary, fontSize: 14),
                          validator: (v) => v!.isEmpty ? l.required : null,
                          decoration: InputDecoration(
                            labelText: l.password,
                            prefixIcon: Icon(Icons.lock_outline, color: textSecondary, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: textSecondary, size: 20),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => CustomButton(
                            text: l.signIn,
                            isLoading: state is AuthLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(LoginEvent(
                                  username: _usernameController.text,
                                  password: _passwordController.text,
                                ));
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l.noAccount, style: TextStyle(color: textSecondary, fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationScreen())),
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