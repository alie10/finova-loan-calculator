import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const FinovaApp());
}

class FinovaApp extends StatelessWidget {
  const FinovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finova - Loan Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoanCalculatorPage(),
    );
  }
}

class LoanCalculatorPage extends StatefulWidget {
  const LoanCalculatorPage({super.key});

  @override
  State<LoanCalculatorPage> createState() => _LoanCalculatorPageState();
}

class _LoanCalculatorPageState extends State<LoanCalculatorPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController yearsController = TextEditingController();

  double monthlyPayment = 0;
  double totalPayment = 0;
  double totalInterest = 0;

  void calculateEMI() {
    double principal = double.tryParse(amountController.text) ?? 0;
    double annualRate = double.tryParse(rateController.text) ?? 0;
    double years = double.tryParse(yearsController.text) ?? 0;

    double monthlyRate = annualRate / 12 / 100;
    double months = years * 12;

    if (principal > 0 && monthlyRate > 0 && months > 0) {
      double emi = (principal *
              monthlyRate *
              pow(1 + monthlyRate, months)) /
          (pow(1 + monthlyRate, months) - 1);

      setState(() {
        monthlyPayment = emi;
        totalPayment = emi * months;
        totalInterest = totalPayment - principal;
      });
    }
  }

  Widget buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finova - Loan Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildInput("Loan Amount", amountController),
            const SizedBox(height: 12),
            buildInput("Interest Rate (%)", rateController),
            const SizedBox(height: 12),
            buildInput("Loan Term (Years)", yearsController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateEMI,
              child: const Text("Calculate"),
            ),
            const SizedBox(height: 20),
            Text("Monthly Payment: ${monthlyPayment.toStringAsFixed(2)}"),
            Text("Total Payment: ${totalPayment.toStringAsFixed(2)}"),
            Text("Total Interest: ${totalInterest.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}