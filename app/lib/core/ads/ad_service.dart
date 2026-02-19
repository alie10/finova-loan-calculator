import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  InterstitialAd? _interstitial;
  bool _isLoading = false;

  // تحكم في الإزعاج: إعلان بيني كل كام عملية "حساب"؟
  int _actionCount = 0;
  final int showEvery = 3; // مثال: كل 3 مرات Calculate

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await preloadInterstitial();
  }

  Future<void> preloadInterstitial() async {
    if (_isLoading) return;
    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: AdIds.interstitialId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _isLoading = false;

          _interstitial?.setImmersiveMode(true);
          _interstitial?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              // حضّر اللي بعده
              unawaited(preloadInterstitial());
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              unawaited(preloadInterstitial());
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitial = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// استدعِ دي بعد ما المستخدم يضغط Calculate
  /// عشان الإعلان يظهر "بعد" النتيجة، مش قبلها.
  Future<void> maybeShowInterstitial() async {
    _actionCount++;

    // تقليل الإزعاج: ما نعرضش كل مرة
    if (_actionCount % showEvery != 0) return;

    final ad = _interstitial;
    if (ad == null) {
      // لو مش جاهز، حضّره
      unawaited(preloadInterstitial());
      return;
    }

    await ad.show();
    // بعد show الـ callbacks هتتولى إعادة التحميل
  }
}
