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

  const ListTileItem({
    super.key,
    required this.listModel,
    required this.canViewChildren,
    required this.isSelected,
    required this.isEditable,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressForListProvider(listModel.id));

    final isActionList = listModel.listType == "action";

    final total = progress['total'] ?? 0;
    final completed = progress['completed'] ?? 0;

    return ListTile(
      tileColor: const Color(0xffEAEFF4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      title: Text(
        listModel.description,
        style: tTitle.copyWith(
          color: isSelected ? cWhiteColor : cBlackColor,
          fontSize: 18,
        ),
      ),

      subtitle: isEditable
          ? Row(
        children: [
          if (isActionList && total > 0)
            SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                value: total == 0 ? 0 : (completed / total),
                backgroundColor: cSecondaryColor.withAlpha(50),
                color: cSecondaryColor.withAlpha(200),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            isActionList
                ? "$completed / $total concluídas"
                : "Lista de Entradas",
            style: tNormal.copyWith(
              color: isSelected ? cWhiteColor : Colors.grey[700],
            ),
          ),
        ],
      )
          : Text(
        listModel.listType == 'entry' ? "Lista de Entradas" : "Lista de Acções",
        style: tNormal,
      ),

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

      onLongPress: () => onLongPress?.call(),
    );
  }
}
