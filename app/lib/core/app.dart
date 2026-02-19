import 'package:flutter/material.dart';
import '../features/loan/loan_page.dart';
import '../features/compare/compare_page.dart';
import '../features/savings/savings_page.dart';
import '../features/settings/settings_page.dart';

class FinovaApp extends StatelessWidget {
  const FinovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finova',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    LoanPage(),
    ComparePage(),
    SavingsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calculate), label: 'Loan'),
          NavigationDestination(icon: Icon(Icons.compare), label: 'Compare'),
          NavigationDestination(icon: Icon(Icons.savings), label: 'Savings'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
