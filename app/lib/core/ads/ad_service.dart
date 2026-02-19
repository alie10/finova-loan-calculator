import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  // منع إزعاج المستخدم: أقل مدة بين الإعلانات البينية
  DateTime? _lastInterstitialShownAt;
  static const Duration _minGapBetweenInterstitial = Duration(minutes: 2);

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;

    // حضّر إعلان بيني من بدري
    _loadInterstitial();
  }

  /// Banner Ad factory
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
  }) {
    return BannerAd(
      adUnitId: AdIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    );
  }

  void _loadInterstitial() {
    if (_loadingInterstitial) return;
    _loadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (err) {
          _loadingInterstitial = false;

          // إعادة محاولة بعد شوية
          Timer(const Duration(seconds: 20), () {
            _loadInterstitial();
          });
        },
      ),
    );
  }

  /// عرض إعلان بيني "بهدوء" (بدون إزعاج): لو لسه ما جهّزش أو الوقت قريب، مش هيعرض
  Future<bool> showInterstitialIfAllowed() async {
    if (!_initialized) return false;

    // لو اتعرض قريب، بلاش
    final last = _lastInterstitialShownAt;
    if (last != null && DateTime.now().difference(last) < _minGapBetweenInterstitial) {
      return false;
    }

    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return false;
    }

    _lastInterstitialShownAt = DateTime.now();
    await ad.show();
    _interstitial = null;
    return true;
  }
}
