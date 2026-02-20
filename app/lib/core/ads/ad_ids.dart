import 'package:flutter/foundation.dart';

class AdIds {
  AdIds._();

  // ✅ Android AdMob App ID (الذي يحتوي على ~)
  static const String androidAppId = 'ca-app-pub-1243924347643904~8738724931';

  // ✅ Banner (Release = الحقيقي / Debug = test)
  static const String banner = kReleaseMode
      ? 'ca-app-pub-1243924347643904/5595345403'
      : 'ca-app-pub-3940256099942544/6300978111';

  // ✅ Interstitial (Release = الحقيقي / Debug = test)
  static const String interstitial = kReleaseMode
      ? 'ca-app-pub-1243924347643904/9597475578'
      : 'ca-app-pub-3940256099942544/1033173712';
}
