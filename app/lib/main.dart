import 'package:flutter/material.dart';
import 'core/app.dart';

import 'package:flutter/material.dart';
import 'core/ads/ad_service.dart';
// باقي imports…

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.instance.initialize(); // ✅
  runApp(const MyApp());
}
