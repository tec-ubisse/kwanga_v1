import 'package:flutter/material.dart';
import 'package:kwanga/telas/tela_login.dart';
import 'package:kwanga/telas/tela_principal.dart';

import 'package:kwanga/temas/foco_sereno.dart';
import 'package:kwanga/widgets/botoes/botao_icone.dart';
import 'package:kwanga/widgets/botoes/botao_principal.dart';

import '../temas/texto.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  bool _aceitoTermos = false;

  void _alteraTermos() {
    setState(() {
      _aceitoTermos = !_aceitoTermos;
    });
  }

  // variáveis de controle para validação
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _senha = '';
  var _termos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: cPrincipal,
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
                        Text('Criar conta', style: tTitulo),
                        Text(
                          'Nunca perca o seu progresso',
                          style: tNormal.copyWith(color: cBranco),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: cBranco,
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
                                        borderSide: BorderSide(color: cPreto),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: cSecundaria,
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
                                        borderSide: BorderSide(color: cPreto),
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: cSecundaria,
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
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _senha = value!;
                                    },
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _aceitoTermos = !_aceitoTermos;
                                      });
                                      _termos = _aceitoTermos;
                                    },
                                    child: Row(
                                      spacing: 8.0,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          _aceitoTermos
                                              ? Icons.check_box_outlined
                                              : Icons.check_box_outline_blank,
                                          color: cPreto,
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
                                    child: BotaoPrincipal(texto: 'Criar'),
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        if (!_termos) {
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
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const TelaPrincipal(),
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
                                    color: cPreto,
                                    thickness: 1,
                                    endIndent:
                                        10, // espaço entre a linha e o texto
                                  ),
                                ),
                                Text('ou crie com', style: tNormal),
                                Expanded(
                                  child: Divider(
                                    color: cPreto,
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
                                BotaoIcone(nome_icone: 'google'),
                                BotaoIcone(nome_icone: 'apple_logo'),
                                BotaoIcone(nome_icone: 'microsoft'),
                              ],
                            ),

                            // Direcionando para a tela de Login
                            Row(
                              spacing: 4.0,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Já tem uma conta?', style: tNormal),
                                GestureDetector(onTap: () {
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const TelaLogin()));
                                }, child: Text('Faça o Login', style: tTituloPequeno)),
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
