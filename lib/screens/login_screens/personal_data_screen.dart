import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/screens/lists_screens/lists_screen.dart';
import 'package:kwanga/widgets/kwanga_dropdown_button.dart';

class PersonalDataScreen extends ConsumerStatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  ConsumerState<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends ConsumerState<PersonalDataScreen> {
  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();
  final _emailController = TextEditingController();

  final List<String> _genders = ["Feminino", "Masculino", "Outro"];
  late String _genderValue = _genders.first;

  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;

  String? _emailError;
  final _emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

  bool _isSubmitting = false;

  // ------------------ MESES ------------------

  String _monthName(int month) => [
    '',
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ][month];

  // ------------------ EMAIL ------------------

  void _validateEmail(String value) {
    if (value.trim().isEmpty) {
      setState(() => _emailError = 'Informe o e-mail');
      return;
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      setState(() => _emailError = 'E-mail inválido');
      return;
    }

    setState(() => _emailError = null);
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

    return DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
  }

  // ------------------ VALIDACAO ------------------

  bool get _isFormValid {
    return _nomeController.text.trim().isNotEmpty &&
        _apelidoController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _birthDate != null &&
        _emailError == null;
  }

  // ------------------ LOG ------------------

  void _logUserData() {
    debugPrint('🧑‍💼 DADOS DO USUÁRIO SALVOS:');
    debugPrint('➡️ Nome: ${_nomeController.text.trim()}');
    debugPrint('➡️ Apelido: ${_apelidoController.text.trim()}');
    debugPrint('➡️ E-mail: ${_emailController.text.trim()}');
    debugPrint('➡️ Gênero: $_genderValue');
    debugPrint(
      '➡️ Data de Nascimento: '
          '${_birthDate!.day.toString().padLeft(2, '0')}/'
          '${_birthDate!.month.toString().padLeft(2, '0')}/'
          '${_birthDate!.year}',
    );
  }

  // ------------------ SUBMIT ------------------

  Future<void> _handleSubmit() async {
    if (!_isFormValid || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      _logUserData();

      await ref.read(authProvider.notifier).updateUserProfile(
        nome: _nomeController.text.trim(),
        apelido: _apelidoController.text.trim(),
        email: _emailController.text.trim(),
        genero: _genderValue,
        dataNascimento: _birthDate!,
      );

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 100));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ListsScreen(listType: 'entry')),
        );
      }
    } catch (e) {
      debugPrint('❌ Erro no submit: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        color: cMainColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 0, 12),
              child: Text('Dados Pessoais', style: tTitle),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            Text('Nome', style: tLabel),
                            TextField(
                              controller: _nomeController,
                              decoration: inputDecoration,
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 24),
                            Text('Apelido', style: tLabel),
                            TextField(
                              controller: _apelidoController,
                              decoration: inputDecoration,
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 24),
                            Text('E-mail', style: tLabel),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: inputDecoration.copyWith(
                                errorText: _emailError,
                              ),
                              onChanged: _validateEmail,
                              enabled: !_isSubmitting,
                            ),
                            const SizedBox(height: 24),
                            Text('Gênero', style: tLabel),
                            KwangaDropdownButton<String>(
                              value: _genderValue,
                              labelText: '',
                              hintText: 'Escolha o seu Gênero',
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
                                  : (value) {
                                setState(() {
                                  _genderValue = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            Text('Data de nascimento', style: tLabel),
                            Row(
                              children: [
                                // ANO
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
                                // MÊS
                                Expanded(
                                  child: KwangaDropdownButton<int>(
                                    value: _selectedMonth,
                                    labelText: '',
                                    hintText: 'Mês',
                                    items: List.generate(12, (index) {
                                      final monthNum = index + 1;
                                      return DropdownMenuItem(
                                        value: monthNum,
                                        child: Text(_monthName(monthNum)),
                                      );
                                    }),
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
                                // DIA
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cMainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _handleSubmit,
            child: _isSubmitting
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'Salvar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
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