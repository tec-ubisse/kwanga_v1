import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/screens/lists_screens/lists_screen.dart';
import 'package:kwanga/screens/login_screens/personal_data_screen.dart';
import 'package:kwanga/screens/login_screens/widgets/auth/auth_background.dart';
import 'package:kwanga/screens/login_screens/widgets/auth/auth_header.dart';
import 'package:kwanga/screens/login_screens/widgets/auth/otp_input.dart';
import 'package:kwanga/screens/login_screens/widgets/keypad/numeric_keypad.dart';

import '../../custom_themes/blue_accent_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/phone_provider.dart';
import '../../providers/otp_provider.dart';
import '../../models/user.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final bool isLogin;
  final String initialOtp; // 🔒 agora é obrigatório

  const OTPScreen({
    super.key,
    required this.isLogin,
    required this.initialOtp,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  @override
  void initState() {
    super.initState();

    /// 🔑 Inicializa o OTP UMA VEZ
    Future.microtask(() {
      ref.invalidate(otpProvider);
      ref.read(otpProvider.notifier).setOTP(widget.initialOtp);
    });
  }

  String normalizePhone(String phone) {
    return phone.startsWith('+') ? phone : '+258$phone';
  }


  @override
  Widget build(BuildContext context) {
    final otp = ref.watch(otpProvider);
    final otpNotifier = ref.read(otpProvider.notifier);

    final phone = ref.read(phoneLoginProvider);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    /// 🔐 Listener do resultado final da autenticação
    ref.listen<AsyncValue<UserModel?>>(
      authProvider,
          (previous, next) {
        next.when(
          data: (user) {
            if (user != null && previous?.isLoading == true) {
              ref.invalidate(otpProvider);
              ref.invalidate(phoneLoginProvider);

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => widget.isLogin
                      ? ListsScreen(listType: 'entry')
                      : const PersonalDataScreen(),
                ),
                    (_) => false,
              );
            }
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
              ),
            );
          },
          loading: () {},
        );
      },
    );

    return Scaffold(
      backgroundColor: cMainColor,
      body: AuthBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 60),

            const AuthHeader(
              title: 'Insira o Código OTP',
              subtitle: 'recebido no seu telefone',
            ),

            OTPInput(value: otp),

            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  children: [
                    /// 📋 MOSTRA SEMPRE O OTP ATUAL
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: GestureDetector(
                        onTap: () async {
                          final clipboardData =
                          await Clipboard.getData('text/plain');
                          final copiedText = clipboardData?.text ?? '';

                          final digitsOnly =
                          copiedText.replaceAll(RegExp(r'[^0-9]'), '');

                          if (digitsOnly.length >= 6) {
                            otpNotifier.setOTP(
                              digitsOnly.substring(0, 6),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Nenhum código OTP válido encontrado',
                                ),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: cMainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: cMainColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.content_paste,
                                color: cMainColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                otp, // 🔥 nunca vazio
                                style: tNormal.copyWith(
                                  color: cMainColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    NumericKeypad(
                      onNumberTap: otpNotifier.addDigit,
                      onDelete: otpNotifier.deleteLast,
                      onClear: otpNotifier.clear,
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cMainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledBackgroundColor:
                          Colors.grey.shade300,
                        ),
                        onPressed: (!otpNotifier.isValid || isLoading)
                            ? null
                            : () {
                          ref
                              .read(authProvider.notifier)
                              .verifyOTP(
                            normalizePhone(phone),
                            otp,
                          );
                        },
                        child: isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          widget.isLogin
                              ? 'Login'
                              : 'Criar Conta',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
