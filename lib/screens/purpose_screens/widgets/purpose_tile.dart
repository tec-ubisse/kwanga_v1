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

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [cDefaultShadow], // ✅ sombra no lugar certo
        ),
        child: ClipRRect(
          borderRadius: _radius,
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
                      builder: (_) => KwangaDeleteDialog(
                        title: 'Eliminar Propósito',
                        message:
                        'Tem certeza que deseja eliminar o propósito '
                            '"${purpose.description}"?\n'
                            'Esta acção é irreversível',
                      ),
                    );

                    if (confirmed == true) {
                      await ref
                          .read(purposesProvider.notifier)
                          .removePurpose(purpose.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Propósito eliminado com sucesso!',
                              ),
                              Image.asset(
                                'assets/gifs/delete.gif',
                                width: 40,
                              ),
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

            /// CONTEÚDO DO CARD
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePurposeScreen(
                      existingPurpose: purpose,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: cardDecoration,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 12,
                ),
                child: Text(
                  purpose.description,
                  style: tNormal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
