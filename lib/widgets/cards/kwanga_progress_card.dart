import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import 'package:percent_indicator/percent_indicator.dart';

class KwangaProgressCard<T> extends StatelessWidget {
  final T item;
  final String Function(T) getTitle;
  final String Function(T) getId;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KwangaProgressCard({
    super.key,
    required this.item,
    required this.getTitle,
    required this.getId,
    required this.progress,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);
    final percent = (safeProgress * 100).round();

    return Slidable(
      key: ValueKey(getId(item)),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: cSecondaryColor,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            borderRadius: BorderRadius.zero,
          ),
          SlidableAction(
            onPressed: (_) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar Exclusão'),
                  content: const Text(
                      'Tem certeza que deseja excluir este item?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                onDelete();
              }
            },
            backgroundColor: cTertiaryColor,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            borderRadius: BorderRadius.zero,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: Colors.deepPurple,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  getTitle(item),
                  style: tNormal,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              CircularPercentIndicator(
                radius: 28,
                lineWidth: 10,
                percent: safeProgress,
                center: Text(
                  '$percent%',
                  style: tSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                progressColor: cMainColor,
                backgroundColor: Colors.grey.shade300,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
        ),
      ),
    );
  }
}