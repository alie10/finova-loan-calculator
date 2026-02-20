import 'package:flutter/material.dart';

import '../../core/app.dart';
import '../../core/app_lang.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;

  String _t({required String ar, required String en}) => _isArabic ? ar : en;

  Future<void> _setLanguage(AppLang lang) async {
    await FinovaApp.of(context).setLang(lang);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isAr = _isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_t(ar: 'الإعدادات', en: 'Settings')),
          actions: [
            IconButton(
              tooltip: _t(ar: 'تبديل اللغة', en: 'Toggle language'),
              onPressed: () async {
                await FinovaApp.of(context).toggle();
                setState(() {});
              },
              icon: const Icon(Icons.language),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(ar: 'اللغة', en: 'Language'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _LangTile(
                            title: 'العربية',
                            selected: isAr,
                            onTap: () => _setLanguage(AppLang.ar),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LangTile(
                            title: 'English',
                            selected: !isAr,
                            onTap: () => _setLanguage(AppLang.en),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(ar: 'تنبيه شرعي', en: 'Sharia Notice'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _t(
                        ar:
                            'تنبيه: القروض الربوية محرّمة في الشريعة الإسلامية. هذا التطبيق أداة حسابية فقط لعرض التكلفة/الفائدة ولا يُعد نصيحة بالاقتراض.',
                        en:
                            'Notice: Interest-based loans are prohibited in Islamic Sharia. This app is a calculator only to show costs/interest and is not a recommendation to take loans.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0x1A3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: Color(0xFF3B82F6)),
            if (selected) const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
