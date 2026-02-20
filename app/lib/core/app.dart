// app/lib/core/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_lang.dart';

// صفحات التطبيق (لازم تكون موجودة عندك بالمسارات دي)
import '../features/loan/loan_page.dart';
import '../features/compare/compare_page.dart';
import '../features/savings/savings_page.dart';
import '../features/settings/settings_page.dart';

class FinovaApp extends StatefulWidget {
  const FinovaApp({super.key});

  static _FinovaAppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FinovaScope>();
    assert(scope != null, 'FinovaApp.of(context) called with no FinovaApp in tree.');
    return scope!.state;
  }

  @override
  State<FinovaApp> createState() => _FinovaAppState();
}

class _FinovaAppState extends State<FinovaApp> {
  AppLang lang = AppLang.ar;

  void toggle() {
    setState(() {
      lang = lang == AppLang.ar ? AppLang.en : AppLang.ar;
    });
  }

  void setLang(AppLang value) {
    setState(() => lang = value);
  }

  @override
  Widget build(BuildContext context) {
    return _FinovaScope(
      state: this,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Finova',
        locale: lang.locale,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        home: const _FinovaShell(),
      ),
    );
  }
}

class _FinovaScope extends InheritedWidget {
  final _FinovaAppState state;
  const _FinovaScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(_FinovaScope oldWidget) => oldWidget.state.lang != state.lang;
}

class _FinovaShell extends StatefulWidget {
  const _FinovaShell();

  @override
  State<_FinovaShell> createState() => _FinovaShellState();
}

class _FinovaShellState extends State<_FinovaShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final isArabic = FinovaApp.of(context).lang.isArabic;

    final pages = const [
      LoanPage(),
      ComparePage(),
      SavingsPage(),
      SettingsPage(),
    ];

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(child: pages[index]),
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
      ),
    );
  }
}
