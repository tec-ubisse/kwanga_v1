import 'package:flutter/material.dart';

import '../../../custom_themes/blue_accent_theme.dart';
import '../../../custom_themes/text_style.dart';
import '../../../models/project_model.dart';
// ... outras importações

class ProjectInfoBar extends StatefulWidget {
  final String monthText;
  final int doneCount;
  final int total;
  final ProjectModel project;
  final bool showMore; // Valor inicial do estado

  const ProjectInfoBar({
    super.key,
    required this.monthText,
    required this.doneCount,
    required this.total,
    required this.project,
    required this.showMore,
  });

  @override
  State<ProjectInfoBar> createState() => _ProjectInfoBarState();
}

class _ProjectInfoBarState extends State<ProjectInfoBar> {
  // ⭐️ Renomeado para 'isExpanded' para maior clareza.
  late bool isExpanded;

  @override
  void initState() {
    // Inicializamos o estado com o valor passado pelo pai (widget.showMore).
    isExpanded = widget.showMore;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.0,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // DETAILS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.monthText,
                            style: tNormal.copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      const Icon(Icons.list_alt_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.doneCount}/${widget.total} tarefas",
                        style: tNormal.copyWith(fontSize: 12),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.doneCount == widget.total && widget.total != 0
                            ? "Concluído"
                            : "Pendente",
                        style: tNormal.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.list_alt, size: 16),
                              Text(
                                'Propósito',
                                style: tSmallTitle.copyWith(
                                  fontSize: 12,
                                  color: cBlackColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.project.purpose,
                            style: tNormal.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.task_alt_outlined, size: 16),
                              Text(
                                'Resultado esperado',
                                style: tSmallTitle.copyWith(
                                  fontSize: 12,
                                  color: cBlackColor,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              widget.project.expectedResult,
                              style: tNormal.copyWith(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            // 2. O texto depende do estado local 'isExpanded'
            isExpanded ? 'Mostrar menos     ' : 'Mostrar mais    ',
            // Estilo opcional para parecer um link/botão
            style: tNormal.copyWith(fontWeight: FontWeight.bold, color: cSecondaryColor, fontStyle: FontStyle.normal, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
