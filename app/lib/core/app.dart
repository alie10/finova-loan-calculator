import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ads.dart';
import 'app_lang.dart';
import 'strings.dart';
import '../features/loan/loan_page.dart';
import '../features/compare/compare_page.dart';
import '../features/savings/savings_page.dart';
import '../features/settings/settings_page.dart';

class FinovaApp extends StatefulWidget {
  const FinovaApp({super.key});

  static AppLangController of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_LangInherited>();
    return inherited!.controller;
  }

  static S strings(BuildContext context) {
    final c = of(context);
    return S(c.lang);
  }

  @override
  State<FinovaApp> createState() => _FinovaAppState();
}

class _FinovaAppState extends State<FinovaApp> {
  final AppLangController _lang = AppLangController();

  @override
  void initState() {
    super.initState();
    _lang.load();
    // Init AdMob early
    Ads.init();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lang,
      builder: (context, _) {
        if (!_lang.isLoaded) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return _LangInherited(
          controller: _lang,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Finova',
            locale: _lang.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blue,
              brightness: Brightness.light,
            ),
            home: const MainNavigation(),
          ),
        );
      },
    );
  }
}

class _LangInherited extends InheritedWidget {
  final AppLangController controller;

  const _LangInherited({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_LangInherited oldWidget) => oldWidget.controller != controller;
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  List<Widget> _pages() => const [
        LoanPage(),
        ComparePage(),
        SavingsPage(),
        SettingsPage(),
      ];

  @override
  Widget build(BuildContext context) {
    final t = FinovaApp.strings(context);

    return Directionality(
      textDirection: FinovaApp.of(context).direction,
      child: Scaffold(
        body: _pages()[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.calculate), label: t.navLoan),
            NavigationDestination(icon: const Icon(Icons.compare_arrows), label: t.navCompare),
            NavigationDestination(icon: const Icon(Icons.savings), label: t.navSavings),
            NavigationDestination(icon: const Icon(Icons.settings), label: t.navSettings),
          ],
        ),
      ),
    );
  }
}
