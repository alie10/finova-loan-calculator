import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static const bool useTestAds = false;

  static const String androidAppId =
      'ca-app-pub-1243924347643904~8738724931';

  static const String androidBannerAli =
      'ca-app-pub-1243924347643904/5595345403';

  static const String androidInterstitial =
      'ca-app-pub-1243924347643904/XXXXXXXXXX'; // ← حط ID البيني هنا

  static const String testBanner =
      'ca-app-pub-3940256099942544/6300978111';

  static const String testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  String bannerUnitId() {
    if (useTestAds) return testBanner;
    return androidBannerAli;
  }

  String interstitialUnitId() {
    if (useTestAds) return testInterstitial;
    return androidInterstitial;
  }

  AdRequest request() => const AdRequest();

  void _loadInterstitial() {
    if (_loadingInterstitial) return;
    _loadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: interstitialUnitId(),
      request: request(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[Interstitial] Loaded');
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[Interstitial] Failed: $error');
          _loadingInterstitial = false;
        },
      ),
    );
  }

  void maybeShowInterstitial() {
    if (_interstitial == null) {
      _loadInterstitial();
      return;
    }

    _interstitial!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
      },
    );

    _interstitial!.show();
    _interstitial = null;
  }
}
