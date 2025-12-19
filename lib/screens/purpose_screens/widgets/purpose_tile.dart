import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/widgets/dialogs/kwanga_delete_dialog.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';

import '../../../models/life_area_model.dart';
import '../../../models/purpose_model.dart';

import '../../../providers/purpose_provider.dart';

import '../create_purpose_screen.dart';

class PurposeTile extends ConsumerWidget {
  final PurposeModel purpose;
  final LifeAreaModel area;

  const PurposeTile({
    super.key,
    required this.purpose,
    required this.area,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Slidable(
          key: ValueKey(purpose.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.45,
            children: [
              // EDIT
              SlidableAction(
                onPressed: (_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatePurposeScreen(
                        existingPurpose: purpose,
                      ),
                    ),
                  );
                },
                backgroundColor: cMainColor,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Editar',
              ),

              // DELETE
              SlidableAction(
                onPressed: (_) async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => KwangaDeleteDialog(title: 'Eliminar Propósito', message: 'Tem certeza que deseja eliminar o propósito ${purpose.description}? \nEsta acção é irreversível'),
                  );

                  if (confirmed == true) {
                    await ref
                        .read(purposesProvider.notifier)
                        .removePurpose(purpose.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Propósito eliminado com sucesso!'),
                            Image.asset('assets/gifs/delete.gif', width: 40.0),
                          ],
                        ),
                      ),
                    );
                  }
                },
                backgroundColor: cTertiaryColor,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Eliminar',
              ),
            ],
          ),

          // --------------------------------------------------
          // TILE CONTENT
          // --------------------------------------------------
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Text(
              purpose.description,
              style: tNormal,
            ),
          ),
        ),
      ),
    );
  }
}
