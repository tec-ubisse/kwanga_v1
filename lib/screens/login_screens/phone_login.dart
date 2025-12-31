import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/screens/login_screens/otp_screen.dart';

import '../../providers/phone_provider.dart';
import '../../providers/otp_provider.dart';
import '../../providers/otp_request_provider.dart';

class PhoneLogin extends ConsumerStatefulWidget {
  final bool isLogin;

  const PhoneLogin({super.key, required this.isLogin});

  @override
  ConsumerState<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends ConsumerState<PhoneLogin> {
  bool _otpRequested = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ref.listen<AsyncValue<void>>(
      otpRequestProvider,
          (previous, next) {
        if (_otpRequested &&
            previous is AsyncLoading &&
            next is AsyncData) {
          _otpRequested = false;

          final otp = ref.read(otpProvider);
          print('🔐 OTP RECEBIDO: $otp');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPScreen(
                isLogin: widget.isLogin,
                initialOtp: otp,
              ),
            ),
          );
        }

        if (next.hasError) {
          _otpRequested = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    final phone = ref.watch(phoneLoginProvider);
    final isValid = phone.length == 9;
    final otpRequestState = ref.watch(otpRequestProvider);

    return Scaffold(
      backgroundColor: cMainColor,
      body: Stack(
        children: [
          /// Background
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/img.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          /// Content
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Header
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isLogin ? 'Login' : 'Cadastro',
                      style: tTitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.isLogin
                          ? 'Bem-vindo(a) de volta!'
                          : 'Nunca perca o seu progresso!',
                      style: tNormal.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              /// Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: cWhiteColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Campo telefone
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cMainColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.grey),
                            const SizedBox(width: 12),
                            Text(
                              '+258 ',
                              style: tNormal.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                phone.isEmpty
                                    ? 'Número de telefone'
                                    : phone,
                                style: phone.isEmpty
                                    ? tNormal.copyWith(color: Colors.grey)
                                    : tNormal,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Keypad
                      _buildKeypad(),

                      const SizedBox(height: 16),

                      /// 🔵 BOTÃO ENVIAR OTP
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cMainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBackgroundColor:
                            Colors.grey.shade300,
                          ),
                          onPressed: (isValid &&
                              !otpRequestState.isLoading)
                              ? () {
                            _otpRequested = true;

                            ref
                                .read(
                                otpRequestProvider.notifier)
                                .requestOTP(
                              '+258$phone',
                              widget.isLogin,
                            );
                          }
                              : null,
                          child: otpRequestState.isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Enviar código OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 🔁 LOGIN / CADASTRO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.isLogin
                                ? 'Não tem uma conta? '
                                : 'Já tem uma conta? ',
                            style:
                            tNormal.copyWith(fontSize: 12),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref.invalidate(phoneLoginProvider);
                              ref.invalidate(otpProvider);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PhoneLogin(
                                    isLogin: !widget.isLogin,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              widget.isLogin
                                  ? 'Cadastre-se aqui'
                                  : 'Faça login',
                              style: tNormal.copyWith(
                                color: cSecondaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------ KEYPAD ------------------

  Widget _buildKeypad() {
    final notifier = ref.read(phoneLoginProvider.notifier);

    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      'del', '0', 'clear',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (_, index) {
        final key = keys[index];

        if (key == 'del') {
          return _iconKey(
            Icons.backspace,
            notifier.deleteLast,
          );
        }

        if (key == 'clear') {
          return _iconKey(
            Icons.clear,
            notifier.clear,
          );
        }

        return _numberKey(key, notifier);
      },
    );
  }

  Widget _numberKey(String value, PhoneLoginNotifier n) {
    return GestureDetector(
      onTap: () => n.addDigit(value),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(value, style: tNumberText),
      ),
    );
  }

  Widget _iconKey(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
