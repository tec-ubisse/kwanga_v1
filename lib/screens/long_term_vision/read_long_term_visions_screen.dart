import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/life_area_dao.dart';
import 'package:kwanga/data/database/long_term_vision_dao.dart';
import 'package:kwanga/data/life_areas.dart';
import 'package:kwanga/screens/long_term_vision/create_long_term_vision.dart';
import 'package:kwanga/widgets/buttons/icon_button.dart';
import '../../models/life_area_model.dart';
import '../../models/long_term_vision_model.dart';

class LongTermVisionsScreen extends StatefulWidget {
  const LongTermVisionsScreen({super.key});

  @override
  State<LongTermVisionsScreen> createState() => _LongTermVisionsScreenState();
}

class _LongTermVisionsScreenState extends State<LongTermVisionsScreen> {
  final Random _random = Random();

  Color _randomColor() {
    return Color.fromARGB(255, _random.nextInt(150), _random.nextInt(150), 250);
  }

  final LongTermVisionDao _longTermVisionDao = LongTermVisionDao();
  final LifeAreaDao _lifeAreaDao = LifeAreaDao();
  late Future<List<LongTermVision>> _visionsFuture;
  late Future<List<LifeArea>> _lifeAreas;

  @override
  void initState() {
    super.initState();
    _loadLifeAreas();
    _loadVisions();
  }

  void _loadVisions() {
    setState(() {
      _visionsFuture = _longTermVisionDao.getAll();
    });
  }

  void _loadLifeAreas() {
    setState(() {
      _lifeAreas = _lifeAreaDao.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text('Visão de Longo Prazo', style: tTitle),
      ),
      body: FutureBuilder(
        future: _visionsFuture,
        builder: (builder, visionSnapshot) {
          if (visionSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: cMainColor,
                color: cSecondaryColor,
              ),
            );
          }

          if (visionSnapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar visões: ${visionSnapshot.error}',
                style: tNormal.copyWith(color: cTertiaryColor),
                textAlign: TextAlign.center,
              ),
            );
          }

          final visions = visionSnapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: initialLifeAreas.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: FutureBuilder(
                    future: _visionsFuture,
                    builder: (context, visionSnapshot) {
                      if (visionSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: cMainColor,
                            color: cSecondaryColor,
                          ),
                        );
                      }

                      // displays error message in case anything goes wrong
                      if (visionSnapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro ao carregar visões: ${visionSnapshot.error}',
                            style: tNormal.copyWith(color: cTertiaryColor),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      List<LongTermVision> filteredVisions = visions
                          .where(
                            (vision) =>
                                vision.lifeArea == initialLifeAreas[index],
                          )
                          .toList();

                      Color currentColor = _randomColor();

                      return Column(
                        children: [
                          // Title
                          Container(
                            decoration: BoxDecoration(
                              color: currentColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                spacing: 16.0,
                                children: [
                                  Image.asset(
                                    'assets/icons/${initialLifeAreas[index].iconPath}.png',
                                    width: 32.0,
                                  ),
                                  Text(
                                    initialLifeAreas[index].designation,
                                    style: tSmallTitle.copyWith(
                                      color: cWhiteColor,
                                    ),
                                  ),

                                  const Spacer(),

                                  // Add button
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) =>
                                              CreateLongTermVision(
                                                selectedArea:
                                                    initialLifeAreas[index],
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: cWhiteColor,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 1.0,
                                            spreadRadius: 1.0,
                                            color: cBlackColor,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      child: Icon(Icons.add, color: cMainColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filteredVisions.isEmpty)
                            Container(
                              height: 100.0,
                              margin: const EdgeInsets.only(top: 8.0),
                              decoration: BoxDecoration(
                                color: currentColor.withAlpha(10),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ainda não tem visão ${initialLifeAreas[index].designation}',
                                          style: tTitle.copyWith(
                                            color: cBlackColor,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        Text('Clique para adicionar'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...filteredVisions.map((vision) {
                              return Container(
                                margin: const EdgeInsets.only(top: 8.0),
                                decoration: BoxDecoration(
                                  color: currentColor.withAlpha(10),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vision.designation,
                                      style: tNormal.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: currentColor,
                                      ),
                                    ), // [cite: 37]
                                    Text(
                                      'Prazo: ${vision.deadline}',
                                      style: tSmallTitle.copyWith(
                                        color: currentColor.withOpacity(0.8),
                                      ),
                                    ), // [cite: 36]
                                  ],
                                ),
                              );
                            }).toList(),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
