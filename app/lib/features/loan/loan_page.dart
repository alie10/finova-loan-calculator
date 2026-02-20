import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app.dart';
import '../../core/app_lang.dart';
import '../../widgets/ad_banner.dart';

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

  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _termCtrl.dispose();
    super.dispose();
  }

  String _t(String ar, String en) => _isArabic ? ar : en;

  double _parseNum(String v) => double.tryParse(v.trim()) ?? 0;

  void _reset() {
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
      _showSnack(_t('من فضلك أدخل قيم صحيحة.', 'Please enter valid values.'));
      return;
    }

    // monthly interest rate
    final r = annualRate / 12.0;

    // If r == 0 -> simple division
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

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final isArabic = _isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('حاسبة القرض', 'Loan Calculator')),
        actions: [
          IconButton(
            tooltip: _t('تبديل اللغة', 'Toggle language'),
            onPressed: () => FinovaApp.of(context).toggle(),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const AdBanner(),
              const SizedBox(height: 12),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(
                      label: _t('العملة', 'Currency'),
                      child: DropdownButtonFormField<String>(
                        value: 'USD',
                        items: const [
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'EGP', child: Text('EGP')),
                          DropdownMenuItem(value: 'SAR', child: Text('SAR')),
                          DropdownMenuItem(value: 'AED', child: Text('AED')),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: _t('مبلغ القرض', 'Loan Amount'),
                      child: TextFormField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: _t('مثال: 10000', 'e.g. 10000'),
                          prefixIcon: const Icon(Icons.payments_outlined),
                        ),
                        validator: (v) {
                          final x = _parseNum(v ?? '');
                          if (x <= 0) return _t('أدخل مبلغ صحيح', 'Enter a valid amount');
                          return null;
                        },
                        onChanged: (_) => _reset(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: _t('نسبة الفائدة (%)', 'Interest Rate (%)'),
                      child: TextFormField(
                        controller: _rateCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: _t('مثال: 10', 'e.g. 10'),
                          prefixIcon: const Icon(Icons.percent),
                        ),
                        validator: (v) {
                          final x = _parseNum(v ?? '');
                          if (x < 0) return _t('أدخل نسبة صحيحة', 'Enter a valid rate');
                          return null;
                        },
                        onChanged: (_) => _reset(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            label: _t('المدة', 'Term'),
                            child: TextFormField(
                              controller: _termCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: _t('مثال: 5', 'e.g. 5'),
                                prefixIcon: const Icon(Icons.calendar_month_outlined),
                              ),
                              validator: (v) {
                                final x = _parseNum(v ?? '');
                                if (x <= 0) return _t('أدخل مدة صحيحة', 'Enter a valid term');
                                return null;
                              },
                              onChanged: (_) => _reset(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            label: _t('الوحدة', 'Unit'),
                            child: SegmentedButton<bool>(
                              segments: [
                                ButtonSegment(
                                  value: false,
                                  label: Text(_t('شهور', 'Months')),
                                ),
                                ButtonSegment(
                                  value: true,
                                  label: Text(_t('سنوات', 'Years')),
                                ),
                              ],
                              selected: {_termIsYears},
                              onSelectionChanged: (s) {
                                setState(() {
                                  _termIsYears = s.first;
                                });
                                _reset();
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
                            onPressed: _reset,
                            child: Text(_t('إعادة', 'Reset')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _calculate,
                            icon: const Icon(Icons.calculate_outlined),
                            label: Text(_t('احسب', 'Calculate')),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _t(
                          'تنبيه شرعي: القروض ذات الفائدة تعد غير جائزة في كثير من الآراء الفقهية. هذا التطبيق آلة حساب فقط ولا يشجع على الاقتراض.',
                          'Sharia notice: Interest-based loans are considered impermissible by many scholars. This app is for calculation only and does not encourage borrowing.',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_monthlyPayment != null) ...[
                      _resultTile(_t('القسط الشهري', 'Monthly Payment'), _fmt(_monthlyPayment!)),
                      _resultTile(_t('إجمالي السداد', 'Total Payment'), _fmt(_totalPayment!)),
                      _resultTile(_t('إجمالي الفائدة', 'Total Interest'), _fmt(_totalInterest!)),
                      const SizedBox(height: 16),
                    ],

                    const AdBanner(),
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
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
