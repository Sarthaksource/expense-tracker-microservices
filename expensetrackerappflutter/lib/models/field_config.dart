class FieldConfig {
  final String label;
  final String type; // "text", "number", "dropdown"
  final List<String>? options;

  FieldConfig({
    required this.label,
    this.type = "text",
    this.options,
  });
}