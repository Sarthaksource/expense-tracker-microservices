import 'package:flutter/material.dart';

enum ExpenseFilterType { all, lastMonth, custom }

class ExpenseFilter {
  final ExpenseFilterType type;
  final DateTimeRange? customRange;

  const ExpenseFilter({required this.type, this.customRange});

  bool includes(DateTime date) {
    switch (type) {
      case ExpenseFilterType.all:
        return true;
      case ExpenseFilterType.lastMonth:
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        return date.isAfter(cutoff);
      case ExpenseFilterType.custom:
        if (customRange == null) return true;
        final start = customRange!.start;
        final end = customRange!.end.add(const Duration(days: 1));
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end);
    }
  }

  String get label {
    switch (type) {
      case ExpenseFilterType.all:
        return 'All Time';
      case ExpenseFilterType.lastMonth:
        return 'Last 30 Days';
      case ExpenseFilterType.custom:
        if (customRange == null) return 'Custom Range';
        final s = customRange!.start;
        final e = customRange!.end;
        return '${s.day}/${s.month} – ${e.day}/${e.month}/${e.year}';
    }
  }
}

class ExpenseFilterDropdown extends StatefulWidget {
  final ExpenseFilter currentFilter;
  final ValueChanged<ExpenseFilter> onFilterChanged;

  const ExpenseFilterDropdown({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<ExpenseFilterDropdown> createState() => _ExpenseFilterDropdownState();
}

class _ExpenseFilterDropdownState extends State<ExpenseFilterDropdown> {
  Future<DateTimeRange?> _pickDateRange() async {
    return showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: widget.currentFilter.customRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple.shade900,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _onSelected(ExpenseFilterType? selected) async {
    if (selected == null) return;

    if (selected == ExpenseFilterType.custom) {
      final range = await _pickDateRange();
      if (range != null) {
        widget.onFilterChanged(
          ExpenseFilter(type: ExpenseFilterType.custom, customRange: range),
        );
      }
      return;
    }

    widget.onFilterChanged(ExpenseFilter(type: selected));
  }

  @override
  Widget build(BuildContext context) {
    // Fixed width so it never overflows regardless of label length
    return SizedBox(
      width: 160,
      height: 35,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ExpenseFilterType>(
            value: widget.currentFilter.type,
            isExpanded: true, // fills the fixed SizedBox width
            icon: Icon(Icons.filter_list, color: Colors.purple.shade900, size: 18),
            style: TextStyle(
              color: Colors.purple.shade900,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            items: const [
              DropdownMenuItem(
                value: ExpenseFilterType.all,
                child: Text('All Time'),
              ),
              DropdownMenuItem(
                value: ExpenseFilterType.lastMonth,
                child: Text('Last 30 Days'),
              ),
              DropdownMenuItem(
                value: ExpenseFilterType.custom,
                child: Text('Custom Range …'),
              ),
            ],
            selectedItemBuilder: (_) => [
              _buildSelectedLabel('All Time'),
              _buildSelectedLabel('Last 30 Days'),
              _buildSelectedLabel(widget.currentFilter.label),
            ],
            onChanged: _onSelected,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis, // truncate gracefully instead of overflow
        maxLines: 1,
        style: TextStyle(
          color: Colors.purple.shade900,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}