import 'package:flutter/foundation.dart';

class AdIds {
  AdIds._();

  // ✅ Your AdMob App ID (Android) — موجود في AndroidManifest
  static const String androidAppId = 'ca-app-pub-1243924347643904~8738724931';

  // ✅ Banner
  static String get banner => kReleaseMode
      ? 'ca-app-pub-1243924347643904/5595345403' // REAL
      : 'ca-app-pub-3940256099942544/6300978111'; // TEST

  // ✅ Interstitial
  static String get interstitial => kReleaseMode
      ? 'ca-app-pub-1243924347643904/9597475578' // REAL
      : 'ca-app-pub-3940256099942544/1033173712'; // TEST
}
