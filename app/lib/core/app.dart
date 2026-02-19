import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ استورد صفحاتك هنا حسب المسارات الموجودة عندك
// لو أسماء الصفحات مختلفة عندك، قولّي أسماء الملفات الموجودة عندك وأنا أضبطها فورًا.
import '../features/home/home_page.dart';
import '../features/settings/settings_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _prefLangKey = 'app_lang';
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefLangKey);
    if (code == 'ar') {
      setState(() => _locale = const Locale('ar'));
    } else if (code == 'en') {
      setState(() => _locale = const Locale('en'));
    } else {
      // default Arabic لو أنت عايزها افتراضي
      setState(() => _locale = const Locale('ar'));
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLangKey, locale.languageCode);
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF3B82F6),
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: const CardTheme(
        elevation: 0,
        margin: EdgeInsets.all(12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.4),
        ),
      ),
    );

    return _LocaleScope(
      locale: _locale,
      setLocale: setLocale,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Finova',
        theme: theme,
        locale: _locale,
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          // لو اللغة المحفوظة موجودة هنستخدمها، وإلا هنحاول لغة الجهاز
          if (_locale.languageCode == 'ar' || _locale.languageCode == 'en') {
            return _locale;
          }
          if (deviceLocale == null) return const Locale('en');
          for (final l in supportedLocales) {
            if (l.languageCode == deviceLocale.languageCode) return l;
          }
          return const Locale('en');
        },
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/settings': (context) => const SettingsPage(),
        },
      ),
    );
  }
}

/// ✅ scope بسيط علشان صفحات Settings تقدر تغيّر اللغة
class _LocaleScope extends InheritedWidget {
  final Locale locale;
  final Future<void> Function(Locale) setLocale;

  const _LocaleScope({
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  static _LocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_LocaleScope>();
    assert(scope != null, 'LocaleScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant _LocaleScope oldWidget) {
    return oldWidget.locale != locale;
  }
}

/// Helper علشان أي صفحة تقدر تنادي تغيير اللغة بسهولة
Future<void> setAppLocale(BuildContext context, Locale locale) async {
  await _LocaleScope.of(context).setLocale(locale);
}
