import 'package:flutter/material.dart';

import '../../core/app.dart';
import '../../core/app_lang.dart';
import '../../widgets/ad_banner.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;
  String _t(String ar, String en) => _isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final isArabic = _isArabic;
    final lang = FinovaApp.of(context).lang;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_t('الإعدادات', 'Settings')),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const AdBanner(),
              const SizedBox(height: 12),

              ListTile(
                leading: const Icon(Icons.language),
                title: Text(_t('اللغة', 'Language')),
                subtitle: Text(lang == AppLang.ar ? 'العربية' : 'English'),
                trailing: SegmentedButton<AppLang>(
                  segments: const [
                    ButtonSegment(value: AppLang.ar, label: Text('AR')),
                    ButtonSegment(value: AppLang.en, label: Text('EN')),
                  ],
                  selected: {lang},
                  onSelectionChanged: (s) {
                    FinovaApp.of(context).setLang(s.first);
                  },
                ),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(_t('تنبيه شرعي', 'Sharia notice')),
                subtitle: Text(
                  _t(
                    'التطبيق آلة حساب فقط ولا يشجع على القروض ذات الفائدة.',
                    'This app is for calculation only and does not encourage interest-based loans.',
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const AdBanner(),

              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => FinovaApp.of(context).toggle(),
                icon: const Icon(Icons.swap_horiz),
                label: Text(_t('تبديل سريع للغة', 'Quick toggle language')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
