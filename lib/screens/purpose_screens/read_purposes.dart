import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/purpose_dao.dart';
import 'package:kwanga/models/purpose_model.dart';
import 'package:kwanga/screens/main_screen.dart';
import 'package:kwanga/screens/purpose_screens/create_purpose.dart';
import 'package:kwanga/screens/purpose_screens/edit_purpose.dart';
import 'package:kwanga/widgets/purpose_widget.dart';

class ReadPurposes extends StatefulWidget {
  const ReadPurposes({super.key});

  @override
  State<ReadPurposes> createState() => _ReadPurposesState();
}

class _ReadPurposesState extends State<ReadPurposes> {
  final PurposeDao _purposeDao = PurposeDao();

  late Future<List<Purpose>> _purposesFuture;

  @override
  void initState() {
    super.initState();
    _loadPurposes();
  }

  void _loadPurposes() {
    setState(() {
      _purposesFuture = _purposeDao.getAll();
    });
  }

  Future<void> _addNewPurpose() async {
    final newPurpose = await Navigator.push<Purpose>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePurpose()),
    );

    if (newPurpose != null) {
      await _purposeDao.insert(newPurpose);
      _loadPurposes();
    }
  }

  Future<void> _editPurpose(Purpose purpose) async {
    final editedPurpose = await Navigator.push<Purpose>(
      context,
      MaterialPageRoute(builder: (_) => EditPurpose(purpose: purpose)),
    );

    if (editedPurpose != null) {
      await _purposeDao.update(editedPurpose);
      _loadPurposes();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Propósito atualizado com sucesso!')),
      );
    }
  }

  Future<void> _deletePurpose(Purpose purpose) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Propósito'),
        content: const Text('Tem certeza que deseja eliminar este propósito?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () {
              _purposeDao.delete(purpose.id);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (ctx) => ReadPurposes()),
              );
            },
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _purposeDao.delete(purpose.id);
      _loadPurposes();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Propósito eliminado.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Row(
          spacing: 8.0,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              },
              child: const Icon(Icons.arrow_back),
            ),
            Text(
              'Propósitos',
              style: tTitle.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      backgroundColor: cWhiteColor,
      body: FutureBuilder<List<Purpose>>(
        future: _purposesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Ainda não tem propósitos.\nDefina um novo.",
                textAlign: TextAlign.center,
              ),
            );
          }

          final purposes = snapshot.data!;

          return ListView.separated(
            itemCount: purposes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final purpose = purposes[index];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    SlidableAction(
                      backgroundColor: cTertiaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      onPressed: (_) => _deletePurpose(purpose),
                      icon: Icons.delete,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () => _editPurpose(purpose),
                  child: PurposeWidget(
                    areaName: purpose.lifeArea.designation,
                    path: purpose.lifeArea.iconPath,
                    purposeDescription: purpose.description,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPurpose,
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
