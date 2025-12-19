import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

enum DueDateOption {
  today,
  tomorrow,
  custom,
}

class DayWidget extends StatefulWidget {
  const DayWidget({super.key});

  @override
  State<DayWidget> createState() => _DayWidgetState();
}

class _DayWidgetState extends State<DayWidget> {
  DueDateOption? _selectedOption;

  Future<void> _openDatePicker() async {
    final pickedDate = await showDatePicker(
      locale: const Locale('pt'),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: cMainColor,
              onPrimary: Colors.white,
              onSurface: cBlackColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: cMainColor, // OK / Cancelar
              ),
            ),

          ),
          child: child!,
        );
      }
    );

    if (pickedDate != null) {
      setState(() {
        _selectedOption = DueDateOption.custom;
      });
    }
  }

  void _onSelect(DueDateOption option) {
    if (option == DueDateOption.custom) {
      _openDatePicker();
      return;
    }

    setState(() {
      if (_selectedOption == option) {
        _selectedOption = null;
      } else {
        _selectedOption = option;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data de conclusão', style: tNormal),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(
              label: 'Hoje',
              option: DueDateOption.today,
            ),
            _buildChip(
              label: 'Amanhã',
              option: DueDateOption.tomorrow,
            ),
            _buildChip(
              label: 'Escolher',
              icon: Icons.calendar_today_outlined,
              option: DueDateOption.custom,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required DueDateOption option,
    IconData? icon,
  }) {
    final bool isSelected = _selectedOption == option;

    return GestureDetector(
      onTap: () => _onSelect(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
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
