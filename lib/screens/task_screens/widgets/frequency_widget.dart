import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';

class FrequencyWidget extends StatefulWidget {
  final Set<int>? initialSelectedDays;
  final ValueChanged<Set<int>>? onChanged;

  const FrequencyWidget({
    super.key,
    this.initialSelectedDays,
    this.onChanged,
  });

  @override
  State<FrequencyWidget> createState() => _FrequencyWidgetState();
}

class _FrequencyWidgetState extends State<FrequencyWidget> {
  final List<String> _days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  late Set<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = {...?widget.initialSelectedDays};
  }

  void _toggleDay(int index) {
    setState(() {
      if (_selectedDays.contains(index)) {
        _selectedDays.remove(index);
      } else {
        _selectedDays.add(index);
      }
    });

    widget.onChanged?.call(_selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Todas as...', style: tNormal),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_days.length, (index) {
              final isSelected = _selectedDays.contains(index);

              return GestureDetector(
                onTap: () => _toggleDay(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? cMainColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? cMainColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _days[index],
                      style: tNormal.copyWith(
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
