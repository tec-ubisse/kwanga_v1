import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/data/database/list_dao.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/screens/lists_screens/lists_screen.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';

import '../../domain/usecases/auth_usecases.dart';
import '../../models/user.dart';

class CreateListsScreen extends StatefulWidget {
  const CreateListsScreen({super.key});

  @override
  State<CreateListsScreen> createState() => _CreateListsScreenState();
}

class _CreateListsScreenState extends State<CreateListsScreen> {
  String? _selectedListType;
  String? _listDescription;
  final List<String> _listTypes = ['Lista de Acção', 'Lista de Entradas'];
  final _formKey = GlobalKey<FormState>();
  final _listDao = ListDao();
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    final AuthUseCases _auth = AuthUseCases();
    final success = await _auth.getUserData();
  }

  void saveList() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedListType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um tipo de lista')),
        );
        return;
      }

      final newList = ListModel(
        userId: 14,
        listType: _selectedListType!,
        description: _listDescription!,
      );
      await _listDao.insert(newList);

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (ctx) => ListsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text('Adicionar Lista'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
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
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedListType,
                                hint: const Text('Selecione um tipo de lista'),
                                items: _listTypes.map((String listType) {
                                  return DropdownMenuItem<String>(
                                    value: listType,
                                    child: Text(listType, style: tNormal),
                                  );
                                }).toList(),
                                onChanged: (String? selectedListType) {
                                  setState(() {
                                    _selectedListType = selectedListType!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text('Descrição', style: tNormal),
                          TextFormField(
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
                  ],
                ),
              ),
            ),
                ),
                ),
          ),
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: GestureDetector(
                onTap: saveList,
                child: MainButton(buttonText: 'Salvar'),
              ),
            ),
          )
        ],
      ),

    );
  }
}
