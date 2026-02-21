import 'package:flutter/material.dart';

import '../../core/app.dart' as app;
import '../../core/app_lang.dart' as lang;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final controller = app.FinovaApp.of(context);
    final isArabic = controller.lang == lang.AppLang.ar;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الإعدادات' : 'Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: isArabic ? 'اللغة' : 'Language'),
          const SizedBox(height: 10),

          // Language segmented control (AR/EN)
          SegmentedButton<lang.AppLang>(
            segments: const [
              ButtonSegment<lang.AppLang>(
                value: lang.AppLang.ar,
                label: Text('AR'),
              ),
              ButtonSegment<lang.AppLang>(
                value: lang.AppLang.en,
                label: Text('EN'),
              ),
            ],
            selected: <lang.AppLang>{controller.lang},
            onSelectionChanged: (set) {
              final selected = set.first;
              // لا تستخدم await هنا (setLang غالباً void)
              controller.setLang(selected);
              setState(() {});
            },
          ),

          const SizedBox(height: 20),
          _SectionTitle(title: isArabic ? 'معلومات' : 'Info'),
          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                isArabic
                    ? 'تنبيه شرعي: القروض ذات الفائدة قد تُعد غير جائزة في كثير من الآراء الفقهية. هذا التطبيق آلة حساب فقط ولا يشجع على الاقتراض.'
                    : 'Sharia notice: Interest-based loans may be impermissible according to many scholarly opinions. This app is a calculator only and does not encourage borrowing.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
