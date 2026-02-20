import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  // ✅ منطق “ذكي” لتقليل الإزعاج
  int _actionCount = 0; // عدد ضغطات "احسب"
  DateTime _lastInterstitialShown = DateTime.fromMillisecondsSinceEpoch(0);

  // إعدادات
  static const int showEveryActions = 6; // يظهر كل 6 عمليات
  static const Duration cooldown = Duration(seconds: 90);

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _preloadInterstitial();
  }

  // يستدعى عند الضغط على "احسب"
  Future<void> maybeShowInterstitial() async {
    if (!_initialized) return;

    _actionCount++;

    final now = DateTime.now();
    final cooldownOk = now.difference(_lastInterstitialShown) >= cooldown;
    final countOk = (_actionCount % showEveryActions) == 0;

    if (!countOk || !cooldownOk) {
      // حمّل إعلان احتياطيًا
      _preloadInterstitial();
      return;
    }

    if (_interstitial == null) {
      _preloadInterstitial();
      return;
    }

    final ad = _interstitial!;
    _interstitial = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _preloadInterstitial();
      },
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      ad.show();
      _lastInterstitialShown = DateTime.now();
    } catch (_) {
      // تجاهل
      _preloadInterstitial();
    }
  }

  void _preloadInterstitial() {
    if (!_initialized) return;
    if (_loadingInterstitial) return;
    if (_interstitial != null) return;

    _loadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (err) {
          _loadingInterstitial = false;
          _interstitial = null;

          // في بعض الحسابات الجديدة ممكن يبقى "no fill" مؤقت
          if (!kReleaseMode) {
            // ignore: avoid_print
            print('Interstitial failed: ${err.code} ${err.message}');
          }
        },
      ),
    );
  }
}
