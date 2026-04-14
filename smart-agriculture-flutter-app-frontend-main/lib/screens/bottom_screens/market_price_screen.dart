import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class MarketPricesScreen extends StatefulWidget {
  final bool isDarkMode;
  const MarketPricesScreen({super.key, this.isDarkMode = true});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  final Dio _dio = Dio();
  List<dynamic> _prices = [];
  bool _loading = true;
  bool _isAdmin = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _loadPrices();
  }

  Future<void> _checkAdmin() async {
    final user = await PrefHelper.getUser();
    if (!mounted) return;
    setState(() => _isAdmin = user?['role'] == 'admin');
  }

  Future<void> _loadPrices() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final token = await PrefHelper.getToken();
      final response = await _dio.get(
        '${Config.baseUrl}/prices',
        options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
      );
      if (!mounted) return;
      setState(() { _prices = response.data['data'] ?? []; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Unable to load prices'; _loading = false; });
    }
  }

  void _openAddPriceDialog(AppLocalizations l, bool isDark) {
    final plantCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCategory = 'Légumes';
    String selectedUnit = 'kg';
    final surface = isDark ? AppColors.surfaceAlt : AppColorsLight.surfaceAlt;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final dialogBg = isDark ? AppColors.surface : AppColorsLight.surface;
    final bg = isDark ? AppColors.background : AppColorsLight.background;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
          title: Text(l.addPrice, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            _dialogField(plantCtrl, l.plantName, surface, border, textPrimary, textSecondary, primary),
            const SizedBox(height: 12),
            _dialogDropdown(value: selectedCategory, label: l.category, items: ['Légumes', 'Fruits', 'Céréales', 'Herbes'], surface: surface, border: border, textPrimary: textPrimary, textSecondary: textSecondary, primary: primary, onChanged: (v) => setDialogState(() => selectedCategory = v!)),
            const SizedBox(height: 12),
            _dialogField(priceCtrl, l.price, surface, border, textPrimary, textSecondary, primary, isNumber: true),
            const SizedBox(height: 12),
            _dialogDropdown(value: selectedUnit, label: l.unit, items: ['kg', 'g', 'pièce', 'litre', 'botte'], surface: surface, border: border, textPrimary: textPrimary, textSecondary: textSecondary, primary: primary, onChanged: (v) => setDialogState(() => selectedUnit = v!)),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel, style: TextStyle(color: textSecondary))),
            Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(10)),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  if (plantCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                  try {
                    final token = await PrefHelper.getToken();
                    await _dio.post('${Config.baseUrl}/prices',
                      data: {'plant_name': plantCtrl.text, 'category': selectedCategory, 'price': double.parse(priceCtrl.text), 'unit': selectedUnit},
                      options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
                    );
                    Navigator.pop(ctx);
                    _loadPrices();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.priceAdded)));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.errorAdding)));
                  }
                },
                child: Text(l.add, style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, Color surface, Color border, Color textPrimary, Color textSecondary, Color primary, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : null,
      style: TextStyle(color: textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
        filled: true, fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
      ),
    );
  }

  Widget _dialogDropdown({required String value, required String label, required List<String> items, required Color surface, required Color border, required Color textPrimary, required Color textSecondary, required Color primary, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value, dropdownColor: surface,
      style: TextStyle(color: textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
        filled: true, fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _deletePrice(int id, AppLocalizations l) async {
    try {
      final token = await PrefHelper.getToken();
      await _dio.delete('${Config.baseUrl}/prices/$id', options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}));
      _loadPrices();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.priceDeleted)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.errorDeleting)));
    }
  }

  Map<String, List<dynamic>> _groupByCategory() {
    final Map<String, List<dynamic>> grouped = {};
    for (var price in _prices) { grouped.putIfAbsent(price['category'] ?? 'Other', () => []).add(price); }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = widget.isDarkMode;
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
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.error_outline, size: 60, color: textSecondary),
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadPrices, style: ElevatedButton.styleFrom(backgroundColor: primary), child: Text(l.retry, style: TextStyle(color: bg))),
                ]))
              : _prices.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.storefront_outlined, size: 60, color: textSecondary),
                      const SizedBox(height: 12),
                      Text(l.noDataToday, style: TextStyle(color: textSecondary, fontSize: 16)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _loadPrices, color: primary,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: primary.withOpacity(0.2))),
                            child: Row(children: [
                              Icon(Icons.calendar_today, color: primary, size: 16),
                              const SizedBox(width: 8),
                              Text('${l.today} — ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 13)),
                              const Spacer(),
                              Text('${_prices.length} ${l.products}', style: TextStyle(color: textSecondary, fontSize: 12)),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          ..._groupByCategory().entries.map((entry) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(entry.key.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cyan, letterSpacing: 1.5))),
                            ...entry.value.map((price) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                              child: Row(children: [
                                Container(width: 36, height: 36, decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(price['plant_name'][0].toUpperCase(), style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 15)))),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(price['plant_name'], style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 14)),
                                  Text('per ${price['unit']}', style: TextStyle(fontSize: 11, color: textSecondary)),
                                ])),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(20)), child: Text('${price['price']} DT', style: TextStyle(color: bg, fontWeight: FontWeight.w700, fontSize: 13))),
                                if (_isAdmin) IconButton(icon: Icon(Icons.delete_outline, color: errorColor, size: 18), onPressed: () => _deletePrice(price['id'], l)),
                              ]),
                            )),
                            const SizedBox(height: 8),
                          ])),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
      floatingActionButton: _isAdmin
          ? Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(16)),
              child: FloatingActionButton.extended(
                onPressed: () => _openAddPriceDialog(l, isDark),
                backgroundColor: Colors.transparent, elevation: 0,
                icon: Icon(Icons.add, color: bg),
                label: Text(l.addPrice, style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
              ),
            )
          : null,
    );
  }
}