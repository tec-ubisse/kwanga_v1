import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/life_area_dao.dart';
import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/screens/life_area_screens/create_life_area_screen.dart';
import 'package:kwanga/utils/current_user.dart';
import 'package:kwanga/widgets/custom_drawer.dart';

class ReadLifeAreasScreen extends StatefulWidget {
  const ReadLifeAreasScreen({super.key});

  @override
  State<ReadLifeAreasScreen> createState() => _ReadLifeAreasScreenState();
}

class _ReadLifeAreasScreenState extends State<ReadLifeAreasScreen> {
  final LifeAreaDao _lifeAreaDao = LifeAreaDao();
  List<LifeArea> _lifeAreas = [];
  int? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndAreas();
  }

  Future<void> _loadUserAndAreas() async {
    final userId = await CurrentUser.getUserId();
    final areas = await _lifeAreaDao.getAll(userId!);

    setState(() {
      _userId = userId;
      _lifeAreas = areas;
      _isLoading = false;
    });
  }

  Future<void> _refreshAreas() async {
    if (_userId == null) return;
    final areas = await _lifeAreaDao.getAll(_userId!);
    setState(() => _lifeAreas = areas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(
          'Áreas da vida',
          style: tTitle.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      drawer: CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lifeAreas.isEmpty
          ? const Center(child: Text('Nenhuma área da vida cadastrada ainda.'))
          : Padding(
        padding: defaultPadding,
        child: RefreshIndicator(
          onRefresh: _refreshAreas,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            itemCount: _lifeAreas.length,
            itemBuilder: (BuildContext context, int index) {
              final area = _lifeAreas[index];
              return Container(
                decoration: BoxDecoration(
                  color: cBlackColor.withAlpha(10),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/${area.iconPath}.png',
                        width: 40.0,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        area.designation,
                        style: tNormal.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const CreateLifeAreaScreen()),
          );
          _refreshAreas();
        },
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
