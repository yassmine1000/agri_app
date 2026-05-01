import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class ShopScreen extends StatefulWidget {
  final bool isDarkMode;
  const ShopScreen({super.key, this.isDarkMode = true});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final Dio _dio = Dio();
  List<dynamic> _products = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  bool _isAdmin = false;
  String? _error;
  String _selectedCategory = 'Tous';
  String _lang = 'EN';
  final _searchCtrl = TextEditingController();

  final List<String> _categories = ['Tous', 'Insecticide', 'Fongicide', 'Herbicide', 'Fertilisant', 'Biostimulant', 'Adjuvant'];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await PrefHelper.getUser();
    if (!mounted) return;
    setState(() {
      _lang = prefs.getString('language') ?? 'EN';
      _isAdmin = user?['role'] == 'admin';
    });
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final token = await PrefHelper.getToken();
      final response = await _dio.get(
        '${Config.baseUrl}/products',
        options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
      );
      if (!mounted) return;
      setState(() {
        _products = response.data['data'] ?? [];
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Failed to load products'; _loading = false; });
    }
  }

  void _applyFilter() {
    List<dynamic> result = _products;
    if (_selectedCategory != 'Tous') {
      result = result.where((p) => p['category'] == _selectedCategory).toList();
    }
    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((p) =>
        (_displayName(p)).toLowerCase().contains(q) ||
        (_displayCategory(p)).toLowerCase().contains(q)
      ).toList();
    }
    _filtered = result;
  }

  String _displayName(dynamic p) {
    if (_lang == 'FR' && p['name_fr'] != null) return p['name_fr'];
    if (_lang == 'AR' && p['name_ar'] != null) return p['name_ar'];
    return p['name'] ?? '';
  }

  String _displayCategory(dynamic p) {
    if (_lang == 'FR' && p['category_fr'] != null) return p['category_fr'];
    if (_lang == 'AR' && p['category_ar'] != null) return p['category_ar'];
    return p['category'] ?? '';
  }

  String _displayDescription(dynamic p) {
    if (_lang == 'FR' && p['description_fr'] != null) return p['description_fr'];
    if (_lang == 'AR' && p['description_ar'] != null) return p['description_ar'];
    return p['description'] ?? '';
  }

  String _categoryLabel(String cat) {
    if (_lang == 'AR') {
      const map = {'Tous': 'الكل', 'Insecticide': 'مبيد حشري', 'Fongicide': 'مبيد فطري', 'Herbicide': 'مبيد أعشاب', 'Fertilisant': 'سماد', 'Biostimulant': 'منشط بيولوجي', 'Adjuvant': 'مادة مساعدة'};
      return map[cat] ?? cat;
    }
    if (_lang == 'EN') {
      const map = {'Tous': 'All', 'Insecticide': 'Insecticide', 'Fongicide': 'Fungicide', 'Herbicide': 'Herbicide', 'Fertilisant': 'Fertilizer', 'Biostimulant': 'Biostimulant', 'Adjuvant': 'Adjuvant'};
      return map[cat] ?? cat;
    }
    const map = {'Tous': 'Tous'};
    return map[cat] ?? cat;
  }

  Color _categoryColor(String cat, Color primary, Color cyan, Color gold, Color error) {
    switch (cat) {
      case 'Insecticide': return error;
      case 'Fongicide': return primary;
      case 'Herbicide': return const Color(0xFF8BC34A);
      case 'Fertilisant': return gold;
      case 'Biostimulant': return cyan;
      case 'Adjuvant': return const Color(0xFF9C27B0);
      default: return primary;
    }
  }

  Future<void> _deleteProduct(dynamic product, bool isDark) async {
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final errorColor = isDark ? AppColors.error : AppColorsLight.error;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: border)),
        title: Text(_lang == 'AR' ? 'حذف المنتج' : _lang == 'FR' ? 'Supprimer le produit' : 'Delete Product', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Text('${_lang == 'AR' ? 'حذف' : _lang == 'FR' ? 'Supprimer' : 'Delete'} "${_displayName(product)}"?', style: TextStyle(color: textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(_lang == 'AR' ? 'إلغاء' : _lang == 'FR' ? 'Annuler' : 'Cancel', style: TextStyle(color: textSecondary))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: errorColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(_lang == 'AR' ? 'حذف' : _lang == 'FR' ? 'Supprimer' : 'Delete', style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final token = await PrefHelper.getToken();
        await _dio.delete('${Config.baseUrl}/products/${product['id']}', options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}));
        _loadProducts();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_lang == 'AR' ? 'تم حذف المنتج' : _lang == 'FR' ? 'Produit supprimé' : 'Product deleted'), backgroundColor: isDark ? AppColors.primary : AppColorsLight.primary));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _toggleStock(dynamic product) async {
    try {
      final token = await PrefHelper.getToken();
      final newStatus = !(product['stock_available'] == true);
      await _dio.put(
        '${Config.baseUrl}/products/${product["id"]}',
        data: {
          'name':           product['name'],
          'name_fr':        product['name_fr'],
          'name_ar':        product['name_ar'],
          'price':          product['price'],
          'category':       product['category'],
          'category_fr':    product['category_fr'],
          'category_ar':    product['category_ar'],
          'description':    product['description'],
          'description_fr': product['description_fr'],
          'description_ar': product['description_ar'],
          'stock_available': newStatus,
        },
        options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
      );
      _loadProducts();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
    }
  }



  // ── helpers trilingues ───────────────────────────────────────────
  String _t(String en, String fr, String ar) {
    if (_lang == 'FR') return fr;
    if (_lang == 'AR') return ar;
    return en;
  }

  String? _validateNotEmpty(String? v, String fieldLabel) {
    if (v == null || v.trim().isEmpty) return '$fieldLabel ${_t("is required", "est requis", "مطلوب")}';
    return null;
  }

  String? _validatePrice(String? v) {
    if (v == null || v.trim().isEmpty) return _t('Price is required', 'Le prix est requis', 'السعر مطلوب');
    final n = double.tryParse(v.trim());
    if (n == null || n <= 0) return _t('Invalid price', 'Prix invalide', 'سعر غير صالح');
    return null;
  }

  void _openAddProductDialog(bool isDark) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl    = TextEditingController();
    final nameFrCtrl  = TextEditingController();
    final nameArCtrl  = TextEditingController();
    final priceCtrl   = TextEditingController();
    final descCtrl    = TextEditingController();
    final descFrCtrl  = TextEditingController();
    final descArCtrl  = TextEditingController();
    String selectedCategory   = 'Insecticide';
    String selectedCategoryFr = 'Insecticide';
    String selectedCategoryAr = 'مبيد حشري';
    bool stockAvailable = true;
    XFile? pickedImage;
    bool submitting = false;
    final isAr = _lang == 'AR';

    // category maps
    final catKeys = ['Insecticide','Fongicide','Herbicide','Fertilisant','Biostimulant','Adjuvant'];
    final catFr   = ['Insecticide','Fongicide','Herbicide','Fertilisant','Biostimulant','Adjuvant'];
    final catAr   = ['مبيد حشري','مبيد فطري','مبيد أعشاب','سماد','منشط بيولوجي','مادة مساعدة'];
    final catEn   = ['Insecticide','Fungicide','Herbicide','Fertilizer','Biostimulant','Adjuvant'];

    final surface       = isDark ? AppColors.surfaceAlt       : AppColorsLight.surfaceAlt;
    final border        = isDark ? AppColors.border            : AppColorsLight.border;
    final primary       = isDark ? AppColors.primary           : AppColorsLight.primary;
    final cyan          = isDark ? AppColors.cyan              : AppColorsLight.cyan;
    final textPrimary   = isDark ? AppColors.textPrimary       : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary     : AppColorsLight.textSecondary;
    final dialogBg      = isDark ? AppColors.surface           : AppColorsLight.surface;
    final bg            = isDark ? AppColors.background        : AppColorsLight.background;
    final errorColor    = isDark ? AppColors.error             : AppColorsLight.error;

    InputDecoration _field(String label, {String? hint}) => InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: textSecondary, fontSize: 13),
      hintStyle: TextStyle(color: textSecondary.withOpacity(0.5), fontSize: 12),
      filled: true, fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: errorColor)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: errorColor, width: 1.5)),
      errorStyle: TextStyle(color: errorColor, fontSize: 11),
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
            title: Text(
              _t('Add Product', 'Ajouter un produit', 'إضافة منتج'),
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [

                  // ── Image picker ─────────────────────────────────
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final img = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                      maxWidth: 1920,
                      maxHeight: 1920,
                    );
                      if (img != null) setD(() => pickedImage = img);
                    },
                    child: Container(
                      height: 120, width: double.infinity,
                      decoration: BoxDecoration(
                        color: surface, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border, style: BorderStyle.solid),
                      ),
                      child: pickedImage != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(pickedImage!.path), fit: BoxFit.cover))
                          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.add_photo_alternate_outlined, color: primary, size: 36),
                              const SizedBox(height: 6),
                              Text(_t('Tap to add image', 'Appuyer pour ajouter une image', 'اضغط لإضافة صورة'),
                                style: TextStyle(color: textSecondary, fontSize: 12)),
                            ]),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Name EN ──────────────────────────────────────
                  TextFormField(
                    controller: nameCtrl,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _field(_t('Name (EN)', 'Nom (EN)', 'الاسم (EN)')),
                    validator: (v) => _validateNotEmpty(v, _t('Name EN', 'Nom EN', 'الاسم بالإنجليزية')),
                  ),
                  const SizedBox(height: 10),

                  // ── Name FR ──────────────────────────────────────
                  TextFormField(
                    controller: nameFrCtrl,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _field(_t('Name (FR)', 'Nom (FR)', 'الاسم (FR)')),
                    validator: (v) => _validateNotEmpty(v, _t('Name FR', 'Nom FR', 'الاسم بالفرنسية')),
                  ),
                  const SizedBox(height: 10),

                  // ── Name AR ──────────────────────────────────────
                  TextFormField(
                    controller: nameArCtrl,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    textDirection: TextDirection.rtl,
                    decoration: _field(_t('Name (AR)', 'Nom (AR)', 'الاسم (AR)')),
                    validator: (v) => _validateNotEmpty(v, _t('Name AR', 'Nom AR', 'الاسم بالعربية')),
                  ),
                  const SizedBox(height: 10),

                  // ── Price ────────────────────────────────────────
                  TextFormField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _field(_t('Price (DT)', 'Prix (DT)', 'السعر (د.ت)')),
                    validator: _validatePrice,
                  ),
                  const SizedBox(height: 10),

                  // ── Category ─────────────────────────────────────
                  DropdownButtonFormField<int>(
                    value: 0,
                    dropdownColor: surface,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _field(_t('Category', 'Catégorie', 'الفئة')),
                    items: List.generate(catKeys.length, (i) => DropdownMenuItem(
                      value: i,
                      child: Text(_lang == 'FR' ? catFr[i] : _lang == 'AR' ? catAr[i] : catEn[i]),
                    )),
                    onChanged: (i) => setD(() {
                      selectedCategory   = catKeys[i!];
                      selectedCategoryFr = catFr[i];
                      selectedCategoryAr = catAr[i];
                    }),
                  ),
                  const SizedBox(height: 10),

                  // ── Description EN ───────────────────────────────
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _field(
                      _t('Description (EN)', 'Description (EN)', 'الوصف (EN)'),
                      hint: _t('Optional', 'Facultatif', 'اختياري'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Description FR ───────────────────────────────
                  TextFormField(
                    controller: descFrCtrl,
                    maxLines: 2,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _field(
                      _t('Description (FR)', 'Description (FR)', 'الوصف (FR)'),
                      hint: _t('Optional', 'Facultatif', 'اختياري'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Description AR ───────────────────────────────
                  TextFormField(
                    controller: descArCtrl,
                    maxLines: 2,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: _field(
                      _t('Description (AR)', 'Description (AR)', 'الوصف (AR)'),
                      hint: _t('Optional', 'Facultatif', 'اختياري'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Stock toggle ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                    child: Row(children: [
                      Text(_t('In stock', 'En stock', 'متوفر'), style: TextStyle(color: textPrimary, fontSize: 13)),
                      const Spacer(),
                      Switch(
                        value: stockAvailable,
                        onChanged: (v) => setD(() => stockAvailable = v),
                        activeColor: primary,
                      ),
                    ]),
                  ),
                ])),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(_t('Cancel', 'Annuler', 'إلغاء'), style: TextStyle(color: textSecondary)),
              ),
              Container(
                decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(10)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: submitting ? null : () async {
                    if (!formKey.currentState!.validate()) return;
                    setD(() => submitting = true);
                    try {
                      final token = await PrefHelper.getToken();
                      final formData = FormData.fromMap({
                        'name':            nameCtrl.text.trim(),
                        'name_fr':         nameFrCtrl.text.trim(),
                        'name_ar':         nameArCtrl.text.trim(),
                        'price':           double.parse(priceCtrl.text.trim()),
                        'category':        selectedCategory,
                        'category_fr':     selectedCategoryFr,
                        'category_ar':     selectedCategoryAr,
                        'description':     descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                        'description_fr':  descFrCtrl.text.trim().isEmpty ? null : descFrCtrl.text.trim(),
                        'description_ar':  descArCtrl.text.trim().isEmpty ? null : descArCtrl.text.trim(),
                        'stock_available': stockAvailable.toString(),
                        if (pickedImage != null)
                          'image': await MultipartFile.fromFile(pickedImage!.path,
                            filename: pickedImage!.name),
                      });
                      await _dio.post(
                        '${Config.baseUrl}/products',
                        data: formData,
                        options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true',
                          'Content-Type': 'multipart/form-data'}),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadProducts();
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(_t('Product added successfully', 'Produit ajouté avec succès', 'تمت إضافة المنتج بنجاح')),
                        backgroundColor: isDark ? AppColors.primary : AppColorsLight.primary,
                      ));
                    } catch (e) {
                      setD(() => submitting = false);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(_t('Error adding product', "Erreur lors de l'ajout", 'خطأ في إضافة المنتج')),
                        backgroundColor: errorColor,
                      ));
                    }
                  },
                  child: submitting
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: bg, strokeWidth: 2))
                      : Text(_t('Add', 'Ajouter', 'إضافة'), style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditPriceDialog(dynamic product, bool isDark) {
    final priceCtrl = TextEditingController(text: product['price'].toString());
    final isAr = _lang == 'AR';
    final surface       = isDark ? AppColors.surfaceAlt       : AppColorsLight.surfaceAlt;
    final border        = isDark ? AppColors.border            : AppColorsLight.border;
    final primary       = isDark ? AppColors.primary           : AppColorsLight.primary;
    final cyan          = isDark ? AppColors.cyan              : AppColorsLight.cyan;
    final textPrimary   = isDark ? AppColors.textPrimary       : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary     : AppColorsLight.textSecondary;
    final dialogBg      = isDark ? AppColors.surface           : AppColorsLight.surface;
    final bg            = isDark ? AppColors.background        : AppColorsLight.background;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
          title: Text(
            isAr ? 'تعديل السعر' : _lang == 'FR' ? 'Modifier le prix' : 'Edit Price',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          ),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              _displayName(product),
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: isAr ? 'السعر' : _lang == 'FR' ? 'Prix' : 'Price',
                labelStyle: TextStyle(color: textSecondary, fontSize: 13),
                suffixText: isAr ? 'د.ت' : 'DT',
                suffixStyle: TextStyle(color: primary),
                filled: true, fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
              ),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : _lang == 'FR' ? 'Annuler' : 'Cancel', style: TextStyle(color: textSecondary)),
            ),
            Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(10)),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  if (priceCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(isAr ? 'السعر مطلوب' : _lang == 'FR' ? 'Le prix est requis' : 'Price is required'),
                      backgroundColor: (isDark ? AppColors.error : AppColorsLight.error),
                    ));
                    return;
                  }
                  final newPrice = double.tryParse(priceCtrl.text.trim());
                  if (newPrice == null || newPrice <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(isAr ? 'سعر غير صالح' : _lang == 'FR' ? 'Prix invalide' : 'Invalid price'),
                      backgroundColor: (isDark ? AppColors.error : AppColorsLight.error),
                    ));
                    return;
                  }
                  try {
                    final token = await PrefHelper.getToken();
                    await _dio.put(
                      '${Config.baseUrl}/products/${product['id']}',
                      data: {
                        'name':            product['name'],
                        'name_fr':         product['name_fr'],
                        'name_ar':         product['name_ar'],
                        'price':           newPrice,
                        'category':        product['category'],
                        'category_fr':     product['category_fr'],
                        'category_ar':     product['category_ar'],
                        'description':     product['description'],
                        'description_fr':  product['description_fr'],
                        'description_ar':  product['description_ar'],
                        'stock_available': product['stock_available'],
                      },
                      options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadProducts();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isAr ? 'تم تحديث السعر' : _lang == 'FR' ? 'Prix mis à jour' : 'Price updated'),
                      backgroundColor: isDark ? AppColors.primary : AppColorsLight.primary,
                    ));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: Text(isAr ? 'حفظ' : _lang == 'FR' ? 'Enregistrer' : 'Save', style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetail(dynamic p, bool isDark) {
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final gold = isDark ? AppColors.gold : AppColorsLight.gold;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final errorColor = isDark ? AppColors.error : AppColorsLight.error;
    final catColor = _categoryColor(p['category'] ?? '', primary, cyan, gold, errorColor);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),

              // Image
              if (p['image_url'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    '${Config.baseUrl.replaceAll('/api', '')}${p['image_url']}',
                    height: 220, width: double.infinity, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(height: 220, color: surface, child: Icon(Icons.image_not_supported, color: textSecondary, size: 48)),
                    headers: const {'ngrok-skip-browser-warning': 'true'},
                  ),
                ),

              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Text(_displayName(p), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(20)),
                  child: Text('${p['price']} DT', style: TextStyle(color: bg, fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ]),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(_displayCategory(p), style: TextStyle(color: catColor, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              const SizedBox(height: 12),
              if (_displayDescription(p).isNotEmpty)
                Text(_displayDescription(p), style: TextStyle(color: textSecondary, fontSize: 14, height: 1.6)),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p['stock_available'] == true ? primary.withOpacity(0.1) : errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: p['stock_available'] == true ? primary.withOpacity(0.3) : errorColor.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Icon(p['stock_available'] == true ? Icons.check_circle_outline : Icons.cancel_outlined, color: p['stock_available'] == true ? primary : errorColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    p['stock_available'] == true
                        ? (_lang == 'AR' ? 'متوفر في المخزون' : _lang == 'FR' ? 'En stock' : 'In stock')
                        : (_lang == 'AR' ? 'غير متوفر' : _lang == 'FR' ? 'Rupture de stock' : 'Out of stock'),
                    style: TextStyle(color: p['stock_available'] == true ? primary : errorColor, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              // Admin: edit price + toggle stock buttons
              if (_isAdmin) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openEditPriceDialog(p, isDark);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cyan),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(Icons.edit_outlined, color: cyan, size: 18),
                    label: Text(
                      _lang == 'AR' ? 'تعديل السعر' : _lang == 'FR' ? 'Modifier le prix' : 'Edit Price',
                      style: TextStyle(color: cyan, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleStock(p);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: p['stock_available'] == true ? errorColor : primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(
                      p['stock_available'] == true ? Icons.remove_shopping_cart_outlined : Icons.add_shopping_cart_outlined,
                      color: p['stock_available'] == true ? errorColor : primary,
                      size: 18,
                    ),
                    label: Text(
                      p['stock_available'] == true
                          ? (_lang == 'AR' ? 'تحديد كـ: غير متوفر' : _lang == 'FR' ? 'Marquer comme épuisé' : 'Mark as out of stock')
                          : (_lang == 'AR' ? 'تحديد كـ: متوفر' : _lang == 'FR' ? 'Marquer comme en stock' : 'Mark as in stock'),
                      style: TextStyle(
                        color: p['stock_available'] == true ? errorColor : primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final isAr = _lang == 'AR';
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final gold = isDark ? AppColors.gold : AppColorsLight.gold;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final errorColor = isDark ? AppColors.error : AppColorsLight.error;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        body: Builder(builder: (context) {
          if (_loading) return Center(child: CircularProgressIndicator(color: primary));
          if (_error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.error_outline, color: textSecondary, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadProducts, style: ElevatedButton.styleFrom(backgroundColor: primary), child: Text(_lang == 'AR' ? 'إعادة المحاولة' : _lang == 'FR' ? 'Réessayer' : 'Retry', style: TextStyle(color: bg))),
          ]));
          return RefreshIndicator(
                    onRefresh: _loadProducts, color: primary,
                    child: CustomScrollView(slivers: [
                      // Search bar
                      SliverToBoxAdapter(child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: TextField(
                          controller: _searchCtrl,
                          style: TextStyle(color: textPrimary, fontSize: 14),
                          onChanged: (v) => setState(() => _applyFilter()),
                          decoration: InputDecoration(
                            hintText: isAr ? 'البحث عن منتج...' : _lang == 'FR' ? 'Rechercher un produit...' : 'Search product...',
                            hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                            prefixIcon: Icon(Icons.search, color: textSecondary, size: 20),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(icon: Icon(Icons.clear, color: textSecondary, size: 18), onPressed: () => setState(() { _searchCtrl.clear(); _applyFilter(); }))
                                : null,
                            filled: true, fillColor: surface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
                          ),
                        ),
                      )),

                      // Category filter
                      SliverToBoxAdapter(child: SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _categories.length,
                          itemBuilder: (_, i) {
                            final cat = _categories[i];
                            final selected = _selectedCategory == cat;
                            final catColor = _categoryColor(cat, primary, cyan, gold, errorColor);
                            return GestureDetector(
                              onTap: () => setState(() { _selectedCategory = cat; _applyFilter(); }),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: selected ? catColor : surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: selected ? catColor : border),
                                ),
                                child: Center(child: Text(_categoryLabel(cat), style: TextStyle(color: selected ? Colors.white : textSecondary, fontWeight: selected ? FontWeight.w700 : FontWeight.normal, fontSize: 12))),
                              ),
                            );
                          },
                        ),
                      )),

                      // Count
                      SliverToBoxAdapter(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('${_filtered.length} ${isAr ? 'منتج' : _lang == 'FR' ? 'produits' : 'products'}', style: TextStyle(color: textSecondary, fontSize: 12)),
                      )),

                      // Grid
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final p = _filtered[index];
                              final catColor = _categoryColor(p['category'] ?? '', primary, cyan, gold, errorColor);
                              final imageBase = Config.baseUrl.replaceAll('/api', '');

                              return GestureDetector(
                                onTap: () => _showProductDetail(p, isDark),
                                child: Container(
                                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    // Image
                                    Stack(children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                        child: p['image_url'] != null
                                            ? Image.network(
                                                '$imageBase${p['image_url']}',
                                                height: 130, width: double.infinity, fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) => Container(height: 130, color: bg, child: Icon(Icons.eco_outlined, color: primary, size: 40)),
                                                headers: const {'ngrok-skip-browser-warning': 'true'},
                                              )
                                            : Container(height: 130, color: bg, child: Icon(Icons.eco_outlined, color: primary, size: 40)),
                                      ),
                                      if (_isAdmin) ...[
                                        Positioned(top: 4, right: 4, child: GestureDetector(
                                          onTap: () => _deleteProduct(p, isDark),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(color: errorColor.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                                            child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                                          ),
                                        )),
                                        Positioned(top: 4, right: 36, child: GestureDetector(
                                          onTap: () => _openEditPriceDialog(p, isDark),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(color: cyan.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                                            child: const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                                          ),
                                        )),
                                      ],
                                      if (p['stock_available'] == false)
                                        Positioned(top: 4, left: 4, child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: errorColor.withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                                          child: Text(isAr ? 'نفذ' : _lang == 'FR' ? 'Épuisé' : 'Out', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                                        )),
                                    ]),

                                    // Info
                                    Expanded(child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                                            child: Text(_displayCategory(p), style: TextStyle(color: catColor, fontSize: 9, fontWeight: FontWeight.w700)),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(_displayName(p), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        ]),
                                        Text('${p['price']} DT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: primary)),
                                      ]),
                                    )),
                                  ]),
                                ),
                              );
                            },
                            childCount: _filtered.length,
                          ),
                        ),
                      ),
                    ]),
                  );
        }),
        floatingActionButton: _isAdmin
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, cyan]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FloatingActionButton.extended(
                  onPressed: () => _openAddProductDialog(isDark),
                  backgroundColor: Colors.transparent, elevation: 0,
                  icon: Icon(Icons.add, color: bg),
                  label: Text(
                    _lang == 'AR' ? 'إضافة منتج' : _lang == 'FR' ? 'Ajouter un produit' : 'Add Product',
                    style: TextStyle(color: bg, fontWeight: FontWeight.w700),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}