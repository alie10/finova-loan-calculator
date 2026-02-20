// app/lib/core/app_lang.dart
import 'package:flutter/material.dart';

enum AppLang { ar, en }

extension AppLangX on AppLang {
  Locale get locale => this == AppLang.ar ? const Locale('ar') : const Locale('en');
  bool get isArabic => this == AppLang.ar;
}
