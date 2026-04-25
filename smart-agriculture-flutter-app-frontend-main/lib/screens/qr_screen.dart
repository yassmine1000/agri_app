import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'package:smart_agri_app/screens/main_screen.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;

class QrScreen extends StatefulWidget {
  final ValueNotifier<bool> isDarkNotifier;
  final Function(Locale) onLocaleChange;
  final Function(bool) onThemeChange;

  const QrScreen({
    super.key,
    required this.isDarkNotifier,
    required this.onLocaleChange,
    required this.onThemeChange,
  });

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> with SingleTickerProviderStateMixin {
  // This screen is for LOGIN via QR — user is NOT logged in yet
  // Tab 0: My QR Code (load from local prefs if available)
  // Tab 1: Scanner (scan another user's QR to log in)
  late TabController _tabController;
  final ScreenshotController _screenshotController = ScreenshotController();
  final MobileScannerController _scannerController = MobileScannerController();
  String? _qrToken;
  bool _loading = true;
  bool _scanning = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQrToken();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _loadQrToken() async {
    setState(() { _loading = true; _error = null; });
    final localToken = await PrefHelper.getQrToken();
    if (localToken != null) {
      if (!mounted) return;
      setState(() { _qrToken = localToken; _loading = false; });
      return;
    }
    try {
      final token = await PrefHelper.getToken();
      if (token == null) {
        if (!mounted) return;
        setState(() { _error = 'login_required'; _loading = false; });
        return;
      }
      final response = await Dio().get(
        '${Config.baseUrl}/auth/qr-token',
        options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
      );
      final qrToken = response.data['qr_token'];
      await PrefHelper.saveQrToken(qrToken);
      if (!mounted) return;
      setState(() { _qrToken = qrToken; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'load_error'; _loading = false; });
    }
  }

  Future<void> _saveQrToGallery(bool isDark, AppLocalizations l) async {
    setState(() => _saving = true);
    try {
      await Permission.storage.request();
      await Permission.photos.request();
      final imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes == null) throw Exception('Capture failed');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/agriscan_qr.png');
      await file.writeAsBytes(imageBytes);
      await GallerySaver.saveImage(file.path, albumName: 'AgriScan');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.qrSaved),
        backgroundColor: isDark ? AppColors.primary : AppColorsLight.primary,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.qrSaveError)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loginWithQrToken(String qrToken, AppLocalizations l) async {
    try {
      final response = await Dio().post(
        '${Config.baseUrl}/auth/login-qr',
        data: {'qr_token': qrToken},
        options: Options(headers: {'ngrok-skip-browser-warning': 'true'}),
      );
      final data = response.data;
      await PrefHelper.saveLoginData(data['token'], data['user']);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(
          onLocaleChange: widget.onLocaleChange,
          onThemeChange: widget.onThemeChange,
          isDarkNotifier: widget.isDarkNotifier,
        )),
        (route) => false,
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? l.invalidQr;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _scanFromGallery(AppLocalizations l) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final scanner = mlkit.BarcodeScanner();
      final barcodes = await scanner.processImage(inputImage);
      await scanner.close();
      if (barcodes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.noQrFound)));
        return;
      }
      final value = barcodes.first.rawValue;
      if (value != null) await _loginWithQrToken(value, l);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l.qrSaveError}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l    = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDarkNotifier,
      builder: (context, isDark, _) {
        final bg            = isDark ? AppColors.background    : AppColorsLight.background;
        final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
        final border        = isDark ? AppColors.border        : AppColorsLight.border;
        final primary       = isDark ? AppColors.primary       : AppColorsLight.primary;
        final cyan          = isDark ? AppColors.cyan          : AppColorsLight.cyan;
        final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: bg,
              title: Text('QR Code', style: TextStyle(color: textPrimary)),
              iconTheme: IconThemeData(color: textPrimary),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(49),
                child: Column(children: [
                  Container(height: 1, color: border),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: primary,
                    labelColor: primary,
                    unselectedLabelColor: textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: [
                      Tab(text: l.myQrCode),
                      Tab(text: l.scanner),
                    ],
                  ),
                ]),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [

                // ── Tab 1: My QR Code ───────────────────────────
                _loading
                    ? Center(child: CircularProgressIndicator(color: primary))
                    : _error != null
                        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.error_outline, color: textSecondary, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              _error == 'login_required' ? l.loginRequired : l.qrLoadError,
                              style: TextStyle(color: textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadQrToken,
                              style: ElevatedButton.styleFrom(backgroundColor: primary),
                              child: Text(l.retryLoad, style: TextStyle(color: bg)),
                            ),
                          ]))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(children: [
                              const SizedBox(height: 16),
                              Text(l.yourPersonalQr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                              const SizedBox(height: 8),
                              Text(l.scanToLogin, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: textSecondary, height: 1.5)),
                              const SizedBox(height: 28),

                              Screenshot(
                                controller: _screenshotController,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)],
                                  ),
                                  child: Column(children: [
                                    PrettyQrView.data(
                                      data: _qrToken!,
                                      errorCorrectLevel: QrErrorCorrectLevel.H,
                                      decoration: PrettyQrDecoration(
                                        shape: PrettyQrSmoothSymbol(color: const Color(0xFF050E1A)),
                                        image: PrettyQrDecorationImage(
                                          image: AssetImage('assets/icons/agriscan_logo.png'),
                                          scale: 0.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text('AgriScan', style: TextStyle(color: Color(0xFF050E1A), fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2)),
                                  ]),
                                ),
                              ),

                              const SizedBox(height: 28),

                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(14)),
                                child: ElevatedButton.icon(
                                  onPressed: _saving ? null : () => _saveQrToGallery(isDark, l),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                  icon: _saving
                                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: bg))
                                      : Icon(Icons.download_rounded, color: bg),
                                  label: Text(l.saveToGallery, style: TextStyle(color: bg, fontWeight: FontWeight.w700, fontSize: 14)),
                                ),
                              ),

                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                                child: Row(children: [
                                  Icon(Icons.info_outline, color: textSecondary, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(l.qrSecurityNote, style: TextStyle(color: textSecondary, fontSize: 12, height: 1.5))),
                                ]),
                              ),
                            ]),
                          ),

                // ── Tab 2: Scanner ──────────────────────────────
                Column(children: [
                  Expanded(
                    child: Stack(children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) async {
                          if (_scanning) return;
                          final barcodes = capture.barcodes;
                          if (barcodes.isEmpty) return;
                          final value = barcodes.first.rawValue;
                          if (value == null) return;
                          setState(() => _scanning = true);
                          await _scannerController.stop();
                          await _loginWithQrToken(value, l);
                          if (mounted) setState(() => _scanning = false);
                        },
                      ),
                      Center(child: Container(
                        width: 250, height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: primary, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(children: [
                          Positioned(top: 0, left: 0, child: _corner(primary)),
                          Positioned(top: 0, right: 0, child: Transform.rotate(angle: 1.5708, child: _corner(primary))),
                          Positioned(bottom: 0, left: 0, child: Transform.rotate(angle: -1.5708, child: _corner(primary))),
                          Positioned(bottom: 0, right: 0, child: Transform.rotate(angle: 3.1416, child: _corner(primary))),
                        ]),
                      )),
                      if (_scanning) Container(color: Colors.black54, child: Center(child: CircularProgressIndicator(color: primary))),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: bg,
                    child: Column(children: [
                      Text(l.pointCamera, textAlign: TextAlign.center, style: TextStyle(color: textSecondary, fontSize: 13)),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(border: Border.all(color: primary.withOpacity(0.5)), borderRadius: BorderRadius.circular(14)),
                        child: ElevatedButton.icon(
                          onPressed: () => _scanFromGallery(l),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          icon: Icon(Icons.photo_library_outlined, color: primary),
                          label: Text(l.importFromGallery, style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _corner(Color color) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: color, width: 4),
        left: BorderSide(color: color, width: 4),
      ),
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
    ),
  );
}