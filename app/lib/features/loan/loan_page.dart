import 'package:flutter/material.dart';

class LoanPage extends StatelessWidget {
  const LoanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Calculator"),
      ),
      body: const Center(
        child: Text(
          "Loan Calculator Page (Coming Soon)",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
