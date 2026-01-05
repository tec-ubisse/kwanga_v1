import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';

import 'package:kwanga/providers/life_area_provider.dart';

import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';
import 'package:kwanga/screens/purpose_screens/widgets/purpose_area_section.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';

import 'create_purpose_screen.dart';

class PurposesScreen extends ConsumerWidget {
  const PurposesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(lifeAreasProvider);

    return Scaffold(
      backgroundColor: cWhiteColor,

      appBar: AppBar(
        title: const Text('Propósitos'),
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
      ),

      drawer: const CustomDrawer(),

      bottomNavigationBar: BottomActionBar(
        buttonText: 'Novo Propósito',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePurposeScreen(),
            ),
          );
        },
      ),

      body: SafeArea(
        child: areasAsync.when(
          loading: () =>
          const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
          const Center(child: Text('Erro ao carregar áreas')),
          data: (areas) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: areas.length,
              itemBuilder: (_, i) {
                final area = areas[i];

                return Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                  ),
                  child: PurposeAreaSection(
                    area: area,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
