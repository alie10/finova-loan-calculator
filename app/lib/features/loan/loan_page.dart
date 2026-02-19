import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ads.dart';
import '../../core/app.dart';
import '../../core/app_lang.dart';

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

  String _currency = 'USD';
  final List<String> _currencies = const ['USD', 'EUR', 'GBP', 'EGP', 'SAR', 'AED'];

  bool _loadedPrefs = false;
  bool _showIslamicNotice = true;

  _LoanResult? _result;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isArabic = FinovaApp.of(context).lang == AppLang.ar;
    final saved = prefs.getBool('show_islamic_notice');
    setState(() {
      _showIslamicNotice = saved ?? isArabic;
      _loadedPrefs = true;
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _termCtrl.dispose();
    super.dispose();
  }

  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;
  String _t({required String en, required String ar}) => _isArabic ? ar : en;

  NumberFormat _moneyFormat() {
    final locale = _isArabic ? 'ar' : 'en';
    return NumberFormat.currency(locale: locale, name: _currency, symbol: '$_currency ');
  }

  NumberFormat _numFormat() {
    final locale = _isArabic ? 'ar' : 'en';
    return NumberFormat.decimalPattern(locale);
  }

  double _parseDouble(String s) => double.tryParse(s.trim().replaceAll(',', '')) ?? double.nan;
  int _parseInt(String s) => int.tryParse(s.trim()) ?? -1;

  int _termMonths() {
    final term = _parseInt(_termCtrl.text);
    if (term <= 0) return -1;
    return _termIsYears ? term * 12 : term;
  }

  String? _validateAmount(String? v) {
    final x = _parseDouble(v ?? '');
    if (x.isNaN || x <= 0) return _t(en: 'Enter a valid amount', ar: 'أدخل مبلغًا صحيحًا');
    if (x < 10) return _t(en: 'Minimum amount is 10', ar: 'الحد الأدنى للمبلغ 10');
    if (x > 1000000000) return _t(en: 'Amount too large', ar: 'المبلغ كبير جدًا');
    return null;
  }

  String? _validateRate(String? v) {
    final x = _parseDouble(v ?? '');
    if (x.isNaN || x < 0) return _t(en: 'Enter a valid rate (0–100)', ar: 'أدخل فائدة صحيحة (0–100)');
    if (x > 100) return _t(en: 'Rate must be 0–100', ar: 'الفائدة يجب أن تكون بين 0 و 100');
    return null;
  }

  String? _validateTerm(String? v) {
    final x = _parseInt(v ?? '');
    if (x <= 0) return _t(en: 'Enter a valid term', ar: 'أدخل مدة صحيحة');
    final months = _termIsYears ? x * 12 : x;
    if (months < 1) return _t(en: 'Term too short', ar: 'المدة قصيرة جدًا');
    if (months > 600) return _t(en: 'Max term is 600 months', ar: 'الحد الأقصى 600 شهر');
    return null;
  }

  Future<void> _calculate() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final principal = _parseDouble(_amountCtrl.text);
    final annualRate = _parseDouble(_rateCtrl.text);
    final n = _termMonths();

    if (principal.isNaN || annualRate.isNaN || n <= 0) return;

    final monthlyRate = annualRate / 12 / 100;

    double monthlyPayment;
    if (monthlyRate == 0) {
      monthlyPayment = principal / n;
    } else {
      monthlyPayment =
          (principal * monthlyRate * pow(1 + monthlyRate, n)) / (pow(1 + monthlyRate, n) - 1);
    }

    final totalPayment = monthlyPayment * n;
    final totalInterest = max(0, totalPayment - principal);

    setState(() {
      _result = _LoanResult(
        principal: principal,
        annualRate: annualRate,
        months: n,
        monthlyPayment: monthlyPayment,
        totalPayment: totalPayment,
        totalInterest: totalInterest,
      );
    });

    // Show interstitial occasionally (frequency capped)
    await Ads.maybeShowInterstitial(context);

    // Optional Islamic notice for Arabic
    if (_showIslamicNotice && _isArabic) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 4),
          content: Text('تنبيه: التطبيق آلة حساب فقط. القروض ذات الفائدة غير جائزة في كثير من الآراء.'),
        ),
      );
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    setState(() {
      _amountCtrl.text = '10000';
      _rateCtrl.text = '10';
      _termCtrl.text = '5';
      _termIsYears = true;
      _currency = 'USD';
      _result = null;
    });
  }

  List<_AmRow> _buildSchedule(_LoanResult r) {
    final rows = <_AmRow>[];
    final monthlyRate = r.annualRate / 12 / 100;

    double balance = r.principal;
    final payment = r.monthlyPayment;

    for (int i = 1; i <= r.months; i++) {
      final interest = monthlyRate == 0 ? 0 : balance * monthlyRate;
      double principalPaid = payment - interest;
      if (principalPaid > balance) principalPaid = balance;

      balance = (balance - principalPaid);
      if (balance < 0) balance = 0;

      rows.add(_AmRow(
        month: i,
        payment: payment,
        interest: interest,
        principal: principalPaid,
        balance: balance,
      ));

      if (balance <= 0) break;
    }
    return rows;
  }

  void _showSchedule() {
    final r = _result;
    if (r == null) return;

    final rows = _buildSchedule(r);
    final money = _moneyFormat();
    final num = _numFormat();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _t(en: 'Amortization Schedule', ar: 'جدول السداد'),
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.65,
                  child: ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return ListTile(
                        dense: true,
                        title: Text(_t(en: 'Month', ar: 'شهر') + ' ${num.format(row.month)}'),
                        subtitle: Text(
                          _t(en: 'Principal', ar: 'أصل') +
                              ': ${money.format(row.principal)}   •   ' +
                              _t(en: 'Interest', ar: 'فائدة') +
                              ': ${money.format(row.interest)}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              money.format(row.payment),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _t(en: 'Bal', ar: 'المتبقي') + ': ${money.format(row.balance)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputCard() {
    return Card(
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
                items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _currency = v ?? 'USD'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateAmount,
                decoration: InputDecoration(
                  labelText: _t(en: 'Loan Amount', ar: 'مبلغ القرض'),
                  prefixIcon: const Icon(Icons.payments_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateRate,
                decoration: InputDecoration(
                  labelText: _t(en: 'Interest Rate (%)', ar: 'نسبة الفائدة (%)'),
                  prefixIcon: const Icon(Icons.percent),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _termCtrl,
                      keyboardType: TextInputType.number,
                      validator: _validateTerm,
                      decoration: InputDecoration(
                        labelText: _t(en: 'Term', ar: 'المدة'),
                        prefixIcon: const Icon(Icons.calendar_month_outlined),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(value: true, label: Text(_t(en: 'Years', ar: 'سنوات'))),
                      ButtonSegment(value: false, label: Text(_t(en: 'Months', ar: 'شهور'))),
                    ],
                    selected: {_termIsYears},
                    onSelectionChanged: (s) {
                      setState(() => _termIsYears = s.first);
                      _formKey.currentState?.validate();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: Text(_t(en: 'Calculate', ar: 'احسب')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _reset,
                    child: Text(_t(en: 'Reset', ar: 'إعادة')),
                  ),
                ],
              ),
              if (_showIslamicNotice && _isArabic) ...[
                const SizedBox(height: 12),
                const _IslamicInlineNotice(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(_LoanResult r) {
    final money = _moneyFormat();

    final principal = r.principal;
    final interest = max(0, r.totalInterest);
    final total = principal + interest;

    final sections = [
      PieChartSectionData(
        value: principal <= 0 ? 0 : principal,
        title: _t(en: 'Principal', ar: 'الأصل'),
        radius: 48,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      PieChartSectionData(
        value: interest <= 0 ? 0 : interest,
        title: _t(en: 'Interest', ar: 'الفائدة'),
        radius: 48,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ];

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: _t(en: 'Monthly Payment', ar: 'القسط الشهري'),
                    value: money.format(r.monthlyPayment),
                    icon: Icons.calendar_view_month_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: _t(en: 'Total Payment', ar: 'إجمالي السداد'),
                    value: money.format(r.totalPayment),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricTile(
              label: _t(en: 'Total Interest', ar: 'إجمالي الفائدة'),
              value: money.format(r.totalInterest),
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 28,
                        sections: sections,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendRow(label: _t(en: 'Principal', ar: 'الأصل'), value: money.format(principal)),
                        const SizedBox(height: 8),
                        _LegendRow(label: _t(en: 'Interest', ar: 'الفائدة'), value: money.format(interest)),
                        const SizedBox(height: 8),
                        _LegendRow(label: _t(en: 'Total', ar: 'الإجمالي'), value: money.format(total)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showSchedule,
                    icon: const Icon(Icons.table_chart_outlined),
                    label: Text(_t(en: 'View Schedule', ar: 'عرض الجدول')),
                  ),
                ),
              ],
            ),
            if (_showIslamicNotice && _isArabic) ...[
              const SizedBox(height: 10),
              const _IslamicResultDisclaimer(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(en: 'Loan Calculator', ar: 'حاسبة القرض')),
        actions: [
          IconButton(
            tooltip: _t(en: 'Language', ar: 'اللغة'),
            onPressed: () => FinovaApp.of(context).toggle(),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInputCard(),
          const SizedBox(height: 12),
          if (_result != null) _buildResultCard(_result!),
          if (_result == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _t(
                  en: 'Tip: Use 0% interest for simple installment calculation.',
                  ar: 'ملاحظة: يمكنك وضع 0% لحساب التقسيط بدون فائدة.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}

class _LoanResult {
  final double principal;
  final double annualRate;
  final int months;
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterest;

  const _LoanResult({
    required this.principal,
    required this.annualRate,
    required this.months,
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
  });
}

class _AmRow {
  final int month;
  final double payment;
  final double interest;
  final double principal;
  final double balance;

  const _AmRow({
    required this.month,
    required this.payment,
    required this.interest,
    required this.principal,
    required this.balance,
  });
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final String label;
  final String value;

  const _LegendRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _IslamicInlineNotice extends StatelessWidget {
  const _IslamicInlineNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.45),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'تنبيه شرعي: القروض ذات الفائدة تُعد غير جائزة في كثير من الآراء الفقهية. '
          'هذا التطبيق آلة حساب فقط ولا يشجّع على الاقتراض.',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

class _IslamicResultDisclaimer extends StatelessWidget {
  const _IslamicResultDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.45),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'تنبيه: النتائج تقديرية لأغراض الحساب فقط. التطبيق لا يقدم نصيحة مالية ولا ينصح بأخذ قروض. '
          'شرعًا: القروض ذات الفائدة غير جائزة في كثير من الآراء، فالأفضل تجنّبها واستشارة أهل العلم.',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
