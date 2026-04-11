import 'package:flutter/material.dart';
import 'package:expensetrackerappflutter/services/permission_service.dart';

class ProfileForm extends StatefulWidget {
  final List<String> currencyOptions;
  final bool initialReadPermission;
  final void Function(Map<String, dynamic>) onSubmit;
  final String? initialAmount;
  final String? initialCurrencyCode;

  const ProfileForm({
    super.key,
    required this.currencyOptions,
    required this.initialReadPermission,
    required this.onSubmit,
    this.initialAmount,
    this.initialCurrencyCode
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();
  String? _selectedCurrencyCode;
  late bool _readMessagesPermission;

  @override
  void initState() {
    super.initState();
    
    _amountController.text = widget.initialAmount ?? "";

    if (widget.initialCurrencyCode != null && widget.currencyOptions.contains(widget.initialCurrencyCode)) {
      _selectedCurrencyCode = widget.initialCurrencyCode;
    } else if (widget.currencyOptions.isNotEmpty) {
      _selectedCurrencyCode = widget.currencyOptions.first;
    }
    
    _readMessagesPermission = widget.initialReadPermission; 
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        "amountLimit": _amountController.text,
        "currencyCode": _selectedCurrencyCode,
        "readMessagesPermission": _readMessagesPermission,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Amount Limit Field
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount Limit",
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Enter valid number';
                return null;
              },
            ),
          ),

          // 2. Currency Dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return DropdownMenu<String>(
                  initialSelection: _selectedCurrencyCode,
                  width: constraints.maxWidth,
                  label: const Text("Currency"),
                  onSelected: (val) => setState(() => _selectedCurrencyCode = val),
                  dropdownMenuEntries: widget.currencyOptions
                      .map(
                        (e) => DropdownMenuEntry(
                          value: e,
                          label: e,
                          style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all(
                              Size(constraints.maxWidth, 48),
                            ),
                            maximumSize: WidgetStateProperty.all(
                              Size(constraints.maxWidth, 48),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
          ),

          // 3. Message Permission Toggle
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Read expenses from messages",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: _readMessagesPermission,
                      activeThumbColor: Colors.purple.shade900,
                      onChanged: (bool value) async {
                        if (value) {
                          bool permitted = await requestSmsPermission(); 
                          if (!mounted) return;
                          if (permitted) {
                            setState(() {
                              _readMessagesPermission = true;
                            });
                          } else {
                            setState(() {
                              _readMessagesPermission = false;
                            });
                            
                            // if (mounted) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(
                            //       content: Text("SMS permission is required to read expenses."),
                            //     ),
                            //   );
                            // }
                          }
                        } else {
                          setState(() {
                            _readMessagesPermission = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Submit Button
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.purple.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
            ),
            onPressed: _handleSubmit,
            child: const Text(
              "Save",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}