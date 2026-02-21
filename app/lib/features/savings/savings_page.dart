import 'package:flutter/material.dart';

import '../../core/app.dart';
import '../../core/app_lang.dart' as lang;
import '../../widgets/ad_banner.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  bool get _isArabic => FinovaApp.of(context).lang == lang.AppLang.ar;

  final _goalCtrl = TextEditingController(text: '10000');
  final _monthlyCtrl = TextEditingController(text: '500');
  final _monthsCtrl = TextEditingController(text: '12');

  String? _result;

  double _parseDouble(String v) => double.tryParse(v.trim()) ?? 0.0;
  int _parseInt(String v) => int.tryParse(v.trim()) ?? 0;

  void _reset() {
    setState(() {
      _goalCtrl.text = '10000';
      _monthlyCtrl.text = '500';
      _monthsCtrl.text = '12';
      _result = null;
    });
  }

  void _calculate() {
    final goal = _parseDouble(_goalCtrl.text);
    final monthly = _parseDouble(_monthlyCtrl.text);
    final months = _parseInt(_monthsCtrl.text);

    if (goal <= 0 || monthly <= 0 || months <= 0) {
      setState(() {
        _result = _isArabic
            ? 'من فضلك أدخل قيم صحيحة أكبر من صفر.'
            : 'Please enter valid values greater than zero.';
      });
      return;
    }

    final totalSaved = monthly * months;
    final diff = totalSaved - goal;

    setState(() {
      if (diff >= 0) {
        _result = _isArabic
            ? 'ممتاز ✅ ستصل لهدفك. إجمالي الادخار: ${totalSaved.toStringAsFixed(2)} (زيادة: ${diff.toStringAsFixed(2)})'
            : 'Great ✅ You will reach your goal. Total saved: ${totalSaved.toStringAsFixed(2)} (extra: ${diff.toStringAsFixed(2)})';
      } else {
        _result = _isArabic
            ? 'لن تصل لهدفك ❌ إجمالي الادخار: ${totalSaved.toStringAsFixed(2)} (نقص: ${diff.abs().toStringAsFixed(2)})'
            : 'You won’t reach your goal ❌ Total saved: ${totalSaved.toStringAsFixed(2)} (shortfall: ${diff.abs().toStringAsFixed(2)})';
      }
    });
  }

  @override
  void dispose() {
    _goalCtrl.dispose();
    _monthlyCtrl.dispose();
    _monthsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isArabic ? 'حسابات الادخار' : 'Savings Calculator';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: _isArabic ? 'تغيير اللغة' : 'Toggle language',
            onPressed: () => FinovaApp.of(context).toggle(),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Field(
              label: _isArabic ? 'هدف الادخار' : 'Savings Goal',
              controller: _goalCtrl,
              icon: Icons.flag_outlined,
            ),
            const SizedBox(height: 12),
            _Field(
              label: _isArabic ? 'المبلغ الشهري' : 'Monthly Amount',
              controller: _monthlyCtrl,
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 12),
            _Field(
              label: _isArabic ? 'عدد الشهور' : 'Number of months',
              controller: _monthsCtrl,
              icon: Icons.calendar_month_outlined,
              isNumber: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: Text(_isArabic ? 'إعادة' : 'Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate_outlined),
                    label: Text(_isArabic ? 'احسب' : 'Calculate'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  _result!,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            const SizedBox(height: 18),
            const Center(child: AdBanner()),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isNumber;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
