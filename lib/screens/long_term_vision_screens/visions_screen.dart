import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/widgets/cards/kwanga_empty_card.dart';
import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import 'package:kwanga/widgets/kwanga_dropdown_button.dart';

import '../../models/vision_model.dart';
import '../../models/life_area_model.dart';
import '../annual_goals_screens/goals_by_vision.dart';
import 'controllers/visions_aggregator_provider.dart';
import 'create_vision_screen.dart';
import 'widgets/vision_widget.dart';

class VisionsScreen extends ConsumerStatefulWidget {
  const VisionsScreen({super.key});

  @override
  ConsumerState<VisionsScreen> createState() => _VisionsScreenState();
}

class _VisionsScreenState extends ConsumerState<VisionsScreen> {
  int? selectedYear;

  @override
  Widget build(BuildContext context) {
    final aggregatedAsync = ref.watch(visionsAggregatedProvider);

    return aggregatedAsync.when(
      loading: () => _buildScaffold(
        context: context,
        body: const Center(child: CircularProgressIndicator()),
      ),

      error: (e, _) => _buildScaffold(
        context: context,
        body: Center(child: Text("Erro: $e", style: tNormal)),
      ),

      data: (data) {
        final int currentYear = DateTime.now().year;

        // initial year
        final int minYear = currentYear + 3;
        final int maxYear = minYear + 2;

        final List<int> years = [for (var y = minYear; y <= maxYear; y++) y];

        selectedYear ??= years.first;

        final List<LifeAreaModel> areas = data.areas;
        final List<VisionModel> visions = data.visions;

        // ---------- Mapa de contagem de objetivos ----------
        final Map<String, int> goalsCountMap = {};
        for (final g in data.goals) {
          goalsCountMap[g.visionId] = (goalsCountMap[g.visionId] ?? 0) + 1;
        }

        // ---------- Agrupamento: cada área → lista de visões ----------
        final grouped = areas.map((area) {
          final areaVisions = visions
              .where(
                (v) =>
                    v.lifeAreaId == area.id.toString() &&
                    v.conclusion == selectedYear,
              )
              .toList();

          return {"area": area, "visions": areaVisions};
        }).toList();

        return _buildScaffold(
          context: context,
          body: Column(
            children: [
              // ---------- DROPDOWN ----------
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: KwangaDropdownButton<int>(
                    value: selectedYear!,
                    items: years
                        .map((y) => DropdownMenuItem(value: y, child: Text("$y")))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedYear = value);
                    }, labelText: '', hintText: '',
                  ),
                ),
              ),

              // ---------- LISTA AGRUPADA ----------
              Expanded(
                child: ListView.builder(
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final area = grouped[index]["area"] as LifeAreaModel;
                    final List<VisionModel> areaVisions =
                        grouped[index]["visions"] as List<VisionModel>;

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------- Cabeçalho da área ----------
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                area.isSystem
                                    ? Image.asset(
                                        "assets/icons/${area.iconPath}.png",
                                        width: 22,
                                      )
                                    : Image.asset(area.iconPath, width: 22),
                                const SizedBox(width: 8),
                                Text(area.designation, style: tSmallTitle),
                              ],
                            ),
                          ),

                          // ---------- Vision or NoVision ----------
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: areaVisions.isNotEmpty
                                ? Column(
                                    children: areaVisions.map((vision) {
                                      final goalsCount =
                                          goalsCountMap[vision.id] ?? 0;

                                      return VisionWidget(
                                        vision: vision,
                                        area: area,
                                        goalsCount: goalsCount,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GoalsByVision(
                                                vision: vision,
                                                area: area,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  )
                                : KwangaEmptyCard(message: 'Sem visão definida\npara este ano.'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------- SCAFFOLD PADRÃO --------------------

  Widget _buildScaffold({required BuildContext context, required Widget body}) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visões a Longo Prazo"),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),
      drawer: const CustomDrawer(),
      backgroundColor: cWhiteColor,
      bottomNavigationBar: BottomActionBar(
        buttonText: "Adicionar Visão a Longo Prazo",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateVision()),
          );
        },
      ),
      body: SafeArea(child: body),
    );
  }
}
