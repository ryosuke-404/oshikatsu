import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AdProvider with ChangeNotifier {
  final Box _settingsBox = Hive.box('settings');
  bool _shouldShowAds = true;

  bool get shouldShowAds => _shouldShowAds;

  AdProvider() {
    checkAdStatus();
  }

  void checkAdStatus() {
    final adFreeUntilString = _settingsBox.get('ad_free_until');
    if (adFreeUntilString != null) {
      try {
        final adFreeUntil = DateTime.parse(adFreeUntilString);
        if (adFreeUntil.isAfter(DateTime.now())) {
          _shouldShowAds = false;
        } else {
          _shouldShowAds = true;
          // Clean up expired entry
          _settingsBox.delete('ad_free_until');
        }
      } catch (e) {
        _shouldShowAds = true;
      }
    } else {
      _shouldShowAds = true;
    }
    notifyListeners();
  }
}
