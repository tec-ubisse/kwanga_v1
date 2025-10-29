import 'package:flutter/material.dart';

class DateOptionSelector extends StatefulWidget {
  final ValueChanged<DateTime?> onDateChanged;
  const DateOptionSelector({super.key, required this.onDateChanged});

  @override
  State<DateOptionSelector> createState() => _DateOptionSelectorState();
}

class _DateOptionSelectorState extends State<DateOptionSelector> {
  final _options = ['Sem Data', 'Hoje', 'Amanhã', 'Data específica'];
  String _selected = 'Sem Data';
  DateTime? _customDate;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selected = 'Data específica';
        _customDate = picked;
      });
      widget.onDateChanged(picked);
    }
  }

  void _update(String opt) {
    setState(() => _selected = opt);
    final now = DateTime.now();
    widget.onDateChanged(
      opt == 'Hoje'
          ? DateTime(now.year, now.month, now.day)
          : opt == 'Amanhã'
          ? DateTime(now.year, now.month, now.day + 1)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _options.map((option) {
        final selected = option == _selected;
        return SwitchListTile(
          title: Text(option),
          value: selected,
          onChanged: (_) => option == 'Data específica'
              ? _pickDate(context)
              : _update(option),
        );
      }).toList(),
    );
  }
}
