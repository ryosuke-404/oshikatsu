import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../utils/custom_page_route.dart';
import 'management/billing_management_screen.dart';
import 'management/goods_management_screen.dart';
import 'management/mission_management_screen.dart';
import 'management/add_billing_screen.dart';
import 'management/add_goods_screen.dart';
import 'management/add_mission_screen.dart';

import 'package:oshikatu/widgets/animated_gradient_app_bar.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (mounted && _tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _navigateAndRefresh(Widget screen) async {
    final result =
        await Navigator.of(context).push(CustomPageRoute<bool>(child: screen));
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Widget? _buildFab() {
    switch (_currentIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: () => _navigateAndRefresh(const AddBillingScreen()),
          tooltip: 'add_billing_history'.tr(),
          child: const Icon(Icons.add),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () => _navigateAndRefresh(const AddGoodsScreen()),
          tooltip: 'add_goods'.tr(),
          child: const Icon(Icons.add),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => _navigateAndRefresh(const AddMissionScreen()),
          tooltip: 'add_mission'.tr(),
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isNeonMode = themeProvider.isNeonMode;

    return Scaffold(
      backgroundColor:
          isNeonMode ? Colors.black : Theme.of(context).canvasColor,
      appBar: AnimatedGradientAppBar(
        title: null,
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
                icon: const Icon(Icons.payment),
                text: 'billing_management'.tr()),
            Tab(
                icon: const Icon(Icons.collections),
                text: 'goods_management'.tr()),
            Tab(icon: const Icon(Icons.track_changes), text: 'mission'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          BillingManagementScreen(),
          GoodsManagementScreen(),
          MissionManagementScreen(),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }
}
