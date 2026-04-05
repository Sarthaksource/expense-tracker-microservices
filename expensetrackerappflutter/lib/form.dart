import 'package:expensetrackerappflutter/models/field_config.dart';
import 'package:flutter/material.dart';

class DynamicForm extends StatefulWidget {
  final Map<String, FieldConfig> fields;
  final void Function(Map<String, dynamic>) onSubmit;

  const DynamicForm({super.key, required this.fields, required this.onSubmit});

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _dropdownValues = {};

  @override
  void initState() {
    super.initState();

    for (var entry in widget.fields.entries) {
      if (entry.value.type == "dropdown") {
        _dropdownValues[entry.key] = entry.value.options?.first;
      } else {
        _controllers[entry.key] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final result = <String, dynamic>{};

      for (var entry in widget.fields.entries) {
        if (entry.value.type == "dropdown") {
          result[entry.key] = _dropdownValues[entry.key];
        } else {
          result[entry.key] = _controllers[entry.key]!.text;
        }
      }

      widget.onSubmit(result);
    }
  }

  Widget _buildField(String key, FieldConfig config) {
    if (config.type == "dropdown") {
      return LayoutBuilder(
        builder: (context, constraints) {
          return DropdownMenu<String>(
            initialSelection: _dropdownValues[key],
            width: constraints.maxWidth,
            label: Text(config.label),
            onSelected: (val) => setState(() => _dropdownValues[key] = val),
            dropdownMenuEntries: config.options!
                .map(
                  (e) => DropdownMenuEntry(
                    value: e,
                    label: e,
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(
                        Size(constraints.maxWidth, 48),
                      ),
                      maximumSize: WidgetStateProperty.all(
                        Size(
                          constraints.maxWidth,
                          48,
                        ),
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
      );
    }

    return TextFormField(
      controller: _controllers[key],
      keyboardType: config.type == "number"
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: config.label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';

        if (config.type == "number" && double.tryParse(v) == null) {
          return 'Enter valid number';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.fields.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildField(entry.key, entry.value),
            );
          }),
          const SizedBox(height: 15),
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
