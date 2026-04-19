import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'login_screen.dart';

class QrDisplayScreen extends StatefulWidget {
  final String qrToken;
  final ValueNotifier<bool> isDarkNotifier;
  final Function(Locale) onLocaleChange;
  final Function(bool) onThemeChange;

  const QrDisplayScreen({
    super.key,
    required this.qrToken,
    required this.isDarkNotifier,
    required this.onLocaleChange,
    required this.onThemeChange,
  });

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _saving = false;
  bool _saved = false;

  Future<void> _saveToGallery(bool isDark) async {
    setState(() => _saving = true);
    try {
      await Permission.storage.request();
      await Permission.photos.request();

      final imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes == null) throw Exception('Failed to capture');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/agriscan_qr_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);
      await GallerySaver.saveImage(file.path, albumName: 'AgriScan');

      if (!mounted) return;
      setState(() { _saving = false; _saved = true; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('✅ QR code sauvegardé dans la galerie !'),
        backgroundColor: isDark ? AppColors.primary : AppColorsLight.primary,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDarkNotifier,
      builder: (context, isDark, _) {
        final bg = isDark ? AppColors.background : AppColorsLight.background;
        final surface = isDark ? AppColors.surface : AppColorsLight.surface;
        final border = isDark ? AppColors.border : AppColorsLight.border;
        final primary = isDark ? AppColors.primary : AppColorsLight.primary;
        final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
        final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
        final gold = isDark ? AppColors.gold : AppColorsLight.gold;

        return WillPopScope(
          onWillPop: () async => false, // empêcher retour arrière
          child: Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: bg,
              automaticallyImplyLeading: false,
              title: Text('Votre QR Code', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
              bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: border)),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const SizedBox(height: 8),

                // Warning banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gold.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    Icon(Icons.warning_amber_rounded, color: gold, size: 22),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'Ce QR code ne s\'affiche qu\'une seule fois. Téléchargez-le maintenant pour pouvoir vous connecter avec.',
                      style: TextStyle(color: gold, fontSize: 12, height: 1.5, fontWeight: FontWeight.w600),
                    )),
                  ]),
                ),

                const SizedBox(height: 24),
                Text('Compte créé avec succès !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: primary)),
                const SizedBox(height: 6),
                Text('Sauvegardez votre QR code personnel', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: textSecondary, height: 1.5)),

                const SizedBox(height: 28),

                // QR Code
                Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: PrettyQrView.data(
                          data: widget.qrToken,
                          errorCorrectLevel: QrErrorCorrectLevel.H,
                          decoration: PrettyQrDecoration(
                            shape: PrettyQrSmoothSymbol(color: const Color(0xFF050E1A)),
                            image: const PrettyQrDecorationImage(
                              image: AssetImage('assets/icons/agriscan_logo.png'),
                              scale: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('AgriScan', style: TextStyle(color: Color(0xFF050E1A), fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 2)),
                    ]),
                  ),
                ),

                const SizedBox(height: 28),

                // Save button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primary, cyan]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : () => _saveToGallery(isDark),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _saving
                        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: bg))
                        : Icon(_saved ? Icons.check_circle : Icons.download_rounded, color: bg),
                    label: Text(
                      _saved ? 'QR code sauvegardé !' : 'Télécharger dans la galerie',
                      style: TextStyle(color: bg, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                  child: Row(children: [
                    Icon(Icons.info_outline, color: textSecondary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'Vous retrouverez ce QR code dans votre profil après connexion.',
                      style: TextStyle(color: textSecondary, fontSize: 12, height: 1.5),
                    )),
                  ]),
                ),

                const SizedBox(height: 24),

                // Continue to login
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen(
                        isDarkNotifier: widget.isDarkNotifier,
                        onLocaleChange: widget.onLocaleChange,
                        onThemeChange: widget.onThemeChange,
                      )),
                      (route) => false,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primary.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Continuer vers la connexion', style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        );
      },
    );
  }
}