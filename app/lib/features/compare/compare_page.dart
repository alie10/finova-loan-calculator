import 'package:flutter/material.dart';

import '../../core/app.dart';
import '../../core/app_lang.dart';
import '../../widgets/ad_banner.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  bool get _isArabic => FinovaApp.of(context).lang == AppLang.ar;
  String _t(String ar, String en) => _isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final isArabic = _isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_t('المقارنة', 'Compare')),
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
              Text(
                _t('صفحة المقارنة (قيد التحسين)', 'Comparison page (being improved)'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _t(
                  'هنا هنضيف مقارنة بين أكثر من سيناريو قرض/تقسيط (مثلاً: بنك A vs بنك B) مع عرض القسط والإجمالي والفائدة.',
                  'Here we will add comparison between multiple loan scenarios (e.g., Bank A vs Bank B) showing monthly payment, totals, and interest.',
                ),
              ),
              const SizedBox(height: 16),
              const AdBanner(),
            ],
          ),
        ),
      ),
    );
  }
}
