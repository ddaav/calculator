import 'package:flutter/material.dart';

class Calculatorscreen extends StatefulWidget {
  const Calculatorscreen({super.key});

  @override
  State<Calculatorscreen> createState() => _CalculatorscreenState();
}

class _CalculatorscreenState extends State<Calculatorscreen> {
  static const List<String> _buttons = [
    'C', '*', '/', '<-',
    '1', '2', '3', '+',
    '4', '5', '6', '-',
    '7', '8', '9', '*',
    '%', '0', '.', '=',
  ];

  String _display = '';
  double _firstOperand = 0;
  String _operator = '';
  bool _waitingForSecondOperand = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'C') {
        // Clear everything
        _display = '';
        _firstOperand = 0;
        _operator = '';
        _waitingForSecondOperand = false;

      } else if (label == '<-') {
        // Backspace
        if (_display.isNotEmpty) {
          _display = _display.substring(0, _display.length - 1);
        }

      } else if ('+-*/'.contains(label)) {
        // Operator pressed
        if (_display.isEmpty) return;
        _firstOperand = double.tryParse(_display) ?? 0;
        _operator = label;
        _waitingForSecondOperand = true;
        // Show the operator in the display
        _display += ' $label ';

      } else if (label == '%') {
        // Percentage: divide current number by 100
        if (_display.isEmpty) return;
        final value = double.tryParse(_display);
        if (value != null) {
          _display = _formatResult(value / 100);
        }

      } else if (label == '=') {
        // Calculate result
        if (_operator.isEmpty || !_waitingForSecondOperand) return;

        // Split display to extract the second operand
        final parts = _display.split(' $_operator ');
        if (parts.length < 2 || parts[1].isEmpty) return;

        final secondOperand = double.tryParse(parts[1]);
        if (secondOperand == null) return;

        double result;
        switch (_operator) {
          case '+':
            result = _firstOperand + secondOperand;
            break;
          case '-':
            result = _firstOperand - secondOperand;
            break;
          case '*':
            result = _firstOperand * secondOperand;
            break;
          case '/':
            if (secondOperand == 0) {
              _display = 'Error: ÷ by 0';
              _operator = '';
              _waitingForSecondOperand = false;
              return;
            }
            result = _firstOperand / secondOperand;
            break;
          default:
            return;
        }

        _display = _formatResult(result);
        _operator = '';
        _waitingForSecondOperand = false;

      } else {
        // Number or decimal point
        if (label == '.') {
          // Prevent multiple decimals in the current operand
          final parts = _operator.isNotEmpty
              ? _display.split(' $_operator ')
              : [_display];
          final currentPart = parts.last;
          if (currentPart.contains('.')) return;
          if (currentPart.isEmpty) {
            _display += '0';
          }
        }
        _display += label;
      }
    });
  }

  /// Formats a double result — removes trailing zeros for whole numbers
  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    // Limit to 8 decimal places to avoid floating-point noise
    return double.parse(value.toStringAsFixed(8)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator App'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              padding: const EdgeInsets.all(12),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _display.isEmpty ? '0' : _display,
                style: const TextStyle(fontSize: 28, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
                children: [
                  for (final label in _buttons)
                    ElevatedButton(
                      onPressed: () => _onButtonPressed(label),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColor(label),
                        foregroundColor: _getTextColor(label),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getButtonColor(String label) {
    if (label == '=') return Colors.blue;
    if (label == 'C') return Colors.red.shade300;
    if ('+-*/'.contains(label)) return Colors.orange.shade300;
    return const Color(0xFFEDEDED);
  }

  Color _getTextColor(String label) {
    if (label == '=' || label == 'C' || '+-*/'.contains(label)) {
      return Colors.white;
    }
    return Colors.black;
  }
}