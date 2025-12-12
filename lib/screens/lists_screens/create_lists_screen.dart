import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/providers/lists_provider.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';

class CreateOrEditListScreen extends ConsumerStatefulWidget {
  final ListModel? existingList;

  const CreateOrEditListScreen({super.key, this.existingList});

  @override
  ConsumerState<CreateOrEditListScreen> createState() =>
      _CreateOrEditListScreenState();
}

class _CreateOrEditListScreenState
    extends ConsumerState<CreateOrEditListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  final List<Map<String, String>> _listTypes = [
    {"label": "Lista de Acções", "value": "action"},
    {"label": "Lista de Entradas", "value": "entry"},
  ];

  String? _selectedListType;
  String? _listTypeError;
  bool _isLoading = false;

  bool get isEditing => widget.existingList != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _selectedListType =
          (widget.existingList!.listType);
      _descriptionController.text = widget.existingList!.description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveOrUpdateList() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || _selectedListType == null) {
      if (_selectedListType == null) {
        setState(() =>
        _listTypeError = 'É obrigatório selecionar um tipo de lista');
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(listsProvider.notifier);

      if (isEditing) {
        final updatedList = widget.existingList!.copyWith(
          listType: (_selectedListType!),
          description: _descriptionController.text.trim(),
        );
        await notifier.updateList(updatedList);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lista atualizada com sucesso!'),
          ),
        );
      } else {
        await notifier.addList(
          listType: _selectedListType!,
          description: _descriptionController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lista adicionada com sucesso!'),
          ),
        );
      }

      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(isEditing ? 'Editar Lista' : 'Adicionar Lista'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: defaultPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipo de Lista', style: tNormal),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: _listTypeError != null
                                ? Theme.of(context).colorScheme.error
                                : cBlackColor,
                          ),
                        ),
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedListType,
                            hint:
                            const Text('Selecione um tipo de lista'),
                            items: _listTypes.map((item) {
                              return DropdownMenuItem<String>(
                                value: item["value"],
                                child:
                                Text(item["label"]!, style: tNormal),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedListType = value;
                                _listTypeError = null;
                              });
                            },
                          ),
                        ),
                      ),
                      if (_listTypeError != null)
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            _listTypeError!,
                            style: TextStyle(
                              color:
                              Theme.of(context).colorScheme.error,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      Text('Designação', style: tNormal),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: inputDecoration,
                        maxLines: 2,
                        maxLength: 30,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Deve conter a descrição da lista';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 24.0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                onTap: _saveOrUpdateList,
                child: MainButton(
                  buttonText: isEditing ? 'Actualizar' : 'Salvar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
