import 'package:flutter/material.dart';
import 'package:kwanga/screens//login_screens/register_screen.dart';
import 'package:kwanga/screens//purpose_screens/read_purposes.dart';
import 'package:kwanga/custom_themes//blue_accent_theme.dart';
import 'package:kwanga/screens/main_screen.dart';
import 'package:kwanga/widgets/buttons//icon_button.dart';
import 'package:kwanga/widgets/buttons//main_button.dart';
import 'package:kwanga/data/purposes.dart';

import '../../custom_themes//text_style.dart';
import '../../domain/usecases/auth_usecases.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthUseCases _auth = AuthUseCases();
  bool _loading = false;

  Future<void>_login() async {
    setState(() => _loading = true);
    final success = await _auth.loginUser(
      email, password
    );
    setState(() => _loading = false);

    if (success) {
      print(success.toString());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Credenciais inválidas')));
    }
  }

  bool acceptTerms = false;

  void alteraTermos() {
    setState(() {
      acceptTerms = !acceptTerms;
    });
  }

  // variáveis de controle para validação
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

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
                        Text('Login', style: tTitle),
                        Text(
                          'Bem-vindo de volta!',
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
                                      return null;
                                    },
                                    onChanged: (value) {
                                      email = value;
                                      print(email);
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
                                        return 'Este campo não pode estar vazio';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      password = value;
                                      print(password);
                                    },
                                  ),

                                  GestureDetector(
                                    onTap: (){
                                      if(_formKey.currentState!.validate()) {
                                        _login();
                                      }
                                    },
                                    child: MainButton(buttonText: 'Entrar'),
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
                                Text('ou entre com', style: tNormal),
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
                                Text('Não tem uma conta?', style: tNormal),
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
                                    'Registe-se aqui',
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
