import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLang { en, ar }

class AppLangController extends ChangeNotifier {
  AppLang _lang = AppLang.en;
  bool _loaded = false;

  AppLang get lang => _lang;
  bool get isLoaded => _loaded;

  Locale get locale => _lang == AppLang.ar ? const Locale('ar') : const Locale('en');
  TextDirection get direction => _lang == AppLang.ar ? TextDirection.rtl : TextDirection.ltr;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_lang') ?? 'en';
    _lang = (code == 'ar') ? AppLang.ar : AppLang.en;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLang(AppLang value) async {
    _lang = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', value == AppLang.ar ? 'ar' : 'en');
  }

  Future<void> toggle() async {
    await setLang(_lang == AppLang.ar ? AppLang.en : AppLang.ar);
  }
}
