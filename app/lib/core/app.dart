import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Pages
import '../features/loan/loan_page.dart';
import '../features/compare/compare_page.dart';
import '../features/savings/savings_page.dart';
import '../features/settings/settings_page.dart';

const String _kPrefLangCode = 'finova_lang_code';

/// Call this from anywhere to change app locale.
Future<void> setAppLocale(BuildContext context, Locale locale) async {
  final state = context.findAncestorStateOfType<_FinovaAppState>();
  if (state == null) return;

  await state.setLocale(locale);
}

class FinovaApp extends StatefulWidget {
  const FinovaApp({super.key});

  @override
  State<FinovaApp> createState() => _FinovaAppState();
}

class _FinovaAppState extends State<FinovaApp> {
  Locale _locale = const Locale('ar');

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

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefLangCode, locale.languageCode);
    setState(() => _locale = locale);
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
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomePage(),
    );
  }
}

/// Home with tabs (Loan / Compare / Savings / Settings)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isAr = lang == 'ar';

    final pages = const [
      LoanPage(),
      ComparePage(),
      SavingsPage(),
      SettingsPage(),
    ];

    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.calculate_outlined),
        label: isAr ? 'القرض' : 'Loan',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.compare_arrows_outlined),
        label: isAr ? 'المقارنة' : 'Compare',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.savings_outlined),
        label: isAr ? 'الادخار' : 'Savings',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings_outlined),
        label: isAr ? 'الإعدادات' : 'Settings',
      ),
    ];

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _index,
            children: pages,
          ),
        ),
        bottomNavigationBar: Container(
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
      ),
    );
  }
}
