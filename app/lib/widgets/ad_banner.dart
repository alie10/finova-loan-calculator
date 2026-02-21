import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/ads/ad_service.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({
    super.key,
    this.preferAli = true,
    this.height = 60,
  });

  final bool preferAli;
  final double height;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await AdService.instance.initialize();

      final unitId = AdService.instance.bannerUnitId(preferAli: widget.preferAli);

      final ad = BannerAd(
        adUnitId: unitId,
        size: AdSize.banner,
        request: AdService.instance.request(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('[AdBanner] Loaded: ${(ad as BannerAd).adUnitId}');
            if (!mounted) return;
            setState(() {
              _ad = ad as BannerAd;
              _loaded = true;
              _lastError = null;
            });
          },
          onAdFailedToLoad: (ad, err) {
            debugPrint('[AdBanner] Failed: ${ad.adUnitId} => $err');
            ad.dispose();
            if (!mounted) return;
            setState(() {
              _ad = null;
              _loaded = false;
              _lastError = err.message;
            });
          },
          onAdImpression: (ad) {
            debugPrint('[AdBanner] Impression: ${ad.adUnitId}');
          },
        ),
      );

      await ad.load();
    } catch (e) {
      debugPrint('[AdBanner] Exception: $e');
      if (!mounted) return;
      setState(() {
        _ad = null;
        _loaded = false;
        _lastError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // أثناء الإنتاج: لو ما اتحملش، نخفي المساحة عشان ما نزعّج المستخدم
    if (!_loaded || _ad == null) {
      // لو عايز تظهر debug للمراجعة فقط:
      // return Text('Ad not loaded: ${_lastError ?? ''}');
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: Center(
        child: SizedBox(
          width: _ad!.size.width.toDouble(),
          height: _ad!.size.height.toDouble(),
          child: AdWidget(ad: _ad!),
        ),
      ),
    );
  }
}
