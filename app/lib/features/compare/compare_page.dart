import 'package:flutter/material.dart';

class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compare Loans"),
      ),
      body: const Center(
        child: Text(
          "Compare Loans Page (Coming Soon)",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
