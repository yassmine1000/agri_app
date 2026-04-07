// ============================================================
// farmer_screen.dart → lib/screens/bottom_screens/farmer_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'package:smart_agri_app/service/crop_service.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../crop_library_tab.dart';
import '../planning_tab.dart';

class FarmerScreen extends StatefulWidget {
  const FarmerScreen({super.key});

  @override
  State<FarmerScreen> createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CropService _cropService;
  String? token;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadToken();
  }

  Future<void> _loadToken() async {
    final savedToken = await PrefHelper.getToken();
    setState(() {
      token = savedToken;
      _cropService = CropService(authToken: token!);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: token == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 2,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: const [Tab(text: 'Crop Library'), Tab(text: 'Planning')],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      CropLibraryTab(cropService: _cropService),
                      PlanningTab(cropService: _cropService),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}