import 'package:flutter/material.dart';

import '../../core/app.dart';
import '../../core/app_lang.dart' as lang;

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  bool get _isArabic => FinovaApp.of(context).lang == lang.AppLang.ar;
  String t(String ar, String en) => _isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('المقارنة', 'Compare')),
        actions: [
          IconButton(
            onPressed: () => FinovaApp.of(context).toggle(),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              t(
                'صفحة المقارنة جاهزة كبداية — ويمكن تطويرها لاحقًا لإدخال خيارين ومقارنة القسط والإجمالي.',
                'Comparison page base is ready — can be improved later to compare two options.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
