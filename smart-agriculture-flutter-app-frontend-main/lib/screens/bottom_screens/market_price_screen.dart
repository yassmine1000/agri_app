import 'dart:async';
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
  DateTime _today = DateTime.now();
  Timer? _dayTimer;

  // ── Translation maps ─────────────────────────────────────────────
  final Map<String, Map<String, String>> _categories = {
    'Légumes':    {'EN': 'Vegetables', 'FR': 'Légumes',  'AR': 'خضروات'},
    'Vegetables': {'EN': 'Vegetables', 'FR': 'Légumes',  'AR': 'خضروات'},
    'خضروات':     {'EN': 'Vegetables', 'FR': 'Légumes',  'AR': 'خضروات'},
    'Fruits':     {'EN': 'Fruits',     'FR': 'Fruits',   'AR': 'فواكه'},
    'فواكه':      {'EN': 'Fruits',     'FR': 'Fruits',   'AR': 'فواكه'},
    'Céréales':   {'EN': 'Cereals',    'FR': 'Céréales', 'AR': 'حبوب'},
    'Cereals':    {'EN': 'Cereals',    'FR': 'Céréales', 'AR': 'حبوب'},
    'حبوب':       {'EN': 'Cereals',    'FR': 'Céréales', 'AR': 'حبوب'},
    'Herbes':     {'EN': 'Herbs',      'FR': 'Herbes',   'AR': 'أعشاب'},
    'Herbs':      {'EN': 'Herbs',      'FR': 'Herbes',   'AR': 'أعشاب'},
    'أعشاب':      {'EN': 'Herbs',      'FR': 'Herbes',   'AR': 'أعشاب'},
  };

  final Map<String, Map<String, String>> _units = {
    'kg':    {'EN': 'kg',    'FR': 'kg',    'AR': 'كغ'},
    'كغ':    {'EN': 'kg',    'FR': 'kg',    'AR': 'كغ'},
    'g':     {'EN': 'g',     'FR': 'g',     'AR': 'غ'},
    'غ':     {'EN': 'g',     'FR': 'g',     'AR': 'غ'},
    'pièce': {'EN': 'piece', 'FR': 'pièce', 'AR': 'قطعة'},
    'piece': {'EN': 'piece', 'FR': 'pièce', 'AR': 'قطعة'},
    'قطعة':  {'EN': 'piece', 'FR': 'pièce', 'AR': 'قطعة'},
    'litre': {'EN': 'litre', 'FR': 'litre', 'AR': 'لتر'},
    'لتر':   {'EN': 'litre', 'FR': 'litre', 'AR': 'لتر'},
    'botte': {'EN': 'bunch', 'FR': 'botte', 'AR': 'حزمة'},
    'bunch': {'EN': 'bunch', 'FR': 'botte', 'AR': 'حزمة'},
    'حزمة':  {'EN': 'bunch', 'FR': 'botte', 'AR': 'حزمة'},
  };

  // key = stored value (FR), translations per lang
  final Map<String, Map<String, String>> _plants = {
    // ── Légumes ──────────────────────────────────────────────────────
    'Tomate':           {'EN': 'Tomato',           'FR': 'Tomate',           'AR': 'طماطم'},
    'Pomme de terre':   {'EN': 'Potato',           'FR': 'Pomme de terre',   'AR': 'بطاطا'},
    'Oignon':           {'EN': 'Onion',            'FR': 'Oignon',           'AR': 'بصل'},
    'Carotte':          {'EN': 'Carrot',           'FR': 'Carotte',          'AR': 'جزر'},
    'Courgette':        {'EN': 'Zucchini',         'FR': 'Courgette',        'AR': 'كوسة'},
    'Poivron':          {'EN': 'Bell pepper',      'FR': 'Poivron',          'AR': 'فلفل حلو'},
    'Aubergine':        {'EN': 'Eggplant',         'FR': 'Aubergine',        'AR': 'باذنجان'},
    'Concombre':        {'EN': 'Cucumber',         'FR': 'Concombre',        'AR': 'خيار'},
    'Haricot vert':     {'EN': 'Green bean',       'FR': 'Haricot vert',     'AR': 'لوبيا خضراء'},
    'Piment':           {'EN': 'Chili pepper',     'FR': 'Piment',           'AR': 'فلفل حار'},
    'Ail':              {'EN': 'Garlic',           'FR': 'Ail',              'AR': 'ثوم'},
    'Navet':            {'EN': 'Turnip',           'FR': 'Navet',            'AR': 'لفت'},
    'Céleri':           {'EN': 'Celery',           'FR': 'Céleri',           'AR': 'كرفس'},
    'Épinard':          {'EN': 'Spinach',          'FR': 'Épinard',          'AR': 'سبانخ'},
    'Chou-fleur':       {'EN': 'Cauliflower',      'FR': 'Chou-fleur',       'AR': 'قرنبيط'},
    'Brocoli':          {'EN': 'Broccoli',         'FR': 'Brocoli',          'AR': 'بروكلي'},
    'Chou':             {'EN': 'Cabbage',          'FR': 'Chou',             'AR': 'كرمب'},
    'Poireau':          {'EN': 'Leek',             'FR': 'Poireau',          'AR': 'كراث'},
    'Betterave':        {'EN': 'Beetroot',         'FR': 'Betterave',        'AR': 'شمندر'},
    'Radis':            {'EN': 'Radish',           'FR': 'Radis',            'AR': 'فجل'},
    'Petit pois':       {'EN': 'Peas',             'FR': 'Petit pois',       'AR': 'بازلاء'},
    'Fenouil':          {'EN': 'Fennel',           'FR': 'Fenouil',          'AR': 'بسباس'},
    'Artichaut':        {'EN': 'Artichoke',        'FR': 'Artichaut',        'AR': 'خرشوف'},
    'Laitue':           {'EN': 'Lettuce',          'FR': 'Laitue',           'AR': 'خس'},
    'Blette':           {'EN': 'Swiss chard',      'FR': 'Blette',           'AR': 'سلق'},
    'Citrouille':       {'EN': 'Pumpkin',          'FR': 'Citrouille',       'AR': 'قرع'},
    'Gombo':            {'EN': 'Okra',             'FR': 'Gombo',            'AR': 'ملوخية'},
    'Haricot blanc':    {'EN': 'White bean',       'FR': 'Haricot blanc',    'AR': 'لوبيا بيضاء'},
    'Fève':             {'EN': 'Broad bean',       'FR': 'Fève',             'AR': 'فول'},
    'Pois chiche':      {'EN': 'Chickpea',         'FR': 'Pois chiche',      'AR': 'حمص'},
    // ── Fruits ───────────────────────────────────────────────────────
    'Pomme':            {'EN': 'Apple',            'FR': 'Pomme',            'AR': 'تفاح'},
    'Orange':           {'EN': 'Orange',           'FR': 'Orange',           'AR': 'برتقال'},
    'Banane':           {'EN': 'Banana',           'FR': 'Banane',           'AR': 'موز'},
    'Raisin':           {'EN': 'Grape',            'FR': 'Raisin',           'AR': 'عنب'},
    'Pastèque':         {'EN': 'Watermelon',       'FR': 'Pastèque',         'AR': 'بطيخ'},
    'Melon':            {'EN': 'Melon',            'FR': 'Melon',            'AR': 'شمام'},
    'Poire':            {'EN': 'Pear',             'FR': 'Poire',            'AR': 'كمثرى'},
    'Figue':            {'EN': 'Fig',              'FR': 'Figue',            'AR': 'تين'},
    'Grenade':          {'EN': 'Pomegranate',      'FR': 'Grenade',          'AR': 'رمان'},
    'Abricot':          {'EN': 'Apricot',          'FR': 'Abricot',          'AR': 'مشمش'},
    'Pêche':            {'EN': 'Peach',            'FR': 'Pêche',            'AR': 'خوخ'},
    'Citron':           {'EN': 'Lemon',            'FR': 'Citron',           'AR': 'ليمون'},
    'Mandarine':        {'EN': 'Mandarin',         'FR': 'Mandarine',        'AR': 'يوسفي'},
    'Fraise':           {'EN': 'Strawberry',       'FR': 'Fraise',           'AR': 'فريز'},
    'Cerise':           {'EN': 'Cherry',           'FR': 'Cerise',           'AR': 'كرز'},
    'Prune':            {'EN': 'Plum',             'FR': 'Prune',            'AR': 'برقوق'},
    'Nectarine':        {'EN': 'Nectarine',        'FR': 'Nectarine',        'AR': 'نكتارين'},
    'Kaki':             {'EN': 'Persimmon',        'FR': 'Kaki',             'AR': 'كاكي'},
    'Jujube':           {'EN': 'Jujube',           'FR': 'Jujube',           'AR': 'عناب'},
    'Datte':            {'EN': 'Date',             'FR': 'Datte',            'AR': 'تمر'},
    'Olive':            {'EN': 'Olive',            'FR': 'Olive',            'AR': 'زيتون'},
    'Citron vert':      {'EN': 'Lime',             'FR': 'Citron vert',      'AR': 'ليمون أخضر'},
    'Pamplemousse':     {'EN': 'Grapefruit',       'FR': 'Pamplemousse',     'AR': 'بوملو'},
    'Framboise':        {'EN': 'Raspberry',        'FR': 'Framboise',        'AR': 'توت العليق'},
    'Mûre':             {'EN': 'Blackberry',       'FR': 'Mûre',             'AR': 'توت أسود'},
    'Ananas':           {'EN': 'Pineapple',        'FR': 'Ananas',           'AR': 'أناناس'},
    'Mangue':           {'EN': 'Mango',            'FR': 'Mangue',           'AR': 'مانجو'},
    'Noix':             {'EN': 'Walnut',           'FR': 'Noix',             'AR': 'جوز'},
    'Amande':           {'EN': 'Almond',           'FR': 'Amande',           'AR': 'لوز'},
    'Noisette':         {'EN': 'Hazelnut',         'FR': 'Noisette',         'AR': 'بندق'},
    // ── Céréales ─────────────────────────────────────────────────────
    'Blé':              {'EN': 'Wheat',            'FR': 'Blé',              'AR': 'قمح'},
    'Orge':             {'EN': 'Barley',           'FR': 'Orge',             'AR': 'شعير'},
    'Maïs':             {'EN': 'Corn',             'FR': 'Maïs',             'AR': 'ذرة'},
    'Sorgho':           {'EN': 'Sorghum',          'FR': 'Sorgho',           'AR': 'ذرة رفيعة'},
    'Avoine':           {'EN': 'Oats',             'FR': 'Avoine',           'AR': 'شوفان'},
    'Seigle':           {'EN': 'Rye',              'FR': 'Seigle',           'AR': 'جاودار'},
    'Triticale':        {'EN': 'Triticale',        'FR': 'Triticale',        'AR': 'تريتيكالي'},
    'Riz':              {'EN': 'Rice',             'FR': 'Riz',              'AR': 'أرز'},
    'Millet':           {'EN': 'Millet',           'FR': 'Millet',           'AR': 'دخن'},
    'Épeautre':         {'EN': 'Spelt',            'FR': 'Épeautre',         'AR': 'قمح الكاملة'},
    'Sarrasin':         {'EN': 'Buckwheat',        'FR': 'Sarrasin',         'AR': 'حنطة سوداء'},
    'Sésame':           {'EN': 'Sesame',           'FR': 'Sésame',           'AR': 'سمسم'},
    'Tournesol':        {'EN': 'Sunflower seed',   'FR': 'Tournesol',        'AR': 'عباد الشمس'},
    'Lentille':         {'EN': 'Lentil',           'FR': 'Lentille',         'AR': 'عدس'},
    // ── Herbes ───────────────────────────────────────────────────────
    'Menthe':           {'EN': 'Mint',             'FR': 'Menthe',           'AR': 'نعناع'},
    'Persil':           {'EN': 'Parsley',          'FR': 'Persil',           'AR': 'بقدونس'},
    'Coriandre':        {'EN': 'Coriander',        'FR': 'Coriandre',        'AR': 'كزبرة'},
    'Basilic':          {'EN': 'Basil',            'FR': 'Basilic',          'AR': 'ريحان'},
    'Thym':             {'EN': 'Thyme',            'FR': 'Thym',             'AR': 'زعتر'},
    'Romarin':          {'EN': 'Rosemary',         'FR': 'Romarin',          'AR': 'إكليل الجبل'},
    'Laurier':          {'EN': 'Bay leaf',         'FR': 'Laurier',          'AR': 'غار'},
    'Sauge':            {'EN': 'Sage',             'FR': 'Sauge',            'AR': 'مريمية'},
    'Origan':           {'EN': 'Oregano',          'FR': 'Origan',           'AR': 'أوريغانو'},
    'Aneth':            {'EN': 'Dill',             'FR': 'Aneth',            'AR': 'شبت'},
    'Estragon':         {'EN': 'Tarragon',         'FR': 'Estragon',         'AR': 'طرخون'},
    'Ciboulette':       {'EN': 'Chives',           'FR': 'Ciboulette',       'AR': 'ثوم معمر'},
    'Mélisse':          {'EN': 'Lemon balm',       'FR': 'Mélisse',          'AR': 'حشيشة الليمون'},
    'Verveine':         {'EN': 'Verbena',          'FR': 'Verveine',         'AR': 'لويزة'},
    'Lavande':          {'EN': 'Lavender',         'FR': 'Lavande',          'AR': 'خزامى'},
    'Cumin':            {'EN': 'Cumin',            'FR': 'Cumin',            'AR': 'كمون'},
    'Carvi':            {'EN': 'Caraway',          'FR': 'Carvi',            'AR': 'كراوية'},
    'Fenouil sauvage':  {'EN': 'Wild fennel',      'FR': 'Fenouil sauvage',  'AR': 'شمرة برية'},
    'Zaatar':           {'EN': 'Za\'atar',         'FR': 'Zaatar',           'AR': 'زعتر بري'},
    'Harissa':          {'EN': 'Harissa herb',     'FR': 'Harissa',          'AR': 'هريسة'},
    'Fenugrec':         {'EN': 'Fenugreek',        'FR': 'Fenugrec',         'AR': 'حلبة'},
  };

  // Plants grouped by category key (FR stored value)
  final Map<String, List<String>> _plantsByCategory = {
    'Légumes': ['Tomate','Pomme de terre','Oignon','Carotte','Courgette','Poivron','Aubergine','Concombre','Haricot vert','Piment','Ail','Navet','Céleri','Épinard','Chou-fleur','Brocoli','Chou','Poireau','Betterave','Radis','Petit pois','Fenouil','Artichaut','Laitue','Blette','Citrouille','Gombo','Haricot blanc','Fève','Pois chiche'],
    'Fruits':  ['Pomme','Orange','Banane','Raisin','Pastèque','Melon','Poire','Figue','Grenade','Abricot','Pêche','Citron','Mandarine','Fraise','Cerise','Prune','Nectarine','Kaki','Jujube','Datte','Olive','Citron vert','Pamplemousse','Framboise','Mûre','Ananas','Mangue','Noix','Amande','Noisette'],
    'Céréales':['Blé','Orge','Maïs','Sorgho','Avoine','Seigle','Triticale','Riz','Millet','Épeautre','Sarrasin','Sésame','Tournesol','Lentille'],
    'Herbes':  ['Menthe','Persil','Coriandre','Basilic','Thym','Romarin','Laurier','Sauge','Origan','Aneth','Estragon','Ciboulette','Mélisse','Verveine','Lavande','Cumin','Carvi','Fenouil sauvage','Zaatar','Harissa','Fenugrec'],
  };

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      if (_lang == 'AR') {
        const months = ['جانفي','فيفري','مارس','أفريل','ماي','جوان','جويلية','أوت','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
        return '${date.day} ${months[date.month - 1]} ${date.year}';
      }
      if (_lang == 'FR') {
        const months = ['jan.','fév.','mar.','avr.','mai','juin','juil.','août','sep.','oct.','nov.','déc.'];
        return '${date.day} ${months[date.month - 1]} ${date.year}';
      }
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) { return ''; }
  }

  String _formatTodayLabel() {
    if (_lang == 'AR') {
      const months = ['جانفي','فيفري','مارس','أفريل','ماي','جوان','جويلية','أوت','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
      return '${_today.day} ${months[_today.month - 1]} ${_today.year}';
    }
    if (_lang == 'FR') {
      const months = ['jan.','fév.','mar.','avr.','mai','juin','juil.','août','sep.','oct.','nov.','déc.'];
      return '${_today.day} ${months[_today.month - 1]} ${_today.year}';
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[_today.month - 1]} ${_today.day}, ${_today.year}';
  }

  String _catLabel(String key) => _categories[key]?[_lang] ?? key;
  String _unitLabel(String key) => _units[key]?[_lang] ?? key;
  String _plantLabel(String key) {
    // Try direct key first, then search all entries
    if (_plants.containsKey(key)) return _plants[key]![_lang] ?? key;
    for (final entry in _plants.entries) {
      if (entry.value.values.contains(key)) return entry.value[_lang] ?? key;
    }
    return key;
  }

  @override
  void initState() {
    super.initState();
    _loadLangAndData();
    _startDayTimer();
  }

  void _startDayTimer() {
    // Refresh at midnight every day
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final untilMidnight = midnight.difference(now);
    _dayTimer = Timer(untilMidnight, () {
      if (mounted) setState(() => _today = DateTime.now());
      // Re-schedule every 24h after first midnight
      _dayTimer = Timer.periodic(const Duration(days: 1), (_) {
        if (mounted) setState(() => _today = DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _dayTimer?.cancel();
    super.dispose();
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
      setState(() { _error = AppLocalizations.of(context)!.failedToLoadPrices; _loading = false; });
    }
  }

  void _openAddPriceDialog(AppLocalizations l, bool isDark) {
    String selectedCategory = 'Légumes';
    String selectedPlant = 'Tomate';
    String selectedUnit = 'kg';
    final priceCtrl = TextEditingController();
    final isAr = _lang == 'AR';

    final surface   = isDark ? AppColors.surfaceAlt      : AppColorsLight.surfaceAlt;
    final border    = isDark ? AppColors.border           : AppColorsLight.border;
    final primary   = isDark ? AppColors.primary          : AppColorsLight.primary;
    final cyan      = isDark ? AppColors.cyan             : AppColorsLight.cyan;
    final textPrimary   = isDark ? AppColors.textPrimary  : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary: AppColorsLight.textSecondary;
    final dialogBg  = isDark ? AppColors.surface          : AppColorsLight.surface;
    final bg        = isDark ? AppColors.background       : AppColorsLight.background;

    InputDecoration _fieldDeco(String label) => InputDecoration(
      labelText: label, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
      filled: true, fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: dialogBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
            title: Text(l.addPrice, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Category
              DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: surface,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: _fieldDeco(l.category),
                items: ['Légumes','Fruits','Céréales','Herbes']
                    .map((k) => DropdownMenuItem(value: k, child: Text(_catLabel(k)))).toList(),
                onChanged: (v) => setD(() {
                  selectedCategory = v!;
                  selectedPlant = _plantsByCategory[selectedCategory]!.first;
                }),
              ),
              const SizedBox(height: 12),
              // Plant — dropdown from predefined list
              DropdownButtonFormField<String>(
                value: selectedPlant,
                dropdownColor: surface,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: _fieldDeco(l.plantName),
                items: (_plantsByCategory[selectedCategory] ?? [])
                    .map((k) => DropdownMenuItem(value: k, child: Text(_plantLabel(k)))).toList(),
                onChanged: (v) => setD(() => selectedPlant = v!),
              ),
              const SizedBox(height: 12),
              // Price
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: _fieldDeco(l.price),
              ),
              const SizedBox(height: 12),
              // Unit
              DropdownButtonFormField<String>(
                value: selectedUnit,
                dropdownColor: surface,
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: _fieldDeco(l.unit),
                items: ['kg','g','pièce','litre','botte']
                    .map((k) => DropdownMenuItem(value: k, child: Text(_unitLabel(k)))).toList(),
                onChanged: (v) => setD(() => selectedUnit = v!),
              ),
            ])),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel, style: TextStyle(color: textSecondary))),
              Container(
                decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(10)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    if (priceCtrl.text.isEmpty) return;
                    try {
                      final token = await PrefHelper.getToken();
                      await _dio.post('${Config.baseUrl}/prices',
                        data: {'plant_name': selectedPlant, 'category': selectedCategory, 'price': double.parse(priceCtrl.text), 'unit': selectedUnit},
                        options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
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

  void _openEditPriceDialog(dynamic price, AppLocalizations l, bool isDark) {
    final priceCtrl = TextEditingController(text: price['price'].toString());
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
          title: Text(_plantLabel(price['plant_name']), style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
          content: TextField(
            controller: priceCtrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: l.price, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
              suffixText: isAr ? 'د.ت' : 'DT', suffixStyle: TextStyle(color: primary),
              filled: true, fillColor: surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel, style: TextStyle(color: textSecondary))),
            Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(10)),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  if (priceCtrl.text.isEmpty) return;
                  try {
                    final token = await PrefHelper.getToken();
                    await _dio.put('${Config.baseUrl}/prices/${price['id']}',
                      data: {'price': double.parse(priceCtrl.text)},
                      options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadPrices();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.priceUpdated)));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.errorAdding)));
                  }
                },
                child: Text(l.saveChanges, style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePrice(int id, AppLocalizations l) async {
    try {
      final token = await PrefHelper.getToken();
      await _dio.delete('${Config.baseUrl}/prices/$id',
        options: Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'}));
      _loadPrices();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.priceDeleted)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.errorDeleting)));
    }
  }

  Map<String, List<dynamic>> _groupByCategory() {
    final Map<String, List<dynamic>> grouped = {};
    for (var p in _prices) { grouped.putIfAbsent(p['category'] ?? 'Other', () => []).add(p); }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context)!;
    final isDark = widget.isDarkMode;
    final isAr  = _lang == 'AR';
    final bg            = isDark ? AppColors.background    : AppColorsLight.background;
    final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
    final border        = isDark ? AppColors.border        : AppColorsLight.border;
    final primary       = isDark ? AppColors.primary       : AppColorsLight.primary;
    final cyan          = isDark ? AppColors.cyan          : AppColorsLight.cyan;
    final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final errorColor    = isDark ? AppColors.error         : AppColorsLight.error;

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
                        if (_isAdmin) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _openAddPriceDialog(l, isDark),
                            icon: Icon(Icons.add, color: bg),
                            label: Text(l.addPrice, style: TextStyle(color: bg)),
                            style: ElevatedButton.styleFrom(backgroundColor: primary),
                          ),
                        ],
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
                                Text(_formatTodayLabel(), style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 13)),
                                const Spacer(),
                                Text('${_prices.length} ${l.products}', style: TextStyle(color: textSecondary, fontSize: 12)),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            ..._groupByCategory().entries.map((entry) => Column(
                              crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(_catLabel(entry.key).toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cyan, letterSpacing: 1.5)),
                                ),
                                ...entry.value.map((price) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                                  child: Row(children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                      child: Center(child: Text(_plantLabel(price['plant_name'])[0].toUpperCase(), style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 15))),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Column(
                                      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Text(_plantLabel(price['plant_name']), style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 14)),
                                        Text(
                                          '${_lang == 'AR' ? 'لكل' : _lang == 'FR' ? 'par' : 'per'} ${_unitLabel(price['unit'])}',
                                          style: TextStyle(fontSize: 11, color: textSecondary),
                                        ),
                                        if (price['updated_at'] != null)
                                          Row(mainAxisSize: MainAxisSize.min, children: [
                                            Icon(Icons.update, size: 10, color: textSecondary),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${_lang == 'AR' ? 'آخر تحديث:' : _lang == 'FR' ? 'Mis à jour:' : 'Updated:'} ${_formatDate(price['updated_at']?.toString())}',
                                              style: TextStyle(fontSize: 10, color: textSecondary),
                                            ),
                                          ]),
                                      ],
                                    )),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(20)),
                                      child: Text('${price['price']} ${isAr ? 'د.ت' : 'DT'}', style: TextStyle(color: bg, fontWeight: FontWeight.w700, fontSize: 13)),
                                    ),
                                    if (_isAdmin) ...[
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () => _openEditPriceDialog(price, l, isDark),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(padding: const EdgeInsets.all(6), child: Icon(Icons.edit_outlined, color: cyan, size: 18)),
                                      ),
                                      InkWell(
                                        onTap: () => _deletePrice(price['id'], l),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(padding: const EdgeInsets.all(6), child: Icon(Icons.delete_outline, color: errorColor, size: 18)),
                                      ),
                                    ],
                                  ]),
                                )),
                                const SizedBox(height: 8),
                              ],
                            )),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
        floatingActionButton: _isAdmin && _prices.isNotEmpty
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