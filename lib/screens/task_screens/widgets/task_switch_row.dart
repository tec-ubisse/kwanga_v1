import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/text_style.dart';

class TaskSwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final Widget trailing;
  final ValueChanged<bool> onChanged;

  const TaskSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.trailing,
    required this.onChanged,
  });

  factory TaskSwitchRow.reminder({
    required bool enabled,
    required TimeOfDay time,
    required ValueChanged<bool> onChanged,
    required ValueChanged<TimeOfDay> onTimePicked,
  }) {
    return TaskSwitchRow(
      label: 'Lembrete',
      value: enabled,
      onChanged: onChanged,
      trailing: Builder(
        builder: (context) => InkWell(
          onTap: enabled
              ? () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null) onTimePicked(picked);
          }
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.alarm, size: 20, color: Colors.grey),
              const SizedBox(width: 6),
              Text(time.format(context), style: tNormal.copyWith(fontSize: 12.0)),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  factory TaskSwitchRow.frequency({
    required bool enabled,
    required String frequency,
    required ValueChanged<bool> onChanged,
    required ValueChanged<String> onFrequencySelected,
  }) {
    return TaskSwitchRow(
      label: 'Frequência',
      value: enabled,
      onChanged: onChanged,
      trailing: Builder(
        builder: (context) => InkWell(
          onTap: enabled
              ? () async {
            final options = ['Todos os dias', 'Dias úteis', 'Fins de semana'];
            final selected = await showModalBottomSheet<String>(
              context: context,
              builder: (sheetCtx) => ListView(
                children: options
                    .map(
                      (o) => ListTile(
                    title: Text(o),
                    onTap: () => Navigator.pop(sheetCtx, o),
                  ),
                )
                    .toList(),
              ),
            );
            if (selected != null) onFrequencySelected(selected);
          }
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(frequency, style: tNormal.copyWith(fontSize: 12.0)),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.blueAccent,
          ),
          Text(
            label,
            style: TextStyle(
              color: value ? Colors.black : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: value ? 1 : 0.4,
            child: trailing,
          ),
        ],
      ),
    );
  }
}
