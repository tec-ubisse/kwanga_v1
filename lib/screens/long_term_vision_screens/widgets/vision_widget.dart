import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/life_area_model.dart';
import '../../../models/vision_model.dart';
import '../../../providers/visions_provider.dart';
import '../../../widgets/dialogs/kwanga_delete_dialog.dart';
import '../create_vision_screen.dart';

class VisionWidget extends ConsumerWidget {
  final LifeAreaModel area;
  final int goalsCount;
  final VisionModel vision;
  final VoidCallback onTap;

  const VisionWidget({
    super.key,
    required this.vision,
    required this.area,
    required this.goalsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double safeProgress = 0.0;
    const int percent = 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(boxShadow: [cDefaultShadow],),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Slidable(
            key: ValueKey(vision.id),

            /// Ações laterais
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.5,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateVision(
                          visionToEdit: vision,
                          lifeAreaId: vision.lifeAreaId,
                        ),
                      ),
                    );
                  },
                  backgroundColor: cSecondaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Editar',
                ),
                SlidableAction(
                  onPressed: (_) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => KwangaDeleteDialog(
                        title: 'Eliminar Visão',
                        message:
                        'Tem a certeza que pretende eliminar a visão '
                            '"${vision.description}"?\n'
                            'Esta acção é irreversível.',
                      ),
                    );

                    if (confirm == true) {
                      await ref
                          .read(visionsProvider.notifier)
                          .deleteVision(vision.id);
                      ref.invalidate(visionsProvider);
                    }
                  },
                  backgroundColor: cTertiaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Eliminar',
                ),
              ],
            ),

            /// Card
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: cardDecoration,
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Texto flexível
                    Expanded(
                      child: Text(
                        vision.description,
                        style: tNormal,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 12),

                    CircularPercentIndicator(
                      radius: 32,
                      lineWidth: 12,
                      percent: safeProgress,
                      center: Text(
                        '$percent%',
                        style: tSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      progressColor: cMainColor,
                      backgroundColor: Colors.grey.shade300,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}