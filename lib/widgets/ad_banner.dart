import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdBanner extends StatefulWidget {
  // Callback to notify the parent widget when an ad is loaded.
  final Function(BannerAd ad)? onAdLoaded;

  const AdBanner({super.key, this.onAdLoaded});

  @override
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Your production ad unit ID
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-6913173137867777/7421428393' // Android Production ID
      : 'ca-app-pub-6913173137867777/2855979927'; // iOS Production ID (check if this is correct, often test ID is used for iOS dev)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  void _loadAd() async {
    // Dispose the old ad if it exists
    _bannerAd?.dispose();
    _bannerAd = null;
    if (mounted) {
      setState(() {
        _isLoaded = false;
      });
    }

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debugPrint('Unable to get height of anchored adaptive banner.');
      // Retry after a delay
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) {
          _loadAd();
        }
      });
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(extras: {'npa': '1'}),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$BannerAd loaded.');
          final bannerAd = ad as BannerAd;
          setState(() {
            _bannerAd = bannerAd;
            _isLoaded = true;
          });
          // Notify the parent widget
          widget.onAdLoaded?.call(bannerAd);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          // Retry after a delay
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted) {
              _loadAd();
            }
          });
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null && _isLoaded) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Return an empty container while the ad is loading
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
