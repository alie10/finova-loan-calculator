import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/ads/ad_service.dart';
import '../../core/app.dart'; // يحتوي FinovaApp + AppLang (حسب مشروعك الحالي)

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final _amountCtrl = TextEditingController(text: '10000');
  final _rateCtrl = TextEditingController(text: '10');
  final _termCtrl = TextEditingController(text: '5');

  bool _termInYears = true;

  String _currency = 'USD';
  final List<String> _currencies = const ['USD', 'EGP', 'SAR', 'AED', 'EUR'];

  double? _monthlyPayment;
  double? _totalPayment;
  double? _totalInterest;

  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;

  String t(String ar, String en) => _isArabic ? ar : en;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _termCtrl.dispose();
    super.dispose();
  }

  double _parseDouble(String s) => double.tryParse(s.trim().replaceAll(',', '')) ?? 0.0;

  int _parseInt(String s) => int.tryParse(s.trim()) ?? 0;

  void _reset() {
    setState(() {
      _amountCtrl.text = '10000';
      _rateCtrl.text = '10';
      _termCtrl.text = '5';
      _termInYears = true;
      _currency = 'USD';
      _monthlyPayment = null;
      _totalPayment = null;
      _totalInterest = null;
    });
  }

  double _calcEmi({
    required double principal,
    required double annualRatePercent,
    required int months,
  }) {
    if (principal <= 0 || months <= 0) return 0.0;

    final r = (annualRatePercent / 100.0) / 12.0; // monthly rate
    if (r <= 0) return principal / months;

    final powVal = pow(1 + r, months).toDouble();
    final emi = principal * r * powVal / (powVal - 1);
    return emi.isFinite ? emi : 0.0;
  }

  Future<void> _calculate() async {
    final principal = _parseDouble(_amountCtrl.text);
    final annualRate = _parseDouble(_rateCtrl.text);
    final term = _parseInt(_termCtrl.text);

    if (principal <= 0 || term <= 0 || annualRate < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('من فضلك أدخل أرقام صحيحة.', 'Please enter valid numbers.'),
          ),
        ),
      );
      return;
    }

    final months = _termInYears ? term * 12 : term;

    final monthly = _calcEmi(principal: principal, annualRatePercent: annualRate, months: months);
    final total = monthly * months;
    final interest = total - principal;

    setState(() {
      _monthlyPayment = monthly;
      _totalPayment = total;
      _totalInterest = interest;
    });

    // ✅ عرض Interstitial بذكاء (مش كل مرة)
    await AdService.instance.maybeShowInterstitial();
  }

  String _fmt(double v) {
    // تنسيق بسيط بدون حزم إضافية
    final s = v.toStringAsFixed(2);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: ListView(
          children: [
            Row(
              children: [
                const Icon(Icons.public),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('حاسبة القرض', 'Loan Calculator'),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // العملة
            _CardField(
              title: t('العملة', 'Currency'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _currency,
                  items: _currencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _currency = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // مبلغ القرض
            _CardField(
              title: t('مبلغ القرض', 'Loan Amount'),
              suffixIcon: const Icon(Icons.account_balance_wallet_outlined),
              child: TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: t('مثال: 10000', 'e.g. 10000'),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // نسبة الفائدة
            _CardField(
              title: t('نسبة الفائدة (%)', 'Interest Rate (%)'),
              suffixIcon: const Icon(Icons.percent),
              child: TextField(
                controller: _rateCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: t('مثال: 10', 'e.g. 10'),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // المدة + سنوات/شهور
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _CardField(
                    title: t('المدة', 'Term'),
                    suffixIcon: const Icon(Icons.calendar_month_outlined),
                    child: TextField(
                      controller: _termCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: t('مثال: 5', 'e.g. 5'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _CardField(
                    title: t('نوع المدة', 'Term Type'),
                    child: SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(t('شهور', 'Months')),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(t('سنوات', 'Years')),
                        ),
                      ],
                      selected: {_termInYears},
                      onSelectionChanged: (s) {
                        setState(() => _termInYears = s.first);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // أزرار
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
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate_outlined),
                    label: Text(t('احسب', 'Calculate')),
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

            const SizedBox(height: 10),
            Text(
              t('ملاحظة: يمكنك وضع 0% لحساب التقسيط بدون فائدة.', 'Note: You can enter 0% to calculate installments without interest.'),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),

            const SizedBox(height: 18),

            // النتائج
            if (_monthlyPayment != null) ...[
              _ResultCard(
                currency: _currency,
                monthly: _monthlyPayment!,
                total: _totalPayment ?? 0,
                interest: _totalInterest ?? 0,
                isArabic: _isArabic,
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

class _CardField extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? suffixIcon;

  const _CardField({
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

class _ResultCard extends StatelessWidget {
  final String currency;
  final double monthly;
  final double total;
  final double interest;
  final bool isArabic;
  final String Function(double v) fmt;

  const _ResultCard({
    required this.currency,
    required this.monthly,
    required this.total,
    required this.interest,
    required this.isArabic,
    required this.fmt,
  });

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium,
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
        children: [
          Text(
            t('النتائج', 'Results'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          row(t('القسط الشهري', 'Monthly Payment'), '${fmt(monthly)} $currency'),
          row(t('إجمالي المبلغ', 'Total Payment'), '${fmt(total)} $currency'),
          row(t('إجمالي الفائدة', 'Total Interest'), '${fmt(interest)} $currency'),
        ],
      ),
    );
  }
}
