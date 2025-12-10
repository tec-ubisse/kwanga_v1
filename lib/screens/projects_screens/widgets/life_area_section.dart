import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';

import '../../../custom_themes/text_style.dart';
import '../../../models/life_area_model.dart';
import '../../../models/project_model.dart';

import '../cards/project_card.dart';
import '../../../widgets/cards/kwanga_empty_card.dart';

class LifeAreaSection extends StatelessWidget {
  final LifeAreaModel area;
  final List<ProjectModel> projects;
  final Map<String, double> progressMap;
  final VoidCallback onAdd;
  final void Function(ProjectModel) onOpen;
  final void Function(ProjectModel) onEdit;
  final void Function(ProjectModel) onDelete;

  const LifeAreaSection({
    super.key,
    required this.area,
    required this.projects,
    required this.progressMap,
    required this.onAdd,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasProjects = projects.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            if (area.iconPath.isNotEmpty)
              area.isSystem
                  ? Image.asset(
                "assets/icons/${area.iconPath}.png",
                width: 24,
              )
                  : Image.asset(
                area.iconPath,
                width: 24,
              ),
            const SizedBox(width: 8),
            Text(
              area.designation,
              style: tNormal.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// --- LISTA OU PLACEHOLDER ---
        if (!hasProjects)
          KwangaEmptyCard(message: 'Sem projectos nesta área')
        else
          Column(
            children: [
              for (final p in projects)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [cDefaultShadow],
                    ),
                    child: ProjectCard(
                      project: p,
                      progress: progressMap[p.id] ?? 0.0,
                      onTap: () => onOpen(p),
                      onEdit: () => onEdit(p),
                      onDelete: () => onDelete(p),
                    ),
                  ),
                ),
            ],
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}
