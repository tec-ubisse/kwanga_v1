import 'package:flutter/material.dart';
import 'package:kwanga/screens/login_screens/login_screen.dart';
import 'package:kwanga/screens/login_screens/email_verification_screen.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/widgets/buttons/icon_button.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import 'package:kwanga/custom_themes/text_style.dart';

import 'package:kwanga/domain/usecases/auth_usecases.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthUseCases _auth = AuthUseCases();



  Future<void> _register() async {
    final success = await _auth.registerUser(
      _email,
      password,
    );
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Conta criada com sucesso')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EmailVerification(email: _email)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Falha ao criar conta')));
    }
  }

  bool acceptTerms = false;

  void changeTerms() {
    setState(() {
      acceptTerms = !acceptTerms;
    });
  }

  // variáveis de controle para validação
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var password = '';
  var terms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: cMainColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Column(
                      children: [
                        Text('Conta', style: tTitle),
                        Text(
                          'Nunca perca o seu progresso',
                          style: tNormal.copyWith(color: cWhiteColor),
                        ),
                      ],
                    ),
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
                            Form(
                              key: _formKey,
                              child: Column(
                                spacing: 24.0,
                                children: [
                                  // Campo de email
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      label: Text('Email'),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: cBlackColor,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: cSecondaryColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Digite um email';
                                      }

                                      final emailRegex = RegExp(
                                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                      );

                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Email inválido';
                                      }
                                      _email = value;
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _email = value!;
                                    },
                                  ),

                                  // Campo de senha
                                  TextFormField(
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      label: Text('Senha'),
                                      labelStyle: tNormal,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: cBlackColor,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: cSecondaryColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Digite uma senha';
                                      }
                                      if (value.length < 8) {
                                        return 'Senha fraca. Digite outra';
                                      }
                                      // return null;
                                    },
                                    onChanged: (value) {
                                      password = value;
                                    },
                                  ),

                                  // Campo de concordo com os termos
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        acceptTerms = !acceptTerms;
                                      });
                                      terms = acceptTerms;
                                    },
                                    child: Row(
                                      spacing: 8.0,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          acceptTerms
                                              ? Icons.check_box_outlined
                                              : Icons.check_box_outline_blank,
                                          color: cBlackColor,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Aceito os Termos de Condições de Uso',
                                            style: tNormal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  GestureDetector(
                                    child: MainButton(buttonText: 'Criar'),
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        if (!terms) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'É obrigatório aceitar os termos e condições',
                                              ),
                                            ),
                                          );
                                          return;
                                        } else {
                                          _register();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EmailVerification(email: _email,),
                                            ),
                                          );
                                        }
                                      }
                                      // Prosseguir com o cadastro
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Separador
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: cBlackColor,
                                    thickness: 1,
                                    endIndent:
                                        10, // espaço entre a linha e o texto
                                  ),
                                ),
                                Text('ou crie com', style: tNormal),
                                Expanded(
                                  child: Divider(
                                    color: cBlackColor,
                                    thickness: 1,
                                    indent:
                                        10, // espaço entre o texto e a linha
                                  ),
                                ),
                              ],
                            ),

                            // Botoes de provedores de email
                            Row(
                              spacing: 8.0,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconButton(iconName: 'google'),
                                CustomIconButton(iconName: 'apple_logo'),
                                CustomIconButton(iconName: 'microsoft'),
                              ],
                            ),

                            // Direcionando para a tela de Login
                            Row(
                              spacing: 4.0,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Já tem uma conta?', style: tNormal),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const LoginScreen()));
                                  },
                                  child: Text(
                                    'Faça o Login',
                                    style: tSmallTitle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
