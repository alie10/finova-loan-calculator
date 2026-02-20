import 'package:flutter/foundation.dart';

class AdIds {
  // Google TEST IDs (must show quickly if integration is correct)
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';

  // Your REAL IDs
  static const String _realBanner = 'ca-app-pub-1243924347643904/5595345403';
  static const String _realInterstitial = 'ca-app-pub-1243924347643904/9597475578';

  // Debug/Test -> Test ads, Release -> Real ads
  static String get banner => kReleaseMode ? _realBanner : _testBanner;
  static String get interstitial => kReleaseMode ? _realInterstitial : _testInterstitial;
}
