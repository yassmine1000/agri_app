import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/local/pref_helper.dart';

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
    setState(() {
      _isAdmin = user?['role'] == 'admin';
    });
  }

  Future<void> _loadPrices() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await PrefHelper.getToken();
      final response = await _dio.get(
        '${Config.baseUrl}/prices',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      setState(() {
        _prices = response.data['data'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les prix';
        _loading = false;
      });
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Ajouter un prix',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: plantCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la plante',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Légumes', 'Fruits', 'Céréales', 'Herbes']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Prix (DT)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unité',
                    border: OutlineInputBorder(),
                  ),
                  items: ['kg', 'g', 'pièce', 'litre', 'botte']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedUnit = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                if (plantCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                try {
                  final token = await PrefHelper.getToken();
                  await _dio.post(
                    '${Config.baseUrl}/prices',
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
                    const SnackBar(
                      content: Text('Prix ajouté avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de l\'ajout'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePrice(int id) async {
    try {
      final token = await PrefHelper.getToken();
      await _dio.delete(
        '${Config.baseUrl}/prices/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      _loadPrices();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prix supprimé'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, List<dynamic>> _groupByCategory() {
    final Map<String, List<dynamic>> grouped = {};
    for (var price in _prices) {
      final cat = price['category'] ?? 'Autre';
      grouped.putIfAbsent(cat, () => []).add(price);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPrices,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _prices.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store_outlined, size: 60, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'Aucun prix disponible aujourd\'hui',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPrices,
                      color: Colors.green,
                      child: ListView(
                        children: [
                          // Header date
                          Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Prix du ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${_prices.length} produits',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                          // Groupes par catégorie
                          ..._groupByCategory().entries.map(
                            (entry) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                ...entry.value.map(
                                  (price) => Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green.shade100,
                                        child: Text(
                                          price['plant_name'][0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        price['plant_name'],
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'par ${price['unit']}',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '${price['price']} DT',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (_isAdmin)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.redAccent,
                                                size: 20,
                                              ),
                                              onPressed: () => _deletePrice(price['id']),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _openAddPriceDialog,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Ajouter prix', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}