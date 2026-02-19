import 'package:flutter/material.dart';

class SavingsPage extends StatelessWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Savings Calculator"),
      ),
      body: const Center(
        child: Text(
          "Savings Calculator Page (Coming Soon)",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
