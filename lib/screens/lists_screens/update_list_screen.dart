import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/list_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/screens/lists_screens/lists_screen.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';

class UpdateListScreen extends StatefulWidget {
  final ListModel listModel;

  const UpdateListScreen({super.key, required this.listModel});

  @override
  State<UpdateListScreen> createState() => _UpdateListScreenState();
}

class _UpdateListScreenState extends State<UpdateListScreen> {
  late String _selectedListType;
  late String _listDescription;

  final List<String> _listTypes = ['Lista de Acção', 'Lista de Entradas'];
  final _formKey = GlobalKey<FormState>();
  final _listDao = ListDao();

  @override
  void initState() {
    super.initState();
    _selectedListType = widget.listModel.listType;
    _listDescription = widget.listModel.description ?? '';
  }

  Future<void> _updateList() async {
    if (!_formKey.currentState!.validate()) return;

    // Crie um novo objeto preservando os campos imutáveis (ex: id, userId)
    final updated = ListModel(
      id: widget.listModel.id,               // <-- importante para o WHERE
      userId: widget.listModel.userId,       // preserve o dono
      listType: _selectedListType,
      description: _listDescription,
    );

    await _listDao.update(updated); // ver correção do DAO abaixo

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ListsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: const Text('Editar Lista'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: defaultPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Text('Tipo de Lista', style: tNormal),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cBlackColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedListType,
                            items: _listTypes.map((t) => DropdownMenuItem(
                              value: t, child: Text(t, style: tNormal),
                            )).toList(),
                            onChanged: (v) => setState(() {
                              if (v != null) _selectedListType = v;
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Descrição', style: tNormal),
                      TextFormField(
                        initialValue: _listDescription,
                        decoration: inputDecoration,
                        maxLines: 5,
                        validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Deve conter a descrição da lista'
                            : null,
                        onChanged: (v) => _listDescription = v,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: GestureDetector(
              onTap: _updateList,
              child: const MainButton(buttonText: 'Atualizar'),
            ),
          ),
        ],
      ),
    );
  }
}
