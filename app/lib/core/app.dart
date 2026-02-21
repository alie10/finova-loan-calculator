import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/ad_banner.dart';

// صفحاتك الحالية
import '../features/loan/loan_page.dart';
import '../features/compare/compare_page.dart';
import '../features/savings/savings_page.dart';
import '../features/settings/settings_page.dart';

enum AppLang { ar, en }

class FinovaApp extends StatefulWidget {
  const FinovaApp({super.key});

  static _FinovaAppState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_FinovaAppState>();
    if (state == null) {
      throw Exception('FinovaApp.of(context) called with no FinovaApp in tree.');
    }
    return state;
  }

  @override
  State<FinovaApp> createState() => _FinovaAppState();
}

class _FinovaAppState extends State<FinovaApp> {
  static const _prefsLangKey = 'finova_lang';

  AppLang lang = AppLang.ar; // Default Arabic
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_prefsLangKey);
    if (!mounted) return;
    setState(() {
      lang = (v == 'en') ? AppLang.en : AppLang.ar;
    });
  }

  Future<void> setLang(AppLang newLang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsLangKey, newLang == AppLang.en ? 'en' : 'ar');
    if (!mounted) return;
    setState(() => lang = newLang);
  }

  Future<void> toggle() async {
    await setLang(lang == AppLang.ar ? AppLang.en : AppLang.ar);
  }

  bool get isArabic => lang == AppLang.ar;

  @override
  Widget build(BuildContext context) {
    final locale = isArabic ? const Locale('ar') : const Locale('en');
    final direction = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      home: Directionality(
        textDirection: direction,
        child: _RootShell(
          tabIndex: _tabIndex,
          onTabChanged: (i) => setState(() => _tabIndex = i),
        ),
      ),
    );
  }
}

class _RootShell extends StatelessWidget {
  const _RootShell({
    required this.tabIndex,
    required this.onTabChanged,
  });

  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    // صفحات التبويبات
    final pages = <Widget>[
      const LoanPage(),
      const ComparePage(),
      const SavingsPage(),
      const SettingsPage(),
    ];

    // تسميات التبويبات (تدعم عربي/إنجليزي)
    final isArabic = FinovaApp.of(context).isArabic;
    final labels = isArabic
        ? const ['القرض', 'المقارنة', 'الادخار', 'الإعدادات']
        : const ['Loan', 'Compare', 'Savings', 'Settings'];

    return Scaffold(
      // نخلي الجسم يتبدّل من غير ما يعيد بناء كل شيء بقوة
      body: IndexedStack(
        index: tabIndex,
        children: pages,
      ),

      // ✅ أهم جزء: إعلان بانر ثابت لكل الصفحات + BottomNav
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Banner Ad (يظهر في كل الصفحات)
            const AdBanner(preferAli: true, height: 60),

            // Bottom Navigation
            BottomNavigationBar(
              currentIndex: tabIndex,
              onTap: onTabChanged,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.calculate_outlined),
                  label: labels[0],
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.compare_arrows),
                  label: labels[1],
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.savings_outlined),
                  label: labels[2],
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_outlined),
                  label: labels[3],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
