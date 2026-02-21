import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/app.dart';
import '../../core/app_lang.dart' as lang;

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final _formKey = GlobalKey<FormState>();

  final _amountCtrl = TextEditingController(text: '10000');
  final _rateCtrl = TextEditingController(text: '10');
  final _termCtrl = TextEditingController(text: '5');

  bool _termIsYears = true;

  double? _monthlyPayment;
  double? _totalPayment;
  double? _totalInterest;

  bool get _isArabic => FinovaApp.of(context).lang == lang.AppLang.ar;
  String t(String ar, String en) => _isArabic ? ar : en;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _termCtrl.dispose();
    super.dispose();
  }

  double _parseNum(String v) => double.tryParse(v.trim()) ?? 0;

  void _resetResults() {
    setState(() {
      _monthlyPayment = null;
      _totalPayment = null;
      _totalInterest = null;
    });
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final principal = _parseNum(_amountCtrl.text);
    final annualRate = _parseNum(_rateCtrl.text) / 100.0;
    final termValue = _parseNum(_termCtrl.text);
    final months = _termIsYears ? (termValue * 12.0).round() : termValue.round();

    if (principal <= 0 || months <= 0) {
      _snack(t('من فضلك أدخل قيم صحيحة.', 'Please enter valid values.'));
      return;
    }

    final r = annualRate / 12.0;

    final monthly = (r == 0)
        ? (principal / months)
        : (principal * r) / (1 - math.pow(1 + r, -months));

    final totalPay = monthly * months;
    final totalInt = totalPay - principal;

    setState(() {
      _monthlyPayment = monthly;
      _totalPayment = totalPay;
      _totalInterest = totalInt;
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('حاسبة القرض', 'Loan Calculator')),
        actions: [
          IconButton(
            tooltip: t('تبديل اللغة', 'Toggle language'),
            onPressed: () => FinovaApp.of(context).toggle(),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(
                      label: t('مبلغ القرض', 'Loan Amount'),
                      child: TextFormField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: t('مثال: 10000', 'e.g. 10000'),
                          prefixIcon: const Icon(Icons.payments_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (v) {
                          final x = _parseNum(v ?? '');
                          if (x <= 0) return t('أدخل مبلغ صحيح', 'Enter a valid amount');
                          return null;
                        },
                        onChanged: (_) => _resetResults(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: t('نسبة الفائدة (%)', 'Interest Rate (%)'),
                      child: TextFormField(
                        controller: _rateCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: t('مثال: 10', 'e.g. 10'),
                          prefixIcon: const Icon(Icons.percent),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (v) {
                          final x = _parseNum(v ?? '');
                          if (x < 0) return t('أدخل نسبة صحيحة', 'Enter a valid rate');
                          return null;
                        },
                        onChanged: (_) => _resetResults(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            label: t('المدة', 'Term'),
                            child: TextFormField(
                              controller: _termCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: t('مثال: 5', 'e.g. 5'),
                                prefixIcon: const Icon(Icons.calendar_month_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              validator: (v) {
                                final x = _parseNum(v ?? '');
                                if (x <= 0) return t('أدخل مدة صحيحة', 'Enter a valid term');
                                return null;
                              },
                              onChanged: (_) => _resetResults(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            label: t('الوحدة', 'Unit'),
                            child: SegmentedButton<bool>(
                              segments: [
                                ButtonSegment(value: false, label: Text(t('شهور', 'Months'))),
                                ButtonSegment(value: true, label: Text(t('سنوات', 'Years'))),
                              ],
                              selected: {_termIsYears},
                              onSelectionChanged: (s) {
                                setState(() => _termIsYears = s.first);
                                _resetResults();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetResults,
                            child: Text(t('إعادة', 'Reset')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _calculate,
                            icon: const Icon(Icons.calculate_outlined),
                            label: Text(t('احسب', 'Calculate')),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(
                        t(
                          'تنبيه شرعي: القروض ذات الفائدة قد تُعد غير جائزة في كثير من الآراء الفقهية. هذا التطبيق آلة حساب فقط ولا يشجع على الاقتراض.',
                          'Sharia notice: Interest-based loans may be impermissible by many opinions. This app is a calculator only and does not encourage borrowing.',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_monthlyPayment != null) ...[
                      _resultTile(t('القسط الشهري', 'Monthly Payment'), _fmt(_monthlyPayment!)),
                      _resultTile(t('إجمالي السداد', 'Total Payment'), _fmt(_totalPayment!)),
                      _resultTile(t('إجمالي الفائدة', 'Total Interest'), _fmt(_totalInterest!)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _resultTile(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
