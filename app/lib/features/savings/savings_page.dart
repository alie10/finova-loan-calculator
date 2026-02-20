import 'package:flutter/material.dart';

import '../../core/app.dart';
import '../../core/app_lang.dart';
import '../../widgets/ad_banner.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;
  String _t(String ar, String en) => _isArabic ? ar : en;

  final _monthlyCtrl = TextEditingController(text: '500');
  final _monthsCtrl = TextEditingController(text: '12');

  double? _total;

  double _parse(String v) => double.tryParse(v.trim()) ?? 0;

  void _calc() {
    final m = _parse(_monthlyCtrl.text);
    final n = _parse(_monthsCtrl.text);
    if (m <= 0 || n <= 0) return;
    setState(() => _total = m * n);
  }

  @override
  void dispose() {
    _monthlyCtrl.dispose();
    _monthsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_t('الادخار', 'Savings')),
          actions: [
            IconButton(
              onPressed: () => FinovaApp.of(context).toggle(),
              icon: const Icon(Icons.language),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const AdBanner(),
              const SizedBox(height: 12),

              Text(_t('حاسبة ادخار بسيطة', 'Simple savings calculator'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              TextField(
                controller: _monthlyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _t('ادخار شهري', 'Monthly saving'),
                  prefixIcon: const Icon(Icons.savings_outlined),
                ),
                onChanged: (_) => setState(() => _total = null),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _monthsCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _t('عدد الشهور', 'Number of months'),
                  prefixIcon: const Icon(Icons.calendar_month_outlined),
                ),
                onChanged: (_) => setState(() => _total = null),
              ),
              const SizedBox(height: 12),

              FilledButton(
                onPressed: _calc,
                child: Text(_t('احسب', 'Calculate')),
              ),

              if (_total != null) ...[
                const SizedBox(height: 12),
                Text(
                  _t('الإجمالي: ', 'Total: ') + _total!.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],

              const SizedBox(height: 16),
              const AdBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
