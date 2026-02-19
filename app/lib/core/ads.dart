import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob integration (SAFE defaults):
/// - Uses Google TEST ad unit IDs by default.
/// - Includes a simple frequency cap for interstitials.
/// - Banner widget you can attach to any page.
///
/// بعد ما تعمل Ad Units حقيقية في AdMob، هنستبدل IDs بسهولة.
class Ads {
  Ads._();

  static bool _initialized = false;

  // Frequency cap: show interstitial after every N actions
  static int _actionCount = 0;
  static const int interstitialEvery = 3;

  // Keep one loaded interstitial ready
  static InterstitialAd? _interstitial;
  static bool _loadingInterstitial = false;

  /// TEST Ad Unit IDs (official from Google).
  /// Replace later with your real IDs.
  static String get bannerUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static String get interstitialUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  /// Call once at app start.
  static Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _preloadInterstitial();
  }

  static void _preloadInterstitial() {
    if (_loadingInterstitial) return;
    _loadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              _preloadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _interstitial = null;
              _preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (err) {
          _loadingInterstitial = false;
          _interstitial = null;
          // Try again later (light backoff)
          Future.delayed(const Duration(seconds: 20), _preloadInterstitial);
        },
      ),
    );
  }

  /// Call when user performs a main action (calculate/compare/etc).
  /// It will show an interstitial occasionally (not annoying).
  static Future<void> maybeShowInterstitial(BuildContext context) async {
    if (!_initialized) return;

    _actionCount += 1;
    if (_actionCount % interstitialEvery != 0) return;

    final ad = _interstitial;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }

    // Avoid showing if app is not active/route not ready
    final mounted = context.mounted;
    if (!mounted) return;

    try {
      ad.show();
      _interstitial = null; // will be reloaded via callback
    } catch (_) {
      _interstitial = null;
      _preloadInterstitial();
    }
  }
}

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: Ads.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _ad = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox(height: 0);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: _ad!.size.height.toDouble(),
        width: _ad!.size.width.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
