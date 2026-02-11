import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:minty/core/services/ad_helper.dart';

class FullscreenAdService {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _isAdLoaded = false;
                  // Reload immediately after dismissal for next time
                  loadAd();
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  _isAdLoaded = false;
                  loadAd();
                },
              );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Shows the interstitial ad if available.
  /// Calls [onAdDismissed] when the ad is closed or if it fails/ isn't ready.
  void showAdIfAvailable(VoidCallback onAdDismissed) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          onAdDismissed();
          loadAd(); // Preload the next one
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAdLoaded = false;
          onAdDismissed(); // Proceed anyway
          loadAd();
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint('Ad not ready, proceeding without showing ad.');
      onAdDismissed();
      loadAd(); // Try to load again
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
