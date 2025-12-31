import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';

enum DueDateOption {
  today,
  tomorrow,
  custom,
}

class DayWidget extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const DayWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<DayWidget> createState() => _DayWidgetState();
}

class _DayWidgetState extends State<DayWidget> {
  String _customLabel() {
    if (widget.value == null) return 'Escolher';
    return DateFormat('dd/MM').format(widget.value!);
  }

  DueDateOption? get _selectedOption {
    if (widget.value == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final selected = DateTime(
      widget.value!.year,
      widget.value!.month,
      widget.value!.day,
    );

    if (selected == today) return DueDateOption.today;
    if (selected == tomorrow) return DueDateOption.tomorrow;
    return DueDateOption.custom;
  }

  Future<void> _openDatePicker() async {
    final pickedDate = await showDatePicker(
      locale: const Locale('pt'),
      context: context,
      initialDate: widget.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: cMainColor,
              onPrimary: Colors.white,
              onSurface: cBlackColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      widget.onChanged(
        DateTime(pickedDate.year, pickedDate.month, pickedDate.day),
      );
    }
  }

  void _removeDate() {
    widget.onChanged(null);
  }

  void _onSelect(DueDateOption option) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (option) {
      case DueDateOption.today:
        _selectedOption == DueDateOption.today
            ? _removeDate()
            : widget.onChanged(today);
        break;

      case DueDateOption.tomorrow:
        _selectedOption == DueDateOption.tomorrow
            ? _removeDate()
            : widget.onChanged(today.add(const Duration(days: 1)));
        break;

      case DueDateOption.custom:
        _selectedOption == DueDateOption.custom
            ? _removeDate()
            : _openDatePicker();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data de conclusão', style: tLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('Hoje', DueDateOption.today),
            _buildChip('Amanhã', DueDateOption.tomorrow),
            _buildChip(
              _customLabel(),
              DueDateOption.custom,
              icon: Icons.calendar_today_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(
      String label,
      DueDateOption option, {
        IconData? icon,
      }) {
    final isSelected = _selectedOption == option;

    return GestureDetector(
      onTap: () => _onSelect(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cMainColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? cMainColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: tNormal.copyWith(
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
