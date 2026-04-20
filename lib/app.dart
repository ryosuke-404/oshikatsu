import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'package:provider/provider.dart';
import 'package:oshikatu/providers/ad_provider.dart';
import 'models/oshi_model.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/record_screen.dart';
import 'screens/management_screen.dart';
import 'screens/settings_screen.dart';
import 'services/native_ad_manager.dart';
import 'widgets/app_startup_native_ad_view.dart';

class App extends StatefulWidget {
  final int initialIndex;

  const App({super.key, this.initialIndex = 0});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late int _selectedIndex;
  late final NativeAdManager _nativeAdManager;
  bool _isShowingAd = false;
  bool _canShowAd = false;
  AppLifecycleState? _appLifecycleState;
  bool _adShownOnThisResume = false; // Flag to show ad only once per resume

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _nativeAdManager = NativeAdManager();
    _nativeAdManager.onAdLoaded = () {
      if (mounted) {
        setState(() {
          _canShowAd = true;
        });
      }
    };
    _nativeAdManager.loadAd();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nativeAdManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Reset the flag when the app goes to the background.
      _adShownOnThisResume = false;
    } else if (state == AppLifecycleState.resumed) {
      // Show ad on resume only if it's ready and not already shown in this cycle.
      if (_canShowAd && !_adShownOnThisResume) {
        _showNativeAd();
      }
    }
  }

  void _showNativeAd() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.checkAdStatus(); // Make sure the status is up-to-date
    if (!adProvider.shouldShowAds) {
      debugPrint("Ad-free period is active. Skipping native ad.");
      return;
    }

    if (_isShowingAd || !_canShowAd) return;

    final settingsBox = Hive.box('settings');
    int adCount = settingsBox.get('app_open_ad_count', defaultValue: 0);
    adCount++;
    settingsBox.put('app_open_ad_count', adCount);

    if (adCount <= 10) {
      debugPrint("Skipping native ad: count is $adCount (<= 10)");
      return;
    }
    
    // 最初の10回をスキップした後、3回に1回表示するには (adCount - 10) % 3 == 0 や adCount % 3 == 0 を使います
    if (adCount % 3 != 0) {
      debugPrint("Skipping native ad: count is $adCount (not a multiple of 3)");
      return;
    }

    if (_nativeAdManager.isAdLoaded && _nativeAdManager.nativeAd != null) {
      _isShowingAd = true;
      setState(() {
        _canShowAd = false; // Consume the ad
        _adShownOnThisResume = true; // Mark as shown for this resume cycle
      });

      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppStartupNativeAdView(nativeAd: _nativeAdManager.nativeAd!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(160, 56), // さらにサイズアップ
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28), // 角を丸くする
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20, // 文字もさらに大きく
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('close_ad'.tr()),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((_) {
        _isShowingAd = false;
        _nativeAdManager.dispose(); // Dispose the used ad
        _nativeAdManager.loadAd(); // Load the next ad
      });
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScheduleScreen(),
    const RecordScreen(),
    const ManagementScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return ValueListenableBuilder<Box<Oshi>>(
      valueListenable: Hive.box<Oshi>('oshis').listenable(),
      builder: (context, box, _) {
        Oshi? saiOshi;
        try {
          saiOshi =
              box.values.firstWhere((oshi) => oshi.level == OshiLevel.saiOshi);
        } catch (e) {
          saiOshi = null;
        }

        final Color selectedColor = saiOshi?.mainColorValue != null
            ? Color(saiOshi!.mainColorValue!)
            : const Color(0xFFD9C2F0); // ラベンダー色

        return UpgradeAlert(
          child: Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: const Icon(Icons.home), label: tr('home_title')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.calendar_today),
                    label: tr('schedule_title')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.edit), label: tr('record_title')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.inventory),
                    label: tr('management_title')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.star), label: tr('oshi_title')),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: selectedColor, // 動的に取得した色を設定
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
            ),
          ),
        );
      },
    );
  }
}
