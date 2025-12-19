import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/providers/life_area_provider.dart';
import 'package:kwanga/widgets/buttons/bottom_action_bar.dart';
import '../../models/life_area_model.dart';
import '../../widgets/feedback_widget.dart';

class CreateLifeAreaScreen extends ConsumerStatefulWidget {
  final LifeAreaModel? areaToEdit;

  const CreateLifeAreaScreen({super.key, this.areaToEdit});

  @override
  ConsumerState<CreateLifeAreaScreen> createState() =>
      _CreateLifeAreaScreenState();
}

class _CreateLifeAreaScreenState extends ConsumerState<CreateLifeAreaScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int? _selectedIconIndex;
  bool _isSaving = false;
  bool _showIconError = false;

  @override
  void initState() {
    super.initState();

    if (widget.areaToEdit != null) {
      _controller.text = widget.areaToEdit!.designation;

      final iconPath = widget.areaToEdit!.iconPath;
      final match = RegExp(r'(\d+)\.png').firstMatch(iconPath);

      if (match != null) {
        final iconNumber = int.parse(match.group(1)!);
        _selectedIconIndex = iconNumber - 1; // Converte para índice do grid (0-based)
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveLifeArea() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    setState(() => _showIconError = _selectedIconIndex == null);

    if (!isValid || _selectedIconIndex == null) return;

    setState(() => _isSaving = true);

    try {
      final iconPath = 'assets/icons/${_selectedIconIndex! + 1}.png';

      if (widget.areaToEdit == null) {
        // MODO CRIAR
        await ref.read(lifeAreasProvider.notifier).addLifeArea(
          designation: _controller.text.trim(),
          iconPath: iconPath,
        );
        showFeedbackScaffoldMessenger(context, "Área adicionada com sucesso");
      } else {
        // MODO EDITAR
        final updated = widget.areaToEdit!.copyWith(
          designation: _controller.text.trim(),
          iconPath: iconPath,
          isDeleted: false,
          isSynced: false,
        );

        await ref.read(lifeAreasProvider.notifier).updateLifeArea(updated);
        showFeedbackScaffoldMessenger(context, "Área actualizada com sucesso");
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return inputDecoration.copyWith(
      errorStyle: tSmallTitle.copyWith(color: errorColor, fontSize: 12),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1),
        borderRadius: (inputDecoration.border as OutlineInputBorder?)?.borderRadius ??
            BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorColor, width: 1),
        borderRadius: (inputDecoration.border as OutlineInputBorder?)?.borderRadius ??
            BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildIconGrid(BuildContext context) {
    return SizedBox(
      height: 480,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (_, index) {
          final isSelected = _selectedIconIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIconIndex = index;
                _showIconError = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? cSecondaryColor.withAlpha(40)
                    : cBlackColor.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: cSecondaryColor, width: 1)
                    : null,
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/${index + 1}.png',
                  width: 40,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoration = _buildInputDecoration(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final isEditing = widget.areaToEdit != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(isEditing ? 'Editar Área da Vida' : 'Nova Área da Vida'),
      ),
      backgroundColor: cWhiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digite a área da vida',
                  style: tTitle.copyWith(color: cMainColor),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controller,
                  maxLines: 1,
                  decoration: decoration.copyWith(
                    hintText: 'Nova área da vida',
                    hintStyle: tNormal.copyWith(
                      color: cBlackColor.withAlpha(60),
                    ),
                  ),
                  validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'Este campo é obrigatório'
                      : null,
                ),
                const SizedBox(height: 24),
                Text(
                  'Selecione o ícone',
                  style: tTitle.copyWith(color: cMainColor),
                ),
                if (_showIconError)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text(
                      'Deve escolher um ícone',
                      style: tSmallTitle.copyWith(
                        color: errorColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // 🟢 AQUI ESTAVA FALTANDO - Exibir o grid de ícones
                Expanded(
                  child: _buildIconGrid(context),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        buttonText: _isSaving
            ? (isEditing ? 'Actualizando...' : 'Salvando...')
            : (isEditing ? 'Actualizar' : 'Salvar'),
        onPressed: _isSaving ? null : () { _saveLifeArea(); },
      ),
    );
  }
}