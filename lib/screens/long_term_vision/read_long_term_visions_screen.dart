import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/long_term_vision_dao.dart';
import 'package:kwanga/data/life_areas.dart';
import 'package:kwanga/screens/long_term_vision/create_long_term_vision.dart';
import '../../models/long_term_vision_model.dart';

class LongTermVisionsScreen extends StatefulWidget {
  const LongTermVisionsScreen({super.key});

  @override
  State<LongTermVisionsScreen> createState() => _LongTermVisionsScreenState();
}

class _LongTermVisionsScreenState extends State<LongTermVisionsScreen> {
  final List<Color> _colors = [
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.lime,
    Colors.cyan,
    Colors.amber,
  ];

  final LongTermVisionDao _longTermVisionDao = LongTermVisionDao();
  late Future<List<LongTermVision>> _visionsFuture;

  @override
  void initState() {
    super.initState();
    _loadVisions();
  }

  // Lê as visões da base de dados
  void _loadVisions() {
    setState(() {
      _visionsFuture = _longTermVisionDao.getAll();
    });
  }

  // Adiciona nova visão
  Future<void> _addVision() async {
    final newVision = await Navigator.push<LongTermVision>(
      context,
      MaterialPageRoute(builder: (_) => const CreateLongTermVision()),
    );

    if (newVision != null) {
      await _longTermVisionDao.insert(newVision);
      _loadVisions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text('Visão de Longo Prazo', style: tTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVision,
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<LongTermVision>>(
        future: _visionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar visões: ${snapshot.error}',
                style: tNormal.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final visions = snapshot.data ?? [];

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 5 / 6,
            ),
            padding: const EdgeInsets.all(24),
            itemCount: initialLifeAreas.length,
            itemBuilder: (context, index) {
              final area = initialLifeAreas[index];

              // encontra visão (ou null se não existir)
              final vision = visions.where((v) => v.lifeArea.id == area.id).isNotEmpty
                  ? visions.firstWhere((v) => v.lifeArea.id == area.id)
                  : null;

              return Container(
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                  color: const Color(0xffF2F2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/icons/${area.iconPath}.png',
                            width: 24.0,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            area.designation,
                            style: tSmallTitle.copyWith(color: _colors[index]),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            vision?.designation ?? 'Sem visão definida',
                            style: tNormal.copyWith(
                              color: vision == null ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        vision?.deadline ?? 'Sem prazo definido',
                        style: tNormal.copyWith(
                          color: vision == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
