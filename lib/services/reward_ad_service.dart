import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

// Enum to represent the type of reward
enum RewardType { adFree, experienceBoost, customTag }

class RewardAdService {
  static final RewardAdService _instance = RewardAdService._internal();
  factory RewardAdService() => _instance;
  RewardAdService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  // Use test ad unit IDs
  static final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-6913173137867777/2234740773'
      : 'ca-app-pub-6913173137867777/9602929058';

  void loadAd() {
    if (_isAdLoaded) return;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(extras: {'npa': '1'}),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _isAdLoaded = false;
          _rewardedAd = null;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 60), () => loadAd());
        },
      ),
    );
  }

  void showAd({
    required BuildContext context,
    required RewardType rewardType,
    required Function onRewardEarned,
  }) {
    if (_rewardedAd == null) {
      debugPrint('Warning: Rewarded ad is not loaded yet.');
      // Optionally, show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('広告の準備ができていません。少し時間をおいてお試しください。')),
      );
      // Try to load an ad for next time
      loadAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _isAdLoaded = false;
        // Load a new ad
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _isAdLoaded = false;
        // Load a new ad
        loadAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint(
            'User earned reward: type=${reward.type}, amount=${reward.amount}');
        // Call the callback with the specific reward type
        onRewardEarned(rewardType);
      },
    );
    _rewardedAd = null;
    _isAdLoaded = false;
  }
}
