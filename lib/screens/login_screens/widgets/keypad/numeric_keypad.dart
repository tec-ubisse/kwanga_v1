import 'package:flutter/material.dart';
import '../../../../custom_themes/text_style.dart';

class NumericKeypad extends StatelessWidget {
  final void Function(String) onNumberTap;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  const NumericKeypad({
    super.key,
    required this.onNumberTap,
    required this.onDelete, required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      '1','2','3',
      '4','5','6',
      '7','8','9',
      'clear','0','del',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (_, index) {
        final key = keys[index];

        if (key == 'del') {
          return _iconKey(Icons.backspace, onDelete);
        }

        if (key == 'clear') {
          return _iconKey(Icons.close, onClear);
        }

        return _numberKey(key);
      },
    );
  }

  Widget _numberKey(String value) {
    return GestureDetector(
      onTap: () => onNumberTap(value),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(value, style: tNumberText),
      ),
    );
  }

  Widget _iconKey(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.grey.shade700),
      ),
    );
  }
}
