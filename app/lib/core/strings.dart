import 'app_lang.dart';

class S {
  final AppLang lang;
  const S(this.lang);

  String get appName => _t(en: 'Finova', ar: 'فينوفا');

  String get navLoan => _t(en: 'Loan', ar: 'قرض');
  String get navCompare => _t(en: 'Compare', ar: 'مقارنة');
  String get navSavings => _t(en: 'Savings', ar: 'ادخار');
  String get navSettings => _t(en: 'Settings', ar: 'الإعدادات');

  String get settingsTitle => _t(en: 'Settings', ar: 'الإعدادات');
  String get language => _t(en: 'Language', ar: 'اللغة');
  String get english => _t(en: 'English', ar: 'English');
  String get arabic => _t(en: 'Arabic', ar: 'العربية');
  String get uiPreview => _t(en: 'UI Preview', ar: 'معاينة الواجهة');

  String _t({required String en, required String ar}) {
    return lang == AppLang.ar ? ar : en;
  }
}
