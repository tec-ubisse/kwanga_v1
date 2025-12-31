import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/widgets/kwanga_dropdown_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<EditProfileScreen> {
  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();
  final _emailController = TextEditingController();

  final List<String> _genders = ['Feminino', 'Masculino', 'Outro'];
  String? _genderValue;

  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;

  bool _isSubmitting = false;

  // ------------------ INIT ------------------

  @override
  void initState() {
    super.initState();

    final user = ref.read(authProvider).value;

    _nomeController.text = user?.nome ?? '';
    _apelidoController.text = user?.apelido ?? '';
    _emailController.text = user?.email ?? '';
    _genderValue = user?.genero;

    if (user?.dataNascimento != null) {
      _selectedDay = user!.dataNascimento!.day;
      _selectedMonth = user.dataNascimento!.month;
      _selectedYear = user.dataNascimento!.year;
    }
  }

  // ------------------ DATA ------------------

  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(100, (i) => currentYear - i);
  }

  List<int> get _months => List.generate(12, (i) => i + 1);

  List<int> get _days {
    if (_selectedMonth == null || _selectedYear == null) return [];

    final daysInMonth = DateUtils.getDaysInMonth(
      _selectedYear!,
      _selectedMonth!,
    );

    return List.generate(daysInMonth, (i) => i + 1);
  }

  DateTime? get _birthDate {
    if (_selectedDay == null ||
        _selectedMonth == null ||
        _selectedYear == null) {
      return null;
    }

    return DateTime(
      _selectedYear!,
      _selectedMonth!,
      _selectedDay!,
    );
  }

  bool get _isFormValid {
    return _nomeController.text.trim().isNotEmpty &&
        _apelidoController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty;
  }

  // ------------------ SUBMIT ------------------

  Future<void> _handleSubmit() async {
    if (!_isFormValid || _isSubmitting) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final updated = user.copyWith(
        nome: _nomeController.text.trim(),
        apelido: _apelidoController.text.trim(),
        email: _emailController.text.trim(),
        genero: _genderValue,
        dataNascimento: _birthDate,
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      await ref
          .read(authProvider.notifier)
          .updateLocalProfile(updated);

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: Colors.white,
        title: const Text('Editar Perfil'),
      ),
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        color: cMainColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            const SizedBox(height: 18),
                            Text('Nome', style: tLabel),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nomeController,
                              decoration: inputDecoration,
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 24),

                            Text('Apelido', style: tLabel),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _apelidoController,
                              decoration: inputDecoration,
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 24),

                            Text('E-mail', style: tLabel),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              keyboardType:
                              TextInputType.emailAddress,
                              decoration: inputDecoration,
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 24),

                            Text('Gênero', style: tLabel),
                            KwangaDropdownButton<String>(
                              value: _genderValue,
                              labelText: '',
                              hintText: 'Escolha o gênero',
                              items: _genders
                                  .map(
                                    (g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g),
                                ),
                              )
                                  .toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (v) =>
                                  setState(() => _genderValue = v),
                            ),
                            const SizedBox(height: 24),

                            Text('Data de nascimento', style: tLabel),
                            Row(
                              children: [
                                Expanded(
                                  child: KwangaDropdownButton<int>(
                                    value: _selectedYear,
                                    labelText: '',
                                    hintText: 'Ano',
                                    items: _years
                                        .map(
                                          (y) => DropdownMenuItem(
                                        value: y,
                                        child: Text('$y'),
                                      ),
                                    )
                                        .toList(),
                                    onChanged: _isSubmitting
                                        ? null
                                        : (v) {
                                      setState(() {
                                        _selectedYear = v;
                                        _selectedDay = null;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: KwangaDropdownButton<int>(
                                    value: _selectedMonth,
                                    labelText: '',
                                    hintText: 'Mês',
                                    items: _months
                                        .map(
                                          (m) => DropdownMenuItem(
                                        value: m,
                                        child: Text('$m'),
                                      ),
                                    )
                                        .toList(),
                                    onChanged: _isSubmitting
                                        ? null
                                        : (v) {
                                      setState(() {
                                        _selectedMonth = v;
                                        _selectedDay = null;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: KwangaDropdownButton<int>(
                                    value: _selectedDay,
                                    labelText: '',
                                    hintText: 'Dia',
                                    items: _days
                                        .map(
                                          (d) => DropdownMenuItem(
                                        value: d,
                                        child: Text('$d'),
                                      ),
                                    )
                                        .toList(),
                                    onChanged: _isSubmitting
                                        ? null
                                        : (v) =>
                                        setState(() => _selectedDay = v),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ------------------ BOTÃO ------------------
                      SafeArea(
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cMainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: (!_isFormValid || _isSubmitting)
                                ? null
                                : _handleSubmit,
                            child: _isSubmitting
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Salvar alterações',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _apelidoController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
