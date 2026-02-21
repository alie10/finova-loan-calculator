import 'package:flutter/material.dart';

import 'app_lang.dart';

class FinovaApp extends StatefulWidget {
  const FinovaApp({super.key});

  static _FinovaAppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FinovaScope>();
    assert(scope != null, 'FinovaApp.of(context) called with no FinovaApp in tree');
    return scope!.state;
  }

  @override
  State<FinovaApp> createState() => _FinovaAppState();
}

class _FinovaAppState extends State<FinovaApp> {
  AppLang lang = AppLang.ar;

  void toggle() {
    setState(() {
      lang = (lang == AppLang.ar) ? AppLang.en : AppLang.ar;
    });
  }

  void setLang(AppLang newLang) {
    if (newLang == lang) return;
    setState(() => lang = newLang);
  }

  @override
  Widget build(BuildContext context) {
    return _FinovaScope(
      state: this,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: lang == AppLang.ar ? const Locale('ar') : const Locale('en'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        home: const _RootShell(),
      ),
    );
  }
}

/// Inherited scope for FinovaApp state
class _FinovaScope extends InheritedWidget {
  final _FinovaAppState state;
  const _FinovaScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(covariant _FinovaScope oldWidget) => true;
}

/// Root shell (Bottom navigation)
class _RootShell extends StatefulWidget {
  const _RootShell();

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final isArabic = FinovaApp.of(context).lang == AppLang.ar;

    final pages = <Widget>[
      // لازم تكون موجودة عندك في المسارات دي
      // لو أسماء/مسارات الصفحات مختلفة عندك، ابعتهالي وأنا أضبطها
      const _LazyPage(importPath: 'features/loan/loan_page.dart', className: 'LoanPage'),
      const _LazyPage(importPath: 'features/compare/compare_page.dart', className: 'ComparePage'),
      const _LazyPage(importPath: 'features/savings/savings_page.dart', className: 'SavingsPage'),
      const _LazyPage(importPath: 'features/settings/settings_page.dart', className: 'SettingsPage'),
    ];

    // NOTE: _LazyPage مجرد placeholder لتجنب كراش لو حد غيّر أسماء
    // ولكن لأن Flutter لا يدعم import ديناميكي، هنستخدم Widgets بسيطة بدلها
    // الحل العملي: استورد الصفحات مباشرة (أسفل) — الأفضل.
    // ---------------------------------------------------
    // بما إن مشروعك بالفعل فيه الصفحات، هنستوردها مباشرة بدل placeholder:
    return _DirectRootShell(isArabic: isArabic, index: index, onIndex: (v) => setState(() => index = v));
  }
}

// ✅ استيراد الصفحات مباشرة (الطريقة الصحيحة)
import '../features/loan/loan_page.dart';
import '../features/compare/compare_page.dart';
import '../features/savings/savings_page.dart';
import '../features/settings/settings_page.dart';

class _DirectRootShell extends StatelessWidget {
  final bool isArabic;
  final int index;
  final ValueChanged<int> onIndex;

  const _DirectRootShell({
    required this.isArabic,
    required this.index,
    required this.onIndex,
  });

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const LoanPage(),
      const ComparePage(),
      const SavingsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calculate_outlined),
            selectedIcon: const Icon(Icons.calculate),
            label: isArabic ? 'القرض' : 'Loan',
          ),
          NavigationDestination(
            icon: const Icon(Icons.compare_arrows_outlined),
            selectedIcon: const Icon(Icons.compare_arrows),
            label: isArabic ? 'المقارنة' : 'Compare',
          ),
          NavigationDestination(
            icon: const Icon(Icons.savings_outlined),
            selectedIcon: const Icon(Icons.savings),
            label: isArabic ? 'الادخار' : 'Savings',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: isArabic ? 'الإعدادات' : 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Placeholder (غير مستخدم فعليًا الآن) — سيبها عادي
class _LazyPage extends StatelessWidget {
  final String importPath;
  final String className;
  const _LazyPage({required this.importPath, required this.className});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
