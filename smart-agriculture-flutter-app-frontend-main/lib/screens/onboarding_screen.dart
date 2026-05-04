import 'package:flutter/material.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/screens/login_screen.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Function(bool) onThemeChange;
  final ValueNotifier<bool> isDarkNotifier;

  const OnboardingScreen({
    super.key,
    required this.onLocaleChange,
    required this.onThemeChange,
    required this.isDarkNotifier,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl,  curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _animateIn() {
    _fadeCtrl.reset();
    _slideCtrl.reset();
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => LoginScreen(
          onLocaleChange: widget.onLocaleChange,
          onThemeChange:  widget.onThemeChange,
          isDarkNotifier: widget.isDarkNotifier,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDarkNotifier,
      builder: (context, isDark, _) {
        final l = AppLocalizations.of(context)!;
        final isAr = Localizations.localeOf(context).languageCode == 'ar';

        final bg            = isDark ? AppColors.background    : AppColorsLight.background;
        final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
        final border        = isDark ? AppColors.border        : AppColorsLight.border;
        final primary       = isDark ? AppColors.primary       : AppColorsLight.primary;
        final cyan          = isDark ? AppColors.cyan          : AppColorsLight.cyan;
        final gold          = isDark ? AppColors.gold          : AppColorsLight.gold;
        final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

        final pages = [
          _OnboardingPage(
            emoji: '🔬',
            gradientColors: [primary, cyan],
            title: l.onboardingTitle1,
            description: l.onboardingDesc1,
            features: [
              _Feature('🍃', '38+', l.chipPlantSpecies),
              _Feature('⚡', '99%', l.chipAccuracy),
              _Feature('📸', '⚡', l.chipAnalysis),
            ],
          ),
          //_OnboardingPage(
          //  emoji: '🌱',
          //  gradientColors: [const Color(0xFF4CAF50), cyan],
          //  title: l.onboardingTitle2,
          //  description: l.onboardingDesc2,
          //  features: [
          //    _Feature('🧪', l.chipNpk, l.chipSoilAnalysis),
          //    _Feature('🌾', '🌾', l.chipCropPlans),
          //    _Feature('💊', '💊', l.chipDosing),
          //  ],
        //  ),
          _OnboardingPage(
            emoji: '📊',
            gradientColors: [gold, primary],
            title: l.onboardingTitle3,
            description: l.onboardingDesc3,
            features: [
              _Feature('📈', '📈', l.chipLive),
              _Feature('📅', '📅', l.chipCalendar),
              _Feature('🛒', '🛒', l.chipProducts),
            ],
          ),
        ];

        final currentPageData = pages[_currentPage];
        final pageColor = currentPageData.gradientColors[0];

        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bg,
            body: SafeArea(
              child: Stack(
                children: [

                  // ── Background decorative circles ───────────────
                  Positioned(
                    top: -60, right: isAr ? null : -60, left: isAr ? -60 : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pageColor.withOpacity(isDark ? 0.08 : 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100, left: isAr ? null : -40, right: isAr ? -40 : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPageData.gradientColors[1].withOpacity(isDark ? 0.06 : 0.04),
                      ),
                    ),
                  ),

                  Column(
                    children: [

                      // ── Top bar: logo + skip ────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo
                            Row(children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [primary, cyan]),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset('assets/icons/agriscan_logo.png', fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('AgriScan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: 1)),
                            ]),
                            // Skip
                            if (_currentPage < 2)
                              TextButton(
                                onPressed: _goToLogin,
                                child: Text(l.skip, style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                      ),

                      // ── PageView ───────────────────────────────
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (i) {
                            setState(() => _currentPage = i);
                            _animateIn();
                          },
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            final page = pages[index];
                            return FadeTransition(
                              opacity: _fadeAnim,
                              child: SlideTransition(
                                position: _slideAnim,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 28),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 20),

                                      // ── Central emoji card ──────
                                      Container(
                                        width: 140, height: 140,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: page.gradientColors,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(40),
                                          boxShadow: [
                                            BoxShadow(
                                              color: page.gradientColors[0].withOpacity(0.35),
                                              blurRadius: 30,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(page.emoji, style: const TextStyle(fontSize: 64)),
                                        ),
                                      ),
                                      const SizedBox(height: 36),

                                      // ── Title ───────────────────
                                      Text(
                                        page.title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: textPrimary,
                                          height: 1.2,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 14),

                                      // ── Description ─────────────
                                      Text(
                                        page.description,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textSecondary,
                                          height: 1.65,
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      // ── Feature chips ────────────
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: page.features.map((f) => Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: surface,
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: page.gradientColors[0].withOpacity(0.25)),
                                            ),
                                            child: Column(children: [
                                              Text(f.emoji, style: const TextStyle(fontSize: 18)),
                                              const SizedBox(height: 4),
                                              Text(f.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: page.gradientColors[0])),
                                              Text(f.label, style: TextStyle(fontSize: 9, color: textSecondary, fontWeight: FontWeight.w500)),
                                            ]),
                                          ),
                                        )).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Bottom: dots + button ──────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                        child: Column(children: [

                          // Dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(2, (i) {
                              final active = i == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 24 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: active ? pageColor : border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),

                          // Main button
                          GestureDetector(
                            onTap: _nextPage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: currentPageData.gradientColors,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: pageColor.withOpacity(0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentPage < 2 ? l.next : l.getStarted,
                                      style: TextStyle(
                                        color: isDark ? AppColors.background : Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _currentPage < 2 ? Icons.arrow_forward_rounded : Icons.rocket_launch_rounded,
                                      color: isDark ? AppColors.background : Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final List<Color> gradientColors;
  final String title;
  final String description;
  final List<_Feature> features;

  const _OnboardingPage({
    required this.emoji,
    required this.gradientColors,
    required this.title,
    required this.description,
    required this.features,
  });
}

class _Feature {
  final String emoji;
  final String value;
  final String label;
  const _Feature(this.emoji, this.value, this.label);
}