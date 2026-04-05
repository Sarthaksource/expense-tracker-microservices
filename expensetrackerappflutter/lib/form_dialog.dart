import 'package:flutter/material.dart';

class ExpenseFormDialog extends StatefulWidget {
  const ExpenseFormDialog({super.key});

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: SingleChildScrollView(
        // ← fix
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _merchantController,
                decoration: const InputDecoration(labelText: 'Merchant Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Enter valid number';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: _pickDateTime,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(top: 8, bottom: 0),
                      alignment: Alignment.centerLeft,
                      overlayColor: Colors.transparent,
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Pick Date'
                          : _selectedDate.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Divider(height: 1, color: Colors.black45),
                ],
              ),

              SizedBox(height: 4),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'If not selected, current datetime will be used',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 15, color: Colors.purple.shade900),
          ),
        ),
        TextButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final result = {
              "merchant": _merchantController.text,
              "amount": double.parse(_amountController.text).toString(),
              "date": _selectedDate?.toUtc().toIso8601String(),
            };

            Navigator.pop(context, result);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.purple.shade900,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          ),
          child: Text(
            'Add',
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
