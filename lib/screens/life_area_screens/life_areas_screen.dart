import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/providers/life_area_provider.dart';
import 'package:kwanga/screens/life_area_screens/create_life_area_screen.dart';
import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';

import 'details_screen.dart';
import 'widgets/life_area_card.dart';

class LifeAreasScreen extends ConsumerStatefulWidget {
  const LifeAreasScreen({super.key});

  @override
  ConsumerState<LifeAreasScreen> createState() => _LifeAreasScreenState();
}

class _LifeAreasScreenState extends ConsumerState<LifeAreasScreen> {
  bool _isReorderMode = false;

  @override
  Widget build(BuildContext context) {
    final areasAsync = ref.watch(lifeAreasProvider);
    final notifier = ref.read(lifeAreasProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(
          _isReorderMode ? 'Reordenar Áreas' : 'Áreas da vida',
          style: tTitle.copyWith(fontWeight: FontWeight.w500),
        ),
        actions: [
          if (areasAsync.hasValue && areasAsync.value!.length > 1)
            IconButton(
              icon: Icon(
                _isReorderMode ? Icons.check : Icons.swap_vert,
              ),
              tooltip: _isReorderMode ? 'Concluir' : 'Reordenar',
              onPressed: () {
                setState(() {
                  _isReorderMode = !_isReorderMode;
                });
              },
            ),
        ],
      ),
      backgroundColor: cWhiteColor,
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: areasAsync.when(
          loading: () =>
          const Center(child: CircularProgressIndicator()),
          error: (err, _) =>
              Center(child: Text('Erro ao carregar áreas: $err')),
          data: (lifeAreas) {
            if (lifeAreas.isEmpty) {
              return const Center(
                child: Text('Nenhuma área da vida cadastrada ainda.'),
              );
            }

            return Padding(
              padding: defaultPadding,
              child: _isReorderMode
                  ? ReorderableGridView.builder(
                itemCount: lifeAreas.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                onReorder: (oldIndex, newIndex) async {
                  await notifier.reorder(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final area = lifeAreas[index];
                  return Container(
                    key: ValueKey(area.id),
                    child: LifeAreaCard(
                      area: area,
                      showDragHandle: true, // 👈 ajuste no card
                    ),
                  );
                },
              )
                  : GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: lifeAreas.length,
                itemBuilder: (_, index) {
                  final area = lifeAreas[index];
                  return LifeAreaCard(
                    area: area,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LifeAreaDetailsScreen(
                            areaId: area.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _isReorderMode
          ? null
          : BottomActionBar(
        buttonText: 'Adicionar Área da Vida',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateLifeAreaScreen(),
            ),
          );
          ref.invalidate(lifeAreasProvider);
        },
      ),
    );
  }
}
