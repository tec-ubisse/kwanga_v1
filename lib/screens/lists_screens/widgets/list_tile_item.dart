import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/screens/task_screens/list_task_screen.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/providers/progress_for_list_provider.dart';

class ListTileItem extends ConsumerWidget {
  final ListModel listModel;
  final bool canViewChildren;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isEditable;
  final bool showProgress;

  const ListTileItem({
    super.key,
    required this.listModel,
    required this.canViewChildren,
    required this.isSelected,
    required this.isEditable,
    this.onTap,
    this.onLongPress,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressForListProvider(listModel.id));

    final isActionList = listModel.listType == "action";
    final total = progress['total'] ?? 0;
    final completed = progress['completed'] ?? 0;
    final entryCount = total == 1 ? "item" : "itens";

    return GestureDetector(
      onTap: () async {
        onTap?.call();

        if (canViewChildren) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ListTasksScreen(listModel: listModel),
            ),
          );
        }
      },
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xffEAEFF4),
          // borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // TEXTOS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listModel.description,
                  style: tTitle.copyWith(
                    color: isSelected ? cWhiteColor : cBlackColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                isEditable
                    ? Text(
                  isActionList
                      ? "$completed / $total concluídas"
                      : "$total $entryCount de entrada",
                  style: tNormal.copyWith(
                    color: isSelected
                        ? cWhiteColor
                        : Colors.grey[700],
                  ),
                )
                    : Text(
                  listModel.listType == 'entry'
                      ? "Lista de Entradas"
                      : "Lista de Acções",
                  style: tNormal,
                ),
              ],
            ),

            // PROGRESSO
            if (showProgress && isActionList && total > 0)
              SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  value: completed / total,
                  backgroundColor: cSecondaryColor.withAlpha(50),
                  color: cSecondaryColor.withAlpha(200),
                  strokeWidth: 4,
                ),
              ),
            if (showProgress && isActionList && total == 0)
              SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  value: 0.0,
                  backgroundColor: cSecondaryColor.withAlpha(50),
                  color: cSecondaryColor.withAlpha(200),
                  strokeWidth: 4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
