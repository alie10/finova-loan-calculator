import 'package:flutter/foundation.dart';

class AdIds {
  // Your real AdMob IDs (Release)
  static const String androidAppId = 'ca-app-pub-1243924347643904~8738724931';
  static const String androidBannerId = 'ca-app-pub-1243924347643904/5842757415';
  static const String androidInterstitialId = 'ca-app-pub-1243924347643904/3897461798';

  // Google test IDs (Debug)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  static String bannerId() => kReleaseMode ? androidBannerId : _testBannerId;
  static String interstitialId() =>
      kReleaseMode ? androidInterstitialId : _testInterstitialId;
}
