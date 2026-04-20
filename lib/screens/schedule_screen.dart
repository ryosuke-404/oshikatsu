import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:oshikatu/widgets/ad_banner.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';
import 'schedule/calendar_view.dart';
import 'schedule/itinerary_view.dart';
import 'schedule/edit_event_screen.dart';
import 'schedule/add_itinerary_screen.dart';
import '../utils/custom_page_route.dart';

import 'package:oshikatu/widgets/animated_gradient_app_bar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentIndex = 0;
  double _adBannerHeight = 0;
  final GlobalKey<CalendarViewState> _calendarKey =
      GlobalKey<CalendarViewState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted && _tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
          // When switching to the Calendar tab, reset ad height.
          if (_currentIndex == 0) {
            _adBannerHeight = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget? _buildFab() {
    switch (_currentIndex) {
      case 0:
        return FloatingActionButton(
            onPressed: () {
              final selectedDate = _calendarKey.currentState?.selectedDay;
              Navigator.of(context).push(CustomPageRoute(
                  child:
                      EditEventScreen(event: null, initialDate: selectedDate)));
            },
            tooltip: 'add_new_event'.tr(),
            child: const Icon(Icons.add));
      case 1:
        return FloatingActionButton(
            onPressed: () => Navigator.of(context)
                .push(CustomPageRoute(child: const AddItineraryScreen())),
            tooltip: 'create_new_itinerary'.tr(),
            child: const Icon(Icons.add));
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);

    return Scaffold(
      appBar: AnimatedGradientAppBar(
        title: null,
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(icon: const Icon(Icons.calendar_month), text: 'calendar'.tr()),
            Tab(icon: const Icon(Icons.luggage), text: 'expedition'.tr()),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                CalendarView(key: _calendarKey),
                const ItineraryView(),
              ],
            ),
          ),
          Visibility(
            visible: _currentIndex != 0 &&
                adProvider.shouldShowAds, // Updated condition
            child: AdBanner(
              onAdLoaded: (ad) {
                if (mounted) {
                  setState(() {
                    if (_currentIndex != 0) {
                      _adBannerHeight = ad.size.height.toDouble();
                    }
                  });
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: adProvider.shouldShowAds ? _adBannerHeight : 0),
        child: _buildFab(),
      ),
    );
  }
}
