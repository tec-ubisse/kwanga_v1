import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/list_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/screens/lists_screens/lists_screen.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';

class UpdateListScreen extends StatefulWidget {
  final ListModel list;

  const UpdateListScreen({super.key, required this.list});

  @override
  State<UpdateListScreen> createState() => _UpdateListScreenState();
}

class _UpdateListScreenState extends State<UpdateListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _listDao = ListDao();

  late String _selectedListType;
  late String _listDescription;
  final List<String> _listTypes = ['Lista de Acção', 'Lista de Entradas'];

  @override
  void initState() {
    super.initState();
    _selectedListType = widget.list.listType;
    _listDescription = widget.list.description;
  }

  Future<void> updateList() async {
    if (_formKey.currentState!.validate()) {
      final updatedList = ListModel(
        id: widget.list.id,
        userId: widget.list.userId,
        listType: _selectedListType,
        description: _listDescription,
      );

      await _listDao.update(updatedList, widget.list.id);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const ListsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: const Text('Atualizar Lista'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: defaultPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12.0,
                      children: [
                        Text('Tipo de Lista', style: tNormal),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: cBlackColor),
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedListType,
                              items: _listTypes.map((String listType) {
                                return DropdownMenuItem<String>(
                                  value: listType,
                                  child: Text(listType, style: tNormal),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedListType = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text('Descrição', style: tNormal),
                        TextFormField(
                          initialValue: _listDescription,
                          decoration: inputDecoration,
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Deve conter a descrição da lista';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _listDescription = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: updateList,
                    child: const MainButton(buttonText: 'Atualizar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
