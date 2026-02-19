import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app.dart';
import '../../core/app_lang.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _initialCtrl = TextEditingController(text: '1000');
  final _monthlyCtrl = TextEditingController(text: '200');
  final _rateCtrl = TextEditingController(text: '5');
  final _yearsCtrl = TextEditingController(text: '5');

  String _currency = 'USD';
  final List<String> _currencies = const ['USD', 'EUR', 'GBP', 'EGP', 'SAR', 'AED'];

  _SavingsResult? _result;

  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;
  String _t({required String en, required String ar}) => _isArabic ? ar : en;

  NumberFormat _moneyFormat() {
    final locale = _isArabic ? 'ar' : 'en';
    return NumberFormat.currency(locale: locale, name: _currency, symbol: '$_currency ');
  }

  double _parseDouble(String s) => double.tryParse(s.trim()) ?? double.nan;
  int _parseInt(String s) => int.tryParse(s.trim()) ?? -1;

  String? _validatePositive(String? v) {
    final x = _parseDouble(v ?? '');
    if (x.isNaN || x < 0) return _t(en: 'Enter valid number', ar: 'أدخل رقم صحيح');
    return null;
  }

  String? _validateYears(String? v) {
    final x = _parseInt(v ?? '');
    if (x <= 0) return _t(en: 'Enter valid years', ar: 'أدخل عدد سنوات صحيح');
    if (x > 100) return _t(en: 'Too large', ar: 'عدد كبير جدًا');
    return null;
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final initial = _parseDouble(_initialCtrl.text);
    final monthly = _parseDouble(_monthlyCtrl.text);
    final annualRate = _parseDouble(_rateCtrl.text);
    final years = _parseInt(_yearsCtrl.text);

    final months = years * 12;
    final monthlyRate = annualRate / 12 / 100;

    double futureValue = initial * pow(1 + monthlyRate, months);

    for (int i = 0; i < months; i++) {
      futureValue += monthly * pow(1 + monthlyRate, months - i);
    }

    final totalInvested = initial + monthly * months;
    final totalInterest = futureValue - totalInvested;

    setState(() {
      _result = _SavingsResult(
        futureValue: futureValue,
        totalInvested: totalInvested,
        totalInterest: totalInterest,
      );
    });
  }

  void _reset() {
    setState(() {
      _initialCtrl.text = '1000';
      _monthlyCtrl.text = '200';
      _rateCtrl.text = '5';
      _yearsCtrl.text = '5';
      _currency = 'USD';
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final money = _moneyFormat();

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(en: 'Savings Calculator', ar: 'حاسبة الادخار')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => FinovaApp.of(context).toggle(),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: InputDecoration(
                        labelText: _t(en: 'Currency', ar: 'العملة'),
                        border: const OutlineInputBorder(),
                      ),
                      items: _currencies
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _currency = v ?? 'USD'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _initialCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validatePositive,
                      decoration: InputDecoration(
                        labelText: _t(en: 'Initial Amount', ar: 'المبلغ المبدئي'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _monthlyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validatePositive,
                      decoration: InputDecoration(
                        labelText: _t(en: 'Monthly Deposit', ar: 'الإيداع الشهري'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _rateCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validatePositive,
                      decoration: InputDecoration(
                        labelText: _t(en: 'Annual Interest (%)', ar: 'الفائدة السنوية (%)'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _yearsCtrl,
                      keyboardType: TextInputType.number,
                      validator: _validateYears,
                      decoration: InputDecoration(
                        labelText: _t(en: 'Years', ar: 'عدد السنوات'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _calculate,
                            child: Text(_t(en: 'Calculate', ar: 'احسب')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _reset,
                          child: Text(_t(en: 'Reset', ar: 'إعادة')),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Metric(label: _t(en: 'Future Value', ar: 'القيمة المستقبلية'), value: money.format(_result!.futureValue)),
                    const SizedBox(height: 10),
                    _Metric(label: _t(en: 'Total Invested', ar: 'إجمالي المبلغ المدفوع'), value: money.format(_result!.totalInvested)),
                    const SizedBox(height: 10),
                    _Metric(label: _t(en: 'Total Interest', ar: 'إجمالي الأرباح'), value: money.format(_result!.totalInterest)),
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}

class _SavingsResult {
  final double futureValue;
  final double totalInvested;
  final double totalInterest;

  const _SavingsResult({
    required this.futureValue,
    required this.totalInvested,
    required this.totalInterest,
  });
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
