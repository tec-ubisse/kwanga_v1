import 'package:flutter/material.dart';
import 'package:kwanga/screens/login_screens/register_screen.dart';
import 'package:kwanga/screens/main_screen.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import '../../custom_themes//blue_accent_theme.dart';
import '../../custom_themes/text_style.dart';
import '../../domain/usecases/auth_usecases.dart';

class EmailVerification extends StatefulWidget {
  final String email;

  const EmailVerification({super.key, required this.email});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final _formKey = GlobalKey<FormState>();
  String _code = '';

  Future<void> verifyEmail(String email, String code) async {
    final AuthUseCases _auth = AuthUseCases();
    final success = await _auth.verifyEmail(email, code);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código errado! Tente novamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cMainColor,
      appBar: AppBar(backgroundColor: cMainColor, foregroundColor: cWhiteColor),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            Column(children: [Text('Verificação de email', style: tTitle)]),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: cWhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  spacing: 24.0,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Insira o código que recebeu no e-mail',
                          style: tTitle.copyWith(
                            color: cMainColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.0,
                          ),
                        ),
                        Text(
                          'Enviamos um código de verificação para ${widget.email}',
                          style: tNormal,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Column(
                      spacing: 8.0,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira o código';
                            }
                          },
                          onChanged: (value) {
                            _code = value;
                            print(_code);
                          },
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: cBlackColor),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: cSecondaryColor,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            spacing: 4.0,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Não recebeu o código?',
                                style: tNormal.copyWith(fontSize: 12.0),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Reenviar',
                                  style: tSmallTitle.copyWith(fontSize: 12.0),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '01:48',
                                style: tNormal.copyWith(fontSize: 12.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 256.0),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          verifyEmail(widget.email, _code);
                        }
                      },
                      child: MainButton(buttonText: 'Verificar'),
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
