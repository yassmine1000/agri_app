import 'package:flutter/material.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'package:smart_agri_app/service/crop_service.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../crop_library_tab.dart';
import '../planning_tab.dart';

class FarmerScreen extends StatefulWidget {
  final bool isDarkMode;
  const FarmerScreen({super.key, this.isDarkMode = true});

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
    _loadData();
  }

  Future<void> _loadData() async {
    final savedToken = await PrefHelper.getToken();
    if (!mounted) return;
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
    final l = AppLocalizations.of(context)!;
    final isDark = widget.isDarkMode;
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: token == null
          ? Center(child: CircularProgressIndicator(color: primary))
          : Column(children: [
              Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 2,
                  dividerColor: Colors.transparent,
                  labelColor: primary,
                  unselectedLabelColor: textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: [Tab(text: l.cropLibrary), Tab(text: l.planning)],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CropLibraryTab(cropService: _cropService, isDarkMode: isDark),
                    PlanningTab(cropService: _cropService, isDarkMode: isDark),
                  ],
                ),
              ),
            ]),
    );
  }
}