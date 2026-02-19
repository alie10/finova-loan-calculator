import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app.dart';
import '../../core/app_lang.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loaded = false;
  bool _showIslamicNotice = true;

  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;
  String _t({required String en, required String ar}) => _isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // default: ON for Arabic, OFF for English (global-friendly)
    final saved = prefs.getBool('show_islamic_notice');
    setState(() {
      _showIslamicNotice = saved ?? _isArabic;
      _loaded = true;
    });
  }

  Future<void> _setShowIslamicNotice(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_islamic_notice', value);
    setState(() => _showIslamicNotice = value);
  }

  @override
  Widget build(BuildContext context) {
    final controller = FinovaApp.of(context);

    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(en: 'Settings', ar: 'الإعدادات')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t(en: 'Language', ar: 'اللغة'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          controller.lang == AppLang.ar ? 'العربية (RTL)' : 'English (LTR)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SegmentedButton<AppLang>(
                    segments: const [
                      ButtonSegment(value: AppLang.en, label: Text('English')),
                      ButtonSegment(value: AppLang.ar, label: Text('العربية')),
                    ],
                    selected: {controller.lang},
                    onSelectionChanged: (value) {
                      final v = value.first;
                      controller.setLang(v);
                      // If user switches language and never set preference before, keep it sensible:
                      // Arabic -> ON, English -> keep current.
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Islamic Notice toggle
          Card(
            elevation: 0,
            child: SwitchListTile(
              value: _showIslamicNotice,
              onChanged: _setShowIslamicNotice,
              secondary: const Icon(Icons.info_outline),
              title: Text(_t(
                en: 'Show Islamic notice (Interest-based loans)',
                ar: 'إظهار التنبيه الشرعي (قروض الفائدة)',
              )),
              subtitle: Text(_t(
                en: 'Displays a disclaimer that this is a calculator tool only.',
                ar: 'يعرض تنبيهًا أن التطبيق أداة حساب فقط وليس نصيحة مالية.',
              )),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.45),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _t(
                  en: 'Finova provides calculations only and does not recommend taking any loan. '
                      'Always consult qualified professionals for decisions.',
                  ar: 'فينوفا يوفر حسابات فقط ولا ينصح بأخذ أي قرض. '
                      'استشر المختصين قبل اتخاذ أي قرار.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
