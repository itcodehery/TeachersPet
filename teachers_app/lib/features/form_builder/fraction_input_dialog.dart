import 'package:flutter/material.dart';

class FractionInputDialog extends StatefulWidget {
  const FractionInputDialog({super.key});

  @override
  State<FractionInputDialog> createState() => _FractionInputDialogState();
}

class _FractionInputDialogState extends State<FractionInputDialog> {
  final _wholeNumberController = TextEditingController();
  final _numeratorController = TextEditingController();
  final _denominatorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Fraction'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _wholeNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Whole Number (optional)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeratorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Numerator',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a numerator';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _denominatorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Denominator',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a denominator';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.tryParse(value) == 0) {
                  return 'Denominator cannot be zero';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final wholeNumber = _wholeNumberController.text;
              final numerator = _numeratorController.text;
              final denominator = _denominatorController.text;
              String result = '';
              if (wholeNumber.isNotEmpty) {
                result += '$wholeNumber ';
              }
              result += '{$numerator/$denominator}';
              Navigator.of(context).pop(result);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
