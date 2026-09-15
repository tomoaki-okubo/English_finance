import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  // Production Ad Unit IDs (TODO: Replace with actual ad unit IDs when ready)
  static const String _prodBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _prodAppOpenAdUnitId = 'ca-app-pub-3940256099942544/9257395921';
  static const String _prodInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // Test Ad Unit IDs (used as fallback in debug mode for safety)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testAppOpenAdUnitId = 'ca-app-pub-3940256099942544/9257395921';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  String get bannerAdUnitId => kDebugMode ? _testBannerAdUnitId : _prodBannerAdUnitId;
  String get appOpenAdUnitId => kDebugMode ? _testAppOpenAdUnitId : _prodAppOpenAdUnitId;
  String get interstitialAdUnitId => kDebugMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;

  bool _isInitialized = false;
  bool _isShowingInterstitial = false;
  bool _isShowingAppOpenAd = false;
  DateTime? _lastInterstitialShownTime;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  /// Show App Open Ad on startup.
  /// Executes [onAdDismissed] when ad closes or if loading fails.
  void showAppOpenAd({required VoidCallback onAdDismissed}) {
    if (!_isInitialized || _isShowingAppOpenAd) {
      onAdDismissed();
      return;
    }

    _isShowingAppOpenAd = true;

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isShowingAppOpenAd = false;
              onAdDismissed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isShowingAppOpenAd = false;
              onAdDismissed();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          _isShowingAppOpenAd = false;
          onAdDismissed();
        },
      ),
    );
  }

  /// Load and show Interstitial Ad (for drill/chat completion or exit).
  /// Prevents double-triggering when buttons are tapped repeatedly.
  void showInterstitialAd({required VoidCallback onAdDismissed}) {
    if (!_isInitialized || _isShowingInterstitial) {
      onAdDismissed();
      return;
    }

    // Cooldown check: Prevent ads from showing within 3 seconds of previous ad
    final now = DateTime.now();
    if (_lastInterstitialShownTime != null &&
        now.difference(_lastInterstitialShownTime!).inSeconds < 3) {
      onAdDismissed();
      return;
    }

    _isShowingInterstitial = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isShowingInterstitial = false;
              _lastInterstitialShownTime = DateTime.now();
              onAdDismissed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isShowingInterstitial = false;
              onAdDismissed();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          _isShowingInterstitial = false;
          onAdDismissed();
        },
      ),
    );
  }
}
