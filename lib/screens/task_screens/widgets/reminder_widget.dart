import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';

class ReminderWidget extends StatelessWidget {
  final bool enabled;
  final TimeOfDay time;

  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const ReminderWidget({
    super.key,
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onTimeChanged,
  });

  static const List<_ReminderOption> _presetOptions = [
    _ReminderOption(
      label: '07h',
      time: TimeOfDay(hour: 7, minute: 0),
      icon: Icons.notifications_none,
    ),
    _ReminderOption(
      label: '12h',
      time: TimeOfDay(hour: 12, minute: 0),
      icon: Icons.notifications_none,
    ),
    _ReminderOption(
      label: '15h',
      time: TimeOfDay(hour: 15, minute: 0),
      icon: Icons.notifications_none,
    ),
  ];

  String _customLabel() {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _isCustomTime() {
    return !_presetOptions.any((o) => o.time == time);
  }

  bool _isSelected(_ReminderOption option) {
    if (!enabled) return false;

    if (option.time != null) {
      return option.time == time;
    }

    return _isCustomTime();
  }

  void _removeReminder() {
    onToggle(false); // 🔑 único ponto de remoção
  }

  Future<void> _openTimePicker(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      onToggle(true);
      onTimeChanged(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      ..._presetOptions,
      _ReminderOption(
        label: enabled && _isCustomTime() ? _customLabel() : 'Definir',
        icon: Icons.schedule,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lembrete', style: tLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = _isSelected(option);

            return GestureDetector(
              onTap: () {
                // CUSTOM
                if (option.time == null) {
                  if (enabled && _isCustomTime()) {
                    _removeReminder(); // 🔥 remove custom
                  } else {
                    _openTimePicker(context);
                  }
                  return;
                }

                // PRESET
                if (isSelected) {
                  _removeReminder(); // 🔥 remove preset
                } else {
                  onToggle(true);
                  onTimeChanged(option.time!);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
          }).toList(),
        ),
      ],
    );
  }
}

class _ReminderOption {
  final String label;
  final TimeOfDay? time;
  final IconData? icon;

  const _ReminderOption({
    required this.label,
    this.time,
    this.icon,
  });
}
