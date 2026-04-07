import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

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
    setState(() => _isAdmin = user?['role'] == 'admin');
  }

  Future<void> _loadPrices() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await PrefHelper.getToken();
      final response = await _dio.get(
        '${Config.baseUrl}/prices',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      setState(() { _prices = response.data['data'] ?? []; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Unable to load prices'; _loading = false; });
    }
  }

  void _openAddPriceDialog() {
    final plantCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCategory = 'Légumes';
    String selectedUnit = 'kg';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text('Add Price', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(plantCtrl, 'Plant name'),
                const SizedBox(height: 12),
                _dialogDropdown(
                  value: selectedCategory,
                  label: 'Category',
                  items: ['Légumes', 'Fruits', 'Céréales', 'Herbes'],
                  onChanged: (v) => setDialogState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 12),
                _dialogField(priceCtrl, 'Price (DT)', isNumber: true),
                const SizedBox(height: 12),
                _dialogDropdown(
                  value: selectedUnit,
                  label: 'Unit',
                  items: ['kg', 'g', 'pièce', 'litre', 'botte'],
                  onChanged: (v) => setDialogState(() => selectedUnit = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.cyan]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (plantCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                  try {
                    final token = await PrefHelper.getToken();
                    await _dio.post('${Config.baseUrl}/prices',
                      data: {
                        'plant_name': plantCtrl.text,
                        'category': selectedCategory,
                        'price': double.parse(priceCtrl.text),
                        'unit': selectedUnit,
                      },
                      options: Options(headers: {'Authorization': 'Bearer $token'}),
                    );
                    Navigator.pop(ctx);
                    _loadPrices();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Price added successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error adding price')),
                    );
                  }
                },
                child: const Text('Add', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : null,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }

  Widget _dialogDropdown({required String value, required String label, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.surfaceAlt,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _deletePrice(int id) async {
    try {
      final token = await PrefHelper.getToken();
      await _dio.delete('${Config.baseUrl}/prices/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      _loadPrices();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting price')),
      );
    }
  }

  Map<String, List<dynamic>> _groupByCategory() {
    final Map<String, List<dynamic>> grouped = {};
    for (var price in _prices) {
      grouped.putIfAbsent(price['category'] ?? 'Other', () => []).add(price);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPrices,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('Retry', style: TextStyle(color: AppColors.background)),
                      ),
                    ],
                  ),
                )
              : _prices.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront_outlined, size: 60, color: AppColors.textSecondary),
                          SizedBox(height: 12),
                          Text('No prices available today', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPrices,
                      color: AppColors.primary,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Header date
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Today — ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
                                ),
                                const Spacer(),
                                Text('${_prices.length} products',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          ..._groupByCategory().entries.map((entry) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  entry.key.toUpperCase(),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.cyan, letterSpacing: 1.5),
                                ),
                              ),
                              ...entry.value.map((price) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          price['plant_name'][0].toUpperCase(),
                                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(price['plant_name'],
                                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
                                          Text('per ${price['unit']}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.cyan]),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${price['price']} DT',
                                        style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                    ),
                                    if (_isAdmin)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                        onPressed: () => _deletePrice(price['id']),
                                      ),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 8),
                            ],
                          )),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
      floatingActionButton: _isAdmin
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.cyan]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: FloatingActionButton.extended(
                onPressed: _openAddPriceDialog,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.add, color: AppColors.background),
                label: const Text('Add Price', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w700)),
              ),
            )
          : null,
    );
  }
}