import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';

class ReminderWidget extends StatefulWidget {
  const ReminderWidget({super.key});

  @override
  State<ReminderWidget> createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
  int? _selectedIndex;

  final List<_ReminderOption> _options = const [
    _ReminderOption(label: '07h', icon: Icons.notifications_none),
    _ReminderOption(label: '12h', icon: Icons.notifications_none),
    _ReminderOption(label: '15h', icon: Icons.notifications_none),
    _ReminderOption(label: 'Definir', icon: Icons.schedule),
  ];

  Future<void> _openTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // força formato 24h
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedIndex = 3; // índice do "Definir"
      });
    }
  }

  void _onSelect(int index) {
    // Se for "Definir"
    if (index == 3) {
      _openTimePicker();
      return;
    }

    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lembrete', style: tNormal),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_options.length, (index) {
            final option = _options[index];
            final isSelected = _selectedIndex == index;

            return GestureDetector(
              onTap: () => _onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? cMainColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? cMainColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.icon != null) ...[
                      Icon(
                        option.icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      option.label,
                      style: tNormal.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ReminderOption {
  final String label;
  final IconData? icon;

  const _ReminderOption({
    required this.label,
    this.icon,
  });
}
