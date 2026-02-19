import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ads.dart';
import '../../core/app.dart';
import '../../core/app_lang.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final _formKey = GlobalKey<FormState>();

  final _aAmountCtrl = TextEditingController(text: '10000');
  final _aRateCtrl = TextEditingController(text: '10');
  final _aTermCtrl = TextEditingController(text: '5');

  final _bAmountCtrl = TextEditingController(text: '10000');
  final _bRateCtrl = TextEditingController(text: '8');
  final _bTermCtrl = TextEditingController(text: '5');

  bool _termIsYears = true;

  String _currency = 'USD';
  final List<String> _currencies = const ['USD', 'EUR', 'GBP', 'EGP', 'SAR', 'AED'];

  bool _loadedPrefs = false;
  bool _showIslamicNotice = true;

  _CompareResult? _result;

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
    _aAmountCtrl.dispose();
    _aRateCtrl.dispose();
    _aTermCtrl.dispose();
    _bAmountCtrl.dispose();
    _bRateCtrl.dispose();
    _bTermCtrl.dispose();
    super.dispose();
  }

  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;
  String _t({required String en, required String ar}) => _isArabic ? ar : en;

  NumberFormat _moneyFormat() {
    final locale = _isArabic ? 'ar' : 'en';
    return NumberFormat.currency(locale: locale, name: _currency, symbol: '$_currency ');
  }

  double _parseDouble(String s) => double.tryParse(s.trim().replaceAll(',', '')) ?? double.nan;
  int _parseInt(String s) => int.tryParse(s.trim()) ?? -1;

  int _termMonthsFrom(TextEditingController ctrl) {
    final term = _parseInt(ctrl.text);
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

  _LoanCalc _calcLoan({
    required double principal,
    required double annualRate,
    required int months,
  }) {
    final double monthlyRate = annualRate / 12.0 / 100.0;

    final double monthlyPayment = (monthlyRate == 0.0)
        ? (principal / months.toDouble())
        : (principal * monthlyRate * pow(1.0 + monthlyRate, months).toDouble()) /
            (pow(1.0 + monthlyRate, months).toDouble() - 1.0);

    final double totalPayment = monthlyPayment * months.toDouble();
    final double totalInterest = max(0.0, totalPayment - principal);

    return _LoanCalc(
      principal: principal,
      annualRate: annualRate,
      months: months,
      monthlyPayment: monthlyPayment,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
    );
  }

  Future<void> _compare() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final double aP = _parseDouble(_aAmountCtrl.text);
    final double aR = _parseDouble(_aRateCtrl.text);
    final int aN = _termMonthsFrom(_aTermCtrl);

    final double bP = _parseDouble(_bAmountCtrl.text);
    final double bR = _parseDouble(_bRateCtrl.text);
    final int bN = _termMonthsFrom(_bTermCtrl);

    if (aP.isNaN || aR.isNaN || aN <= 0 || bP.isNaN || bR.isNaN || bN <= 0) return;

    final a = _calcLoan(principal: aP, annualRate: aR, months: aN);
    final b = _calcLoan(principal: bP, annualRate: bR, months: bN);

    // winner by lower total interest, then lower total payment
    int winner;
    if ((a.totalInterest - b.totalInterest).abs() < 0.01 && (a.totalPayment - b.totalPayment).abs() < 0.01) {
      winner = 0;
    } else if (a.totalInterest < b.totalInterest - 0.01) {
      winner = 1;
    } else if (b.totalInterest < a.totalInterest - 0.01) {
      winner = 2;
    } else {
      winner = a.totalPayment <= b.totalPayment ? 1 : 2;
    }

    setState(() {
      _result = _CompareResult(a: a, b: b, winner: winner);
    });

    await Ads.maybeShowInterstitial(context);

    if (_showIslamicNotice && _isArabic) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 4),
          content: Text('تنبيه: التطبيق آلة حساب فقط ولا ينصح بالاقتراض. القروض ذات الفائدة غير جائزة في كثير من الآراء.'),
        ),
      );
    }
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    setState(() {
      _aAmountCtrl.text = '10000';
      _aRateCtrl.text = '10';
      _aTermCtrl.text = '5';
      _bAmountCtrl.text = '10000';
      _bRateCtrl.text = '8';
      _bTermCtrl.text = '5';
      _termIsYears = true;
      _currency = 'USD';
      _result = null;
    });
  }

  Widget _loanCard({
    required String title,
    required TextEditingController amount,
    required TextEditingController rate,
    required TextEditingController term,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextFormField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validateAmount,
              decoration: InputDecoration(
                labelText: _t(en: 'Amount', ar: 'المبلغ'),
                prefixIcon: const Icon(Icons.payments_outlined),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: rate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validateRate,
              decoration: InputDecoration(
                labelText: _t(en: 'Rate (%)', ar: 'الفائدة (%)'),
                prefixIcon: const Icon(Icons.percent),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: term,
              keyboardType: TextInputType.number,
              validator: _validateTerm,
              decoration: InputDecoration(
                labelText: _t(en: 'Term', ar: 'المدة'),
                prefixIcon: const Icon(Icons.calendar_month_outlined),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(_CompareResult r) {
    final money = _moneyFormat();

    final String winnerText = (r.winner == 0)
        ? _t(en: 'Tie (very close)', ar: 'متقارب جدًا (تعادل)')
        : (r.winner == 1)
            ? _t(en: 'Loan A is better (lower cost)', ar: 'القرض A أفضل (تكلفة أقل)')
            : _t(en: 'Loan B is better (lower cost)', ar: 'القرض B أفضل (تكلفة أقل)');

    final double diffMonthly = r.a.monthlyPayment - r.b.monthlyPayment;
    final double diffInterest = r.a.totalInterest - r.b.totalInterest;
    final double diffTotal = r.a.totalPayment - r.b.totalPayment;

    String fmtDiff(double v) {
      final sign = v >= 0.0 ? '+' : '-';
      return '$sign${money.format(v.abs())}';
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.verified_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    winnerText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: _t(en: 'A Monthly', ar: 'قسط A'),
                    value: money.format(r.a.monthlyPayment),
                    icon: Icons.looks_one,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: _t(en: 'B Monthly', ar: 'قسط B'),
                    value: money.format(r.b.monthlyPayment),
                    icon: Icons.looks_two,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: _t(en: 'A Interest', ar: 'فائدة A'),
                    value: money.format(r.a.totalInterest),
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: _t(en: 'B Interest', ar: 'فائدة B'),
                    value: money.format(r.b.totalInterest),
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _t(en: 'Differences (A - B)', ar: 'الفروقات (A - B)'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            _DiffRow(label: _t(en: 'Monthly', ar: 'القسط'), value: fmtDiff(diffMonthly)),
            _DiffRow(label: _t(en: 'Interest', ar: 'الفائدة'), value: fmtDiff(diffInterest)),
            _DiffRow(label: _t(en: 'Total', ar: 'الإجمالي'), value: fmtDiff(diffTotal)),
            if (_showIslamicNotice && _isArabic) ...[
              const SizedBox(height: 12),
              const _IslamicCompareDisclaimer(),
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
        title: Text(_t(en: 'Compare Loans', ar: 'مقارنة القروض')),
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
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
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
              ),
            ],
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _loanCard(
                  title: _t(en: 'Loan A', ar: 'القرض A'),
                  amount: _aAmountCtrl,
                  rate: _aRateCtrl,
                  term: _aTermCtrl,
                ),
                const SizedBox(height: 12),
                _loanCard(
                  title: _t(en: 'Loan B', ar: 'القرض B'),
                  amount: _bAmountCtrl,
                  rate: _bRateCtrl,
                  term: _bTermCtrl,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _compare,
                        icon: const Icon(Icons.compare_arrows),
                        label: Text(_t(en: 'Compare', ar: 'قارن')),
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
          const SizedBox(height: 12),
          if (_result != null) _resultCard(_result!),
        ],
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}

class _LoanCalc {
  final double principal;
  final double annualRate;
  final int months;
  final double monthlyPayment;
  final double totalPayment;
  final double totalInterest;

  const _LoanCalc({
    required this.principal,
    required this.annualRate,
    required this.months,
    required this.monthlyPayment,
    required this.totalPayment,
    required this.totalInterest,
  });
}

class _CompareResult {
  final _LoanCalc a;
  final _LoanCalc b;
  final int winner; // 0 tie, 1 A, 2 B

  const _CompareResult({required this.a, required this.b, required this.winner});
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

class _DiffRow extends StatelessWidget {
  final String label;
  final String value;

  const _DiffRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
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

class _IslamicCompareDisclaimer extends StatelessWidget {
  const _IslamicCompareDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.45),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'تنبيه: هذه المقارنة لأغراض الحساب فقط وليست توصية بأخذ قرض. '
          'شرعًا: القروض ذات الفائدة غير جائزة في كثير من الآراء، فالأفضل تجنّبها واستشارة أهل العلم.',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
