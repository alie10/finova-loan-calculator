import 'package:flutter/material.dart';
import '../../core/app.dart';
import '../../core/app_lang.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FinovaApp.of(context);
    final t = FinovaApp.strings(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(t.language),
              subtitle: Text(controller.lang == AppLang.ar ? t.arabic : t.english),
              trailing: SegmentedButton<AppLang>(
                segments: [
                  ButtonSegment(value: AppLang.en, label: Text(t.english)),
                  ButtonSegment(value: AppLang.ar, label: Text(t.arabic)),
                ],
                selected: {controller.lang},
                onSelectionChanged: (value) {
                  final v = value.first;
                  controller.setLang(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text(t.uiPreview),
              subtitle: Text(
                controller.lang == AppLang.ar
                    ? 'الاتجاه RTL شغال + اللغة محفوظة'
                    : 'RTL works + language is saved',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
