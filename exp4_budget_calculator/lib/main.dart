import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const BudgetCalculator(),
    );
  }
}

// 1. The Widget class
class BudgetCalculator extends StatefulWidget {
  const BudgetCalculator({super.key});

  @override
  State<BudgetCalculator> createState() => _BudgetCalculatorState();
}

// 2. The State class
class _BudgetCalculatorState extends State<BudgetCalculator> {
  // State variables
  final _formKey = GlobalKey<FormState>();

  final _incomeController = TextEditingController();
  final _rentController = TextEditingController();
  final _foodController = TextEditingController();
  final _transportController = TextEditingController();
  final _othersController = TextEditingController();

  String _result = '';
  String _message = '';
  double _totalExpenses = 0;
  Color _resultColor = Colors.black;

  @override
  void dispose() {
    _incomeController.dispose();
    _rentController.dispose();
    _foodController.dispose();
    _transportController.dispose();
    _othersController.dispose();
    super.dispose();
  }

  // Validator for Monthly Income (must be positive)
  String? _validateIncome(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    final income = double.tryParse(value);
    if (income == null) {
      return 'Enter a valid number';
    }
    if (income <= 0) {
      return 'Income must be a positive number';
    }
    return null;
  }

  // Validator for expenses (must be zero or more)
  String? _validateExpense(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty (enter 0 if none)';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Enter a valid number';
    }
    if (amount < 0) {
      return 'Amount cannot be negative';
    }
    return null;
  }

  // Function called when the button is pressed
  void _calculateBalance() {
    if (_formKey.currentState!.validate()) {
      double income = double.parse(_incomeController.text);
      double rent = double.parse(_rentController.text);
      double food = double.parse(_foodController.text);
      double transport = double.parse(_transportController.text);
      double others = double.parse(_othersController.text);

      double expenses = rent + food + transport + others;
      double balance = income - expenses;

      setState(() {
        _totalExpenses = expenses;
        _result = 'Remaining Balance = ₹${balance.toStringAsFixed(2)}';
        if (balance < 0) {
          _resultColor = Colors.red;
          _message = 'Warning: You are overspending!';
        } else if (balance == 0) {
          _resultColor = Colors.orange;
          _message = 'You have spent your entire income. No savings this month.';
        } else {
          _resultColor = Colors.green;
          _message = 'Great! You are within your budget.';
        }
      });
    } else {
      setState(() {
        _result = '';
        _message = '';
      });
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
    _incomeController.clear();
    _rentController.clear();
    _foodController.clear();
    _transportController.clear();
    _othersController.clear();
    setState(() {
      _result = '';
      _message = '';
      _totalExpenses = 0;
    });
  }

  // Reusable builder for each input field
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          prefixText: '₹ ',
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Budget Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter your monthly income and expenses',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    controller: _incomeController,
                    label: 'Monthly Income',
                    icon: Icons.account_balance_wallet,
                    validator: _validateIncome,
                  ),
                  _buildField(
                    controller: _rentController,
                    label: 'Rent / EMI',
                    icon: Icons.home,
                    validator: _validateExpense,
                  ),
                  _buildField(
                    controller: _foodController,
                    label: 'Food Expenses',
                    icon: Icons.restaurant,
                    validator: _validateExpense,
                  ),
                  _buildField(
                    controller: _transportController,
                    label: 'Transport Expenses',
                    icon: Icons.directions_bus,
                    validator: _validateExpense,
                  ),
                  _buildField(
                    controller: _othersController,
                    label: 'Other Expenses',
                    icon: Icons.shopping_bag,
                    validator: _validateExpense,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _calculateBalance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Calculate Balance'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _reset,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Result display
                  if (_result.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _resultColor.withValues(alpha: 0.1),
                        border: Border.all(color: _resultColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total Expenses = ₹${_totalExpenses.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _result,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _resultColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _resultColor == Colors.red
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle,
                                color: _resultColor,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _message,
                                  style: TextStyle(fontSize: 16, color: _resultColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}