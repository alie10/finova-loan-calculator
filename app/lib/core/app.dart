import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_lang.dart';

// Pages
import '../features/loan/loan_page.dart';
import '../features/compare/compare_page.dart';
import '../features/savings/savings_page.dart';
import '../features/settings/settings_page.dart';

// Banner widget
import '../widgets/ad_banner.dart';

const String _kPrefLangCode = 'finova_lang_code';

class FinovaController {
  FinovaController(this._getLang, this._toggle, this._setLang);

  final AppLang Function() _getLang;
  final Future<void> Function() _toggle;
  final Future<void> Function(AppLang lang) _setLang;

  AppLang get lang => _getLang();
  Future<void> toggle() => _toggle();
  Future<void> setLang(AppLang lang) => _setLang(lang);
}

class FinovaApp extends StatefulWidget {
  const FinovaApp({super.key});

  static FinovaController of(BuildContext context) {
    final state = context.findAncestorStateOfType<_FinovaAppState>();
    if (state == null) {
      return FinovaController(
        () => AppLang.ar,
        () async {},
        (_) async {},
      );
    }
    return state.controller;
  }

  @override
  State<FinovaApp> createState() => _FinovaAppState();
}

class _FinovaAppState extends State<FinovaApp> {
  Locale _locale = const Locale('ar');

  late final FinovaController controller = FinovaController(
    () => _locale.languageCode == 'ar' ? AppLang.ar : AppLang.en,
    _toggleLang,
    _setLang,
  );

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kPrefLangCode) ?? 'ar';
    setState(() => _locale = Locale(code));
  }

  Future<void> _setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefLangCode, locale.languageCode);
    setState(() => _locale = locale);
  }

  Future<void> _setLang(AppLang lang) async {
    await _setLocale(Locale(lang == AppLang.ar ? 'ar' : 'en'));
  }

  Future<void> _toggleLang() async {
    final next = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await _setLocale(next);
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFF3B82F6),
      scaffoldBackgroundColor: const Color(0xFFF7F7FB),
    );

    final theme = base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFF3B82F6), width: 1.6),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finova',
      theme: theme,
      locale: _locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isArabic = FinovaApp.of(context).lang == AppLang.ar;

    final pages = const [
      LoanPage(),
      ComparePage(),
      SavingsPage(),
      SettingsPage(),
    ];

    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.calculate_outlined),
        label: isArabic ? 'القرض' : 'Loan',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.compare_arrows_outlined),
        label: isArabic ? 'المقارنة' : 'Compare',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.savings_outlined),
        label: isArabic ? 'الادخار' : 'Savings',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings_outlined),
        label: isArabic ? 'الإعدادات' : 'Settings',
      ),
    ];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _index,
            children: pages,
          ),
        ),
        // ✅ Tabs + Banner تحتهم (مضمون الظهور)
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                color: Colors.white,
              ),
              child: BottomNavigationBar(
                currentIndex: _index,
                onTap: (v) => setState(() => _index = v),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFF3B82F6),
                unselectedItemColor: const Color(0xFF6B7280),
                items: items,
              ),
            ),
            const AdBanner(),
          ],
        ),
      ),
    );
  }
}
