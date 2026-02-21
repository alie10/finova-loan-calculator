import 'package:flutter/material.dart';

import 'app_lang.dart';

// صفحات التطبيق (لازم imports تكون فوق)
import '../features/loan/loan_page.dart';
import '../features/compare/compare_page.dart';
import '../features/savings/savings_page.dart';
import '../features/settings/settings_page.dart';

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

class _FinovaScope extends InheritedWidget {
  final _FinovaAppState state;
  const _FinovaScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(covariant _FinovaScope oldWidget) => true;
}

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
      const LoanPage(),
      const ComparePage(),
      const SavingsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
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
