import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppStartupNativeAdView extends StatelessWidget {
  final NativeAd nativeAd;

  const AppStartupNativeAdView({super.key, required this.nativeAd});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 320, // minWidth
        minHeight: 320, // minHeight
        maxWidth: 400,
        maxHeight: 400,
      ),
      child: AdWidget(ad: nativeAd),
    );
  }
}
