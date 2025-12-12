import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/models/vision_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/life_area_model.dart';
import '../../../providers/visions_provider.dart';
import '../../../widgets/dialogs/kwanga_delete_dialog.dart';
import '../create_vision_screen.dart';

class VisionWidget extends ConsumerWidget {
  final LifeAreaModel area;
  final int goalsCount;
  final VisionModel vision;
  final Function() onTap;


  const VisionWidget({
    super.key,
    required this.vision,
    required this.area,
    required this.goalsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(24),
            blurRadius: 8,
            offset: const Offset(4, 4),
            spreadRadius: -1,
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(16.0),
        child: Slidable(
          key: ValueKey(vision.id),

          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.50,
            children: [
              // EDITAR
              SlidableAction(
                onPressed: (_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => CreateVision(
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

              // REMOVER
              SlidableAction(
                onPressed: (_) async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => KwangaDeleteDialog(
                      title: "Eliminar Visão",
                      message:
                      "Tem a certeza que pretende eliminar a visão \"${vision.description}\"? Esta acção é irreversível.",
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

          child: GestureDetector(
            onTap: onTap,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: defaultPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        vision.description,
                        style: tNormal,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: CircularPercentIndicator(
                        radius: 32.0,
                        lineWidth: 12.0,
                        percent: 0.1,
                        center: Text('5%'),
                        progressColor: cMainColor,
                        backgroundColor: Colors.grey.shade300,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
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
