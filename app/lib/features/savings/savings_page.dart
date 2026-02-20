import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/ads/ad_service.dart';
import '../../core/app.dart'; // يحتوي FinovaApp + AppLang

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final _monthlyCtrl = TextEditingController(text: '1000');
  final _rateCtrl = TextEditingController(text: '10');
  final _yearsCtrl = TextEditingController(text: '5');

  String _currency = 'USD';
  final List<String> _currencies = const ['USD', 'EGP', 'SAR', 'AED', 'EUR'];

  _SavingsResult? _result;

  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;
  String t(String ar, String en) => _isArabic ? ar : en;

  @override
  void dispose() {
    _monthlyCtrl.dispose();
    _rateCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  double _parseDouble(String s) => double.tryParse(s.trim().replaceAll(',', '')) ?? 0.0;
  int _parseInt(String s) => int.tryParse(s.trim()) ?? 0;

  String _fmt(double v) => v.toStringAsFixed(2);

  void _reset() {
    setState(() {
      _monthlyCtrl.text = '1000';
      _rateCtrl.text = '10';
      _yearsCtrl.text = '5';
      _currency = 'USD';
      _result = null;
    });
  }

  // حساب قيمة الادخار المستقبلية (استثمار بمساهمة شهرية)
  // نفترض فائدة سنوية مركبة شهرياً
  void _calculate() async {
    final monthly = _parseDouble(_monthlyCtrl.text);
    final annualRate = _parseDouble(_rateCtrl.text);
    final years = _parseInt(_yearsCtrl.text);

    if (monthly <= 0 || years <= 0 || annualRate < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('من فضلك أدخل أرقام صحيحة.', 'Please enter valid numbers.'))),
      );
      return;
    }

    final months = years * 12;
    final r = (annualRate / 100.0) / 12.0;

    double futureValue;
    if (r <= 0) {
      futureValue = monthly * months;
    } else {
      // FV of annuity: P * (( (1+r)^n - 1 ) / r)
      final powVal = pow(1 + r, months).toDouble();
      futureValue = monthly * ((powVal - 1) / r);
    }

    final totalContrib = monthly * months;
    final gain = futureValue - totalContrib;

    setState(() {
      _result = _SavingsResult(
        monthly: monthly,
        years: years,
        months: months,
        annualRate: annualRate,
        totalContrib: totalContrib,
        futureValue: futureValue,
        gain: gain,
      );
    });

    // ✅ عرض Interstitial بذكاء بعد الحساب
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
                const Icon(Icons.savings_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('الادخار', 'Savings'),
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

            _Card(
              title: t('المبلغ الشهري', 'Monthly Amount'),
              suffixIcon: const Icon(Icons.payments_outlined),
              child: TextField(
                controller: _monthlyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: t('مثال: 1000', 'e.g. 1000'),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _Card(
              title: t('العائد السنوي (%)', 'Annual Return (%)'),
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
            const SizedBox(height: 10),

            _Card(
              title: t('المدة (سنوات)', 'Term (Years)'),
              suffixIcon: const Icon(Icons.calendar_month_outlined),
              child: TextField(
                controller: _yearsCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: t('مثال: 5', 'e.g. 5'),
                  border: InputBorder.none,
                ),
              ),
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
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate_outlined),
                    label: Text(t('احسب', 'Calculate')),
                  ),
                ),
              ],
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
  final _SavingsResult r;
  final String Function(double v) fmt;

  const _ResultsCard({
    required this.currency,
    required this.isArabic,
    required this.r,
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
              child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Text(value, style: theme.textTheme.bodyMedium),
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
          Text(t('نتائج الادخار', 'Savings Results'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          row(t('إجمالي المساهمات', 'Total Contributions'), '${fmt(r.totalContrib)} $currency'),
          row(t('القيمة المستقبلية', 'Future Value'), '${fmt(r.futureValue)} $currency'),
          row(t('الربح/الزيادة', 'Gain'), '${fmt(r.gain)} $currency'),
          const SizedBox(height: 6),
          Text(
            t(
              'ملاحظة: هذه حسابات تقديرية وقد تختلف النتائج حسب طريقة الفائدة/الاستثمار.',
              'Note: These are estimates and results may vary depending on investment/interest method.',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SavingsResult {
  final double monthly;
  final int years;
  final int months;
  final double annualRate;
  final double totalContrib;
  final double futureValue;
  final double gain;

  _SavingsResult({
    required this.monthly,
    required this.years,
    required this.months,
    required this.annualRate,
    required this.totalContrib,
    required this.futureValue,
    required this.gain,
  });
}
