import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdManager {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  Function()? onAdLoaded;

  static String? get adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6913173137867777/5882620984';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6913173137867777/7718446831';
    } else {
      return null;
    }
  }

  NativeAd? get nativeAd => _nativeAd;
  bool get isAdLoaded => _isAdLoaded;

  void loadAd() {
    final adUnit = adUnitId;
    if (adUnit == null) {
      print('Native Ad Unit ID is not available for this platform.');
      return;
    }

    _nativeAd = NativeAd(
      adUnitId: adUnit,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('$NativeAd loaded.');
          _isAdLoaded = true;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          print('$NativeAd failed to load: $error');
          ad.dispose();
          _isAdLoaded = false;
        },
        onAdClicked: (ad) {},
        onAdImpression: (ad) {},
        onAdClosed: (ad) {},
        onAdOpened: (ad) {},
        onAdWillDismissScreen: (ad) {},
      ),
      request: const AdRequest(extras: {'npa': '1'}),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    )..load();
  }

  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
  }
}
