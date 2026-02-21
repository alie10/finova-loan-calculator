import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// ✅ خليها true أثناء التطوير عشان تتأكد إن كل حاجة شغالة 100%
  /// ولما ترفع إصدار نهائي على المتجر خليها false.
  static const bool useTestAds = false;

  // ====== IDs (Android) ======
  // App ID (Android) — لازم يكون في AndroidManifest كمان
  static const String androidAppId = 'ca-app-pub-1243924347643904~8738724931';

  // Banner Ad Unit IDs (Android)
  // عندك بانرين: ali و Quran
  static const String androidBannerAli = 'ca-app-pub-1243924347643904/5595345403';
  static const String androidBannerQuran = 'ca-app-pub-1243924347643904/9597475578';

  // ✅ Test Banner Unit (Google الرسمي) — بيظهر دائمًا
  static const String testBanner = 'ca-app-pub-3940256099942544/6300978111';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // تهيئة SDK
    final status = await MobileAds.instance.initialize();

    debugPrint('[AdService] MobileAds initialized.');
    debugPrint('[AdService] Adapter statuses: ${status.adapterStatuses.keys.join(", ")}');

    // (اختياري) أثناء التطوير تقدر تضيف جهازك كـ test device عشان تقلل مشاكل العرض
    // ضع هنا deviceId الحقيقي من اللوج لو احتجنا.
    // MobileAds.instance.updateRequestConfiguration(
    //   RequestConfiguration(testDeviceIds: ['YOUR_DEVICE_ID']),
    // );
  }

  /// يرجع Ad Unit ID المناسب للبانر
  String bannerUnitId({bool preferAli = true}) {
    if (useTestAds) return testBanner;

    if (!Platform.isAndroid) {
      // لو أضفت iOS بعدين هنحط IDs هنا
      return testBanner;
    }

    return preferAli ? androidBannerAli : androidBannerQuran;
  }

  AdRequest request() {
    return const AdRequest(
      // Keywords اختيارية
      // keywords: ['finance', 'calculator', 'loan'],
      nonPersonalizedAds: false,
    );
  }
}
