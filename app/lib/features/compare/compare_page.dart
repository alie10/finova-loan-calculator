import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/ads/ad_service.dart';
import '../../core/app.dart'; // يحتوي FinovaApp + AppLang (حسب مشروعك الحالي)

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  // خيار A
  final _aAmount = TextEditingController(text: '10000');
  final _aRate = TextEditingController(text: '10');
  final _aTerm = TextEditingController(text: '5');

  // خيار B
  final _bAmount = TextEditingController(text: '10000');
  final _bRate = TextEditingController(text: '12');
  final _bTerm = TextEditingController(text: '5');

  bool _termInYears = true;
  String _currency = 'USD';
  final List<String> _currencies = const ['USD', 'EGP', 'SAR', 'AED', 'EUR'];

  _CompareResult? _result;

  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;
  String t(String ar, String en) => _isArabic ? ar : en;

  @override
  void dispose() {
    _aAmount.dispose();
    _aRate.dispose();
    _aTerm.dispose();
    _bAmount.dispose();
    _bRate.dispose();
    _bTerm.dispose();
    super.dispose();
  }

  double _parseDouble(String s) => double.tryParse(s.trim().replaceAll(',', '')) ?? 0.0;
  int _parseInt(String s) => int.tryParse(s.trim()) ?? 0;

  double _calcEmi({
    required double principal,
    required double annualRatePercent,
    required int months,
  }) {
    if (principal <= 0 || months <= 0) return 0.0;

    final r = (annualRatePercent / 100.0) / 12.0;
    if (r <= 0) return principal / months;

    final powVal = pow(1 + r, months).toDouble();
    final emi = principal * r * powVal / (powVal - 1);
    return emi.isFinite ? emi : 0.0;
  }

  String _fmt(double v) => v.toStringAsFixed(2);

  void _reset() {
    setState(() {
      _aAmount.text = '10000';
      _aRate.text = '10';
      _aTerm.text = '5';

      _bAmount.text = '10000';
      _bRate.text = '12';
      _bTerm.text = '5';

      _termInYears = true;
      _currency = 'USD';
      _result = null;
    });
  }

  Future<void> _compare() async {
    final aP = _parseDouble(_aAmount.text);
    final aR = _parseDouble(_aRate.text);
    final aT = _parseInt(_aTerm.text);

    final bP = _parseDouble(_bAmount.text);
    final bR = _parseDouble(_bRate.text);
    final bT = _parseInt(_bTerm.text);

    if (aP <= 0 || bP <= 0 || aT <= 0 || bT <= 0 || aR < 0 || bR < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('من فضلك أدخل أرقام صحيحة.', 'Please enter valid numbers.'))),
      );
      return;
    }

    final aMonths = _termInYears ? aT * 12 : aT;
    final bMonths = _termInYears ? bT * 12 : bT;

    final aMonthly = _calcEmi(principal: aP, annualRatePercent: aR, months: aMonths);
    final bMonthly = _calcEmi(principal: bP, annualRatePercent: bR, months: bMonths);

    final aTotal = aMonthly * aMonths;
    final bTotal = bMonthly * bMonths;

    final aInterest = aTotal - aP;
    final bInterest = bTotal - bP;

    final bestMonthly = aMonthly <= bMonthly ? _BestOption.a : _BestOption.b;
    final bestTotal = aTotal <= bTotal ? _BestOption.a : _BestOption.b;
    final bestInterest = aInterest <= bInterest ? _BestOption.a : _BestOption.b;

    setState(() {
      _result = _CompareResult(
        a: _LoanSnapshot(principal: aP, rate: aR, months: aMonths, monthly: aMonthly, total: aTotal, interest: aInterest),
        b: _LoanSnapshot(principal: bP, rate: bR, months: bMonths, monthly: bMonthly, total: bTotal, interest: bInterest),
        bestMonthly: bestMonthly,
        bestTotal: bestTotal,
        bestInterest: bestInterest,
      );
    });

    // ✅ عرض Interstitial بذكاء
    await AdService.instance.maybeShowInterstitial();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                const Icon(Icons.compare_arrows),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('المقارنة', 'Comparison'),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // العملة
            _Card(
              title: t('العملة', 'Currency'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _currency,
                  items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _currency = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // نوع المدة
            _Card(
              title: t('نوع المدة', 'Term Type'),
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(t('شهور', 'Months'))),
                  ButtonSegment(value: true, label: Text(t('سنوات', 'Years'))),
                ],
                selected: {_termInYears},
                onSelectionChanged: (s) => setState(() => _termInYears = s.first),
              ),
            ),
            const SizedBox(height: 12),

            // خيار A
            _SectionHeader(title: t('الخيار A', 'Option A')),
            const SizedBox(height: 8),
            _LoanInputs(
              isArabic: _isArabic,
              amountCtrl: _aAmount,
              rateCtrl: _aRate,
              termCtrl: _aTerm,
              termLabel: _termInYears ? t('المدة (سنوات)', 'Term (Years)') : t('المدة (شهور)', 'Term (Months)'),
            ),
            const SizedBox(height: 12),

            // خيار B
            _SectionHeader(title: t('الخيار B', 'Option B')),
            const SizedBox(height: 8),
            _LoanInputs(
              isArabic: _isArabic,
              amountCtrl: _bAmount,
              rateCtrl: _bRate,
              termCtrl: _bTerm,
              termLabel: _termInYears ? t('المدة (سنوات)', 'Term (Years)') : t('المدة (شهور)', 'Term (Months)'),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: Text(t('إعادة', 'Reset')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _compare,
                    icon: const Icon(Icons.compare),
                    label: Text(t('قارن', 'Compare')),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // تنبيه شرعي
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
              ),
              child: Text(
                t(
                  'تنبيه شرعي: القروض ذات الفائدة تُعد غير جائزة في كثير من الآراء الفقهية. هذا التطبيق آلة حساب فقط ولا يُشجّع على الاقتراض.',
                  'Sharia notice: Interest-based loans are considered impermissible by many scholarly opinions. This app is for calculation only and does not encourage borrowing.',
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 18),

            if (_result != null) ...[
              _ResultsCard(
                currency: _currency,
                isArabic: _isArabic,
                r: _result!,
                fmt: _fmt,
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoanInputs extends StatelessWidget {
  final bool isArabic;
  final TextEditingController amountCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController termCtrl;
  final String termLabel;

  const _LoanInputs({
    required this.isArabic,
    required this.amountCtrl,
    required this.rateCtrl,
    required this.termCtrl,
    required this.termLabel,
  });

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Card(
          title: t('مبلغ القرض', 'Loan Amount'),
          suffixIcon: const Icon(Icons.account_balance_wallet_outlined),
          child: TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: t('مثال: 10000', 'e.g. 10000'),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _Card(
          title: t('نسبة الفائدة (%)', 'Interest Rate (%)'),
          suffixIcon: const Icon(Icons.percent),
          child: TextField(
            controller: rateCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: t('مثال: 10', 'e.g. 10'),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _Card(
          title: termLabel,
          suffixIcon: const Icon(Icons.calendar_month_outlined),
          child: TextField(
            controller: termCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: t('مثال: 5', 'e.g. 5'),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? suffixIcon;

  const _Card({
    required this.title,
    required this.child,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 8),
                suffixIcon!,
              ],
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  final String currency;
  final bool isArabic;
  final _CompareResult r;
  final String Function(double v) fmt;

  const _ResultsCard({
    required this.currency,
    required this.isArabic,
    required this.r,
    required this.fmt,
  });

  String t(String ar, String en) => isArabic ? ar : en;

  Color _badgeColor(BuildContext context, bool best) {
    return best ? Colors.green.withOpacity(0.12) : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget metricRow({
      required String label,
      required String aValue,
      required String bValue,
      required bool bestA,
      required bool bestB,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _badgeColor(context, bestA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('A', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(aValue, style: theme.textTheme.bodyMedium),
                        if (bestA) ...[
                          const SizedBox(height: 6),
                          Text(t('الأفضل', 'Best'), style: theme.textTheme.labelSmall?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w800)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _badgeColor(context, bestB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('B', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(bValue, style: theme.textTheme.bodyMedium),
                        if (bestB) ...[
                          const SizedBox(height: 6),
                          Text(t('الأفضل', 'Best'), style: theme.textTheme.labelSmall?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w800)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('نتائج المقارنة', 'Comparison Results'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),

          metricRow(
            label: t('القسط الشهري', 'Monthly Payment'),
            aValue: '${fmt(r.a.monthly)} $currency',
            bValue: '${fmt(r.b.monthly)} $currency',
            bestA: r.bestMonthly == _BestOption.a,
            bestB: r.bestMonthly == _BestOption.b,
          ),
          metricRow(
            label: t('إجمالي المبلغ', 'Total Payment'),
            aValue: '${fmt(r.a.total)} $currency',
            bValue: '${fmt(r.b.total)} $currency',
            bestA: r.bestTotal == _BestOption.a,
            bestB: r.bestTotal == _BestOption.b,
          ),
          metricRow(
            label: t('إجمالي الفائدة', 'Total Interest'),
            aValue: '${fmt(r.a.interest)} $currency',
            bValue: '${fmt(r.b.interest)} $currency',
            bestA: r.bestInterest == _BestOption.a,
            bestB: r.bestInterest == _BestOption.b,
          ),
        ],
      ),
    );
  }
}

enum _BestOption { a, b }

class _LoanSnapshot {
  final double principal;
  final double rate;
  final int months;
  final double monthly;
  final double total;
  final double interest;

  _LoanSnapshot({
    required this.principal,
    required this.rate,
    required this.months,
    required this.monthly,
    required this.total,
    required this.interest,
  });
}

class _CompareResult {
  final _LoanSnapshot a;
  final _LoanSnapshot b;
  final _BestOption bestMonthly;
  final _BestOption bestTotal;
  final _BestOption bestInterest;

  _CompareResult({
    required this.a,
    required this.b,
    required this.bestMonthly,
    required this.bestTotal,
    required this.bestInterest,
  });
}
