import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/screens/task_screens/list_task_screen.dart';
import 'package:kwanga/providers/progress_provider.dart';
import 'package:kwanga/utils/list_type_utils.dart';

class ListTileItem extends ConsumerWidget {
  final ListModel listModel;
  final bool canViewChildren;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isEditable;

  const ListTileItem(
      this.onTap,
      this.onLongPress, {
        super.key,
        required this.isEditable,
        required this.listModel,
        required this.isSelected,
        required this.canViewChildren,
      });

  bool get isActionList {
    return normalizeListType(listModel.listType) == 'action';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalized = normalizeListType(listModel.listType);

    final progressAsync = isActionList
        ? ref.watch(taskProgressProvider(listModel.id))
        : const AsyncValue.data({'completed': 0, 'total': 0});

    return progressAsync.when(
      data: (progress) {
        final completed = progress['completed'] ?? 0;
        final total = progress['total'] ?? 0;

        return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: ListTile(
            tileColor: const Color(0xffEAEFF4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              listModel.description,
              style: tTitle.copyWith(
                color: isSelected ? cWhiteColor : cBlackColor,
                fontSize: 18.0,
                height: 1.2,
              ),
            ),
            subtitle: isEditable
                ? Row(
              spacing: 8.0,
              children: [
                if (isActionList && total > 0)
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      value: completed / total,
                      backgroundColor: cSecondaryColor.withAlpha(50),
                      color: cSecondaryColor.withAlpha(200),
                    ),
                  ),
                Text(
                  isActionList
                      ? '$completed / $total concluídas'
                      : 'Lista de Entradas',
                  style: tNormal.copyWith(
                    color: isSelected ? cWhiteColor : Colors.grey[700],
                  ),
                ),
              ],
            )
                : Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                normalized == 'action'
                    ? "Lista de Acções"
                    : "Lista de Entradas",
                style: tNormal.copyWith(
                  color: isSelected ? cWhiteColor : Colors.grey[700],
                ),
              ),
            ),
            onTap: () async {
              if (canViewChildren) {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ListTasksScreen(listModel: listModel),
                  ),
                );

                ref.invalidate(taskProgressProvider(listModel.id));
              }
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Erro: $err'),
    );
  }
}
