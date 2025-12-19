import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/purpose_model.dart';

import 'package:kwanga/providers/life_area_provider.dart';
import 'package:kwanga/providers/purpose_provider.dart';

import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import 'package:kwanga/widgets/feedback_widget.dart';
import 'package:kwanga/widgets/kwanga_dropdown_button.dart';

class CreatePurposeScreen extends ConsumerStatefulWidget {
  final PurposeModel? existingPurpose;

  const CreatePurposeScreen({
    super.key,
    this.existingPurpose,
  });

  @override
  ConsumerState<CreatePurposeScreen> createState() =>
      _CreatePurposeScreenState();
}

class _CreatePurposeScreenState
    extends ConsumerState<CreatePurposeScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedLifeAreaId;
  String? _lifeAreaError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingPurpose != null) {
      _controller.text = widget.existingPurpose!.description;
      _selectedLifeAreaId = widget.existingPurpose!.lifeAreaId;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _savePurpose() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _lifeAreaError = null);

    if (_selectedLifeAreaId == null) {
      setState(() {
        _lifeAreaError = 'Selecione uma área da vida';
      });
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(purposesProvider.notifier);

      if (widget.existingPurpose == null) {

        await notifier.addPurpose(
          lifeAreaId: _selectedLifeAreaId!,
          description: _controller.text.trim(),
        );
      } else {

        final updated = widget.existingPurpose!.copyWith(
          lifeAreaId: _selectedLifeAreaId!,
          description: _controller.text.trim(),
          isSynced: false,
        );

        await notifier.editPurpose(updated);
      }

      if (!mounted) return;

      showFeedbackScaffoldMessenger(
        context,
        'Propósito salvo com sucesso',
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return inputDecoration.copyWith(
      hintText: 'Ex: Viver de forma equilibrada...',
      hintStyle: tNormal.copyWith(
        color: cBlackColor.withAlpha(60),
      ),
      errorStyle: tSmallTitle.copyWith(
        color: errorColor,
        fontSize: 12,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1),
        borderRadius:
        (inputDecoration.border as OutlineInputBorder?)?.borderRadius ??
            BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1),
        borderRadius:
        (inputDecoration.border as OutlineInputBorder?)?.borderRadius ??
            BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoration = _buildInputDecoration(context);
    final isEditing = widget.existingPurpose != null;
    final lifeAreasAsync = ref.watch(lifeAreasProvider);

    return Scaffold(
      backgroundColor: cWhiteColor,
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(isEditing ? 'Editar Propósito' : 'Criar Propósito'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'Área da vida',
                  style: tSmallTitle,
                ),
                const SizedBox(height: 8),

                lifeAreasAsync.when(
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (_, _) =>
                  const Text('Erro ao carregar áreas da vida'),
                  data: (areas) {
                    return KwangaDropdownButton<String>(
                      labelText: '',
                      hintText: 'Selecione a área da vida',
                      value: _selectedLifeAreaId,
                      errorMessage: _lifeAreaError,
                      items: areas.map((LifeAreaModel area) {
                        return DropdownMenuItem<String>(
                          value: area.id,
                          child: Text(area.designation),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLifeAreaId = value;
                          _lifeAreaError = null;
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                Text(
                  'Descrição do propósito',
                  style: tSmallTitle,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controller,
                  maxLines: 4,
                  decoration: decoration,
                  validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'Este campo é obrigatório'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        buttonText: _isSaving
            ? (isEditing ? 'Atualizando...' : 'Salvando...')
            : (isEditing ? 'Actualizar' : 'Salvar'),
        onPressed: _isSaving ? null : _savePurpose,
      ),
    );
  }
}
