import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/providers/life_area_provider.dart';
import 'package:kwanga/screens/life_area_screens/create_life_area_screen.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import 'package:kwanga/widgets/custom_drawer.dart';

class ReadLifeAreasScreen extends ConsumerStatefulWidget {
  const ReadLifeAreasScreen({super.key});

  @override
  ConsumerState<ReadLifeAreasScreen> createState() =>
      _ReadLifeAreasScreenState();
}

class _ReadLifeAreasScreenState
    extends ConsumerState<ReadLifeAreasScreen> {
  LifeAreaModel? _selectedArea;

  void _enterSelectionMode(LifeAreaModel area) {
    setState(() => _selectedArea = area);
  }

  void _exitSelectionMode() {
    setState(() => _selectedArea = null);
  }

  String resolveIconPath(LifeAreaModel area) {
    if (!area.isSystem) {
      return area.iconPath;
    }

    if (area.iconPath.startsWith('assets/')) {
      return area.iconPath;
    }

    return 'assets/icons/${area.iconPath}.png';
  }

  @override
  Widget build(BuildContext context) {
    final areasAsync = ref.watch(lifeAreasProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
        _selectedArea == null ? cMainColor : cSecondaryColor,
        foregroundColor: cWhiteColor,
        title: Text(
          _selectedArea == null
              ? 'Áreas da vida'
              : _selectedArea!.designation,
          style: tTitle.copyWith(fontWeight: FontWeight.w500),
        ),
        actions: _selectedArea == null
            ? null
            : [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final area = _selectedArea!;
              _exitSelectionMode();

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateLifeAreaScreen(areaToEdit: area),
                ),
              );

              ref.invalidate(lifeAreasProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final area = _selectedArea!;

              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Eliminar área da vida"),
                  content: Text(
                    'Tem certeza que deseja eliminar "${area.designation}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Eliminar",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed != true) return;

              _exitSelectionMode();
              await ref.read(lifeAreasProvider.notifier).deleteLifeArea(area.id);
              ref.invalidate(lifeAreasProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitSelectionMode,
          )
        ],
      ),
      backgroundColor: cWhiteColor,
      drawer: CustomDrawer(),
      body: SafeArea(
        child: areasAsync.when(
          loading: () =>
          const Center(child: CircularProgressIndicator()),
          error: (err, st) =>
              Center(child: Text("Erro ao carregar áreas: $err")),
          data: (lifeAreas) {
            if (lifeAreas.isEmpty) {
              return const Center(
                child: Text('Nenhuma área da vida cadastrada ainda.'),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: defaultPadding,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(lifeAreasProvider);
                      },
                      child: GridView.builder(
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: lifeAreas.length,
                        itemBuilder: (context, index) {
                          final area = lifeAreas[index];
                          final isSelected =
                              _selectedArea?.id == area.id;

                          return GestureDetector(
                            onLongPress: () {
                              if (!area.isSystem) {
                                _enterSelectionMode(area);
                              }
                            },
                            onTap: () {
                              // Se estiver a selecionar, um tap cancela
                              if (_selectedArea != null) {
                                _exitSelectionMode();
                              }
                            },
                            child: AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cSecondaryColor
                                    .withAlpha(40)
                                    : cBlackColor.withAlpha(10),
                                borderRadius:
                                BorderRadius.circular(8.0),
                                border: isSelected
                                    ? Border.all(
                                  color: cSecondaryColor,
                                  width: 2,
                                )
                                    : null,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      resolveIconPath(area),
                                      width: 40.0,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      area.designation,
                                      textAlign: TextAlign.center,
                                      style: tNormal.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // BOTÃO DE ADICIONAR
                Container(
                  height: 100.0,
                  width: double.infinity,
                  color: cBlackColor.withAlpha(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 24.0),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) =>
                            const CreateLifeAreaScreen(),
                          ),
                        );

                        ref.invalidate(lifeAreasProvider);
                      },
                      child: MainButton(
                          buttonText: 'Adicionar Área da Vida'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
