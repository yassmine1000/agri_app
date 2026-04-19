import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _lang = 'EN';

  // Categories EN/FR/AR
  final Map<String, Map<String, String>> _categories = {
    'Légumes': {'EN': 'Vegetables', 'FR': 'Légumes', 'AR': 'خضروات'},
    'Fruits': {'EN': 'Fruits', 'FR': 'Fruits', 'AR': 'فواكه'},
    'Céréales': {'EN': 'Cereals', 'FR': 'Céréales', 'AR': 'حبوب'},
    'Herbes': {'EN': 'Herbs', 'FR': 'Herbes', 'AR': 'أعشاب'},
  };

  // Units EN/FR/AR
  final Map<String, Map<String, String>> _units = {
    'kg': {'EN': 'kg', 'FR': 'kg', 'AR': 'كغ'},
    'g': {'EN': 'g', 'FR': 'g', 'AR': 'غ'},
    'pièce': {'EN': 'piece', 'FR': 'pièce', 'AR': 'قطعة'},
    'litre': {'EN': 'litre', 'FR': 'litre', 'AR': 'لتر'},
    'botte': {'EN': 'bunch', 'FR': 'botte', 'AR': 'حزمة'},
  };

  String _catLabel(String key) => _categories[key]?[_lang] ?? key;
  String _unitLabel(String key) => _units[key]?[_lang] ?? key;

  @override
  void initState() {
    super.initState();
    _loadLangAndData();
  }

  Future<void> _loadLangAndData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _lang = prefs.getString('language') ?? 'EN');
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
    final isAr = _lang == 'AR';

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
        builder: (ctx, setDialogState) => Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
            title: Text(l.addPrice, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Plant name
              TextField(
                controller: plantCtrl,
                style: TextStyle(color: textPrimary, fontSize: 14),
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: l.plantName, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                  filled: true, fillColor: surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),
              // Category
              DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: surface,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: l.category, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                  filled: true, fillColor: surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                ),
                items: _categories.keys.map((k) => DropdownMenuItem(value: k, child: Text(_catLabel(k)))).toList(),
                onChanged: (v) => setDialogState(() => selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              // Price
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: l.price, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                  filled: true, fillColor: surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),
              // Unit
              DropdownButtonFormField<String>(
                value: selectedUnit,
                dropdownColor: surface,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: l.unit, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                  filled: true, fillColor: surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                ),
                items: _units.keys.map((k) => DropdownMenuItem(value: k, child: Text(_unitLabel(k)))).toList(),
                onChanged: (v) => setDialogState(() => selectedUnit = v!),
              ),
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
      ),
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
    final isAr = _lang == 'AR';
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final errorColor = isDark ? AppColors.error : AppColorsLight.error;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
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
                            ..._groupByCategory().entries.map((entry) => Column(crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(_catLabel(entry.key).toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cyan, letterSpacing: 1.5)),
                              ),
                              ...entry.value.map((price) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                                child: Row(children: [
                                  Container(width: 36, height: 36, decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(price['plant_name'][0].toUpperCase(), style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 15)))),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                                    Text(price['plant_name'], style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 14)),
                                    Text('${isAr ? 'لكل' : 'per'} ${_unitLabel(price['unit'])}', style: TextStyle(fontSize: 11, color: textSecondary)),
                                  ])),
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(20)), child: Text('${price['price']} ${isAr ? 'د.ت' : 'DT'}', style: TextStyle(color: bg, fontWeight: FontWeight.w700, fontSize: 13))),
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
      ),
    );
  }
}