import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import '../../custom_themes/blue_accent_theme.dart';
import '../../custom_themes/text_style.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  Timer? _timer;
  int _timerValue = 0;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerValue = 120;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerValue <= 1) {
        timer.cancel();
        setState(() {
          _timerValue = 0;
          _canResend = true;
        });
      } else {
        setState(() => _timerValue--);
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).resendVerificationCode(widget.email);
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código reenviado com sucesso!')),
    );
  }

  void _submitVerification() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      ref.read(authProvider.notifier).verifyEmail(
        widget.email,
        _codeController.text.trim(),
      );
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: tNormal,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: cBlackColor),
      borderRadius: BorderRadius.circular(12.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: cSecondaryColor, width: 2.0),
      borderRadius: BorderRadius.circular(12.0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AsyncLoading;

    ref.listen<AsyncValue>(authProvider, (_, state) {
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString())),
        );
      }
    });

    return Scaffold(
      backgroundColor: cMainColor,
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const Spacer(),
            Text('Verificação de email', style: tTitle),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: cWhiteColor,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Insira o código que recebeu no e-mail',
                      style: tTitle.copyWith(
                        color: cMainColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Enviamos um código de verificação para ${widget.email}',
                      style: tNormal,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24.0),

                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Código de Verificação'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira o código';
                        }
                        if (value.length < 4) {
                          return 'Código incompleto';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Text(
                            'Não recebeu o código?',
                            style: tNormal.copyWith(fontSize: 12.0),
                          ),
                          const SizedBox(width: 4.0),
                          GestureDetector(
                            onTap: _canResend ? _resendCode : null,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: tSmallTitle.copyWith(
                                fontSize: 12.0,
                                color: _canResend
                                    ? cMainColor
                                    : Colors.grey.shade500,
                              ),
                              child: Text(
                                _canResend ? 'Reenviar' : 'Aguarde...',
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (_timerValue > 0)
                            Text(
                              _formatTime(_timerValue),
                              style: tNormal.copyWith(
                                fontSize: 12.0,
                                color: Colors.grey.shade700,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 128.0),

                    isLoading
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                      onTap: _codeController.text.isEmpty
                          ? null
                          : _submitVerification,
                      child: Opacity(
                        opacity:
                        _codeController.text.isEmpty ? 0.6 : 1.0,
                        child: const MainButton(
                          buttonText: 'Verificar',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
