import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/providers/life_area_provider.dart';
import 'package:kwanga/screens/life_area_screens/widgets/header.dart';
import 'package:kwanga/screens/life_area_screens/widgets/purpose_widget.dart';
import 'package:kwanga/screens/life_area_screens/widgets/stats_grid.dart';
import 'package:kwanga/widgets/dialogs/kwanga_delete_dialog.dart';

import 'create_life_area_screen.dart';

class LifeAreaDetailsScreen extends ConsumerWidget {
  final String areaId;

  const LifeAreaDetailsScreen({
    super.key,
    required this.areaId,
  });

  Future<void> _onEdit(
      BuildContext context,
      WidgetRef ref,
      LifeAreaModel area,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateLifeAreaScreen(areaToEdit: area),
      ),
    );
  }

  Future<void> _onDelete(
      BuildContext context,
      WidgetRef ref,
      LifeAreaModel area,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => KwangaDeleteDialog(
        title: "Eliminar Área da Vida",
        message:
        'Tem certeza que deseja eliminar a área ${area.designation}?'
            '\nEsta acção é irreversível',
      ),
    );

    if (confirmed != true) return;

    await ref.read(lifeAreasProvider.notifier).deleteLifeArea(area.id);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(lifeAreasProvider);

    return areasAsync.when(
      loading: () =>
      const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (areas) {
        final area = areas.firstWhere((a) => a.id == areaId);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Área da Vida'),
            backgroundColor: cMainColor,
            foregroundColor: cWhiteColor,
            actions: [
              if (!area.isSystem)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _onEdit(context, ref, area);
                    } else if (value == 'delete') {
                      _onDelete(context, ref, area);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final headerHeight = constraints.maxHeight * 0.33;

              return Column(
                children: [
                  // 🔹 HEADER FIXO (1/3 da tela)
                  SizedBox(
                    height: headerHeight,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Header(area: area),
                      ),
                    ),
                  ),

                  // 🔹 CONTEÚDO SCROLLÁVEL (2/3 restantes)
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xfff5f5f5),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Propósito
                            PurposeWidget(area: area),

                            const SizedBox(height: 32),

                            // Estatísticas
                            StatsGrid(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),


        );
      },
    );
  }
}

