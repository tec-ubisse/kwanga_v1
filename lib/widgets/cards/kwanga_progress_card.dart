import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../models/project_model.dart';
import 'package:percent_indicator/percent_indicator.dart';

class KwangaProgressCard extends StatelessWidget {
  final ProjectModel project;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KwangaProgressCard({
    super.key,
    required this.project,
    required this.progress,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Slidable(
        key: ValueKey(project.id),

        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.45,
          children: [
            // EDITAR
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: cSecondaryColor,
              foregroundColor: Colors.white,
              icon: Icons.edit,
            ),

            // APAGAR
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: cTertiaryColor,
              foregroundColor: Colors.white,
              icon: Icons.delete,
            ),
          ],
        ),

        child: GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    project.title,
                    style: tNormal,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CircularPercentIndicator(
                    radius: 32.0,
                    lineWidth: 12.0,
                    percent: progress,
                    center: Text('$percent%'),
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
    );
  }
}
