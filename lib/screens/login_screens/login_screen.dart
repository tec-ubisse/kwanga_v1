import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/screens/login_screens/register_screen.dart';
import 'package:kwanga/widgets/buttons/icon_button.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';
import '../../models/user.dart';
import '../../services/connection_wrapper.dart';
import '../task_screens/task_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;
  late final ProviderSubscription<AsyncValue<UserModel?>> _authListener;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    // Listener para o estado de autenticação
    _authListener = ref.listenManual<AsyncValue<UserModel?>>(
      authProvider,
          (previous, next) {
        next.whenOrNull(
          data: (user) {
            if (user != null && mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const ConnectionWrapper(
                    child: TaskScreen(),
                  ),
                ),
              );
            }
          },
          error: (err, _) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(content: Text('Erro ao fazer login: $err')),
              );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authListener.close();
    super.dispose();
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

    return Scaffold(
      backgroundColor: cMainColor,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AbsorbPointer(
                        absorbing: isLoading,
                        child: Column(
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Campo Email
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: _inputDecoration('Email'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Digite um email';
                                      }
                                      final emailRegex = RegExp(
                                        r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      );
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Email inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24.0),

                                  // Campo Senha
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: _inputDecoration('Senha').copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: cSecondaryColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Este campo não pode estar vazio';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 24.0),

                                  // Botão de Login
                                  isLoading
                                      ? const CircularProgressIndicator()
                                      : GestureDetector(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        ref
                                            .read(authProvider.notifier)
                                            .login(
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                        );
                                      }
                                    },
                                    child: const MainButton(
                                      buttonText: 'Entrar',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24.0),

                            // Separador “ou entre com”
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: cBlackColor,
                                    thickness: 1,
                                    endIndent: 10,
                                  ),
                                ),
                                Text('ou entre com', style: tNormal),
                                Expanded(
                                  child: Divider(
                                    color: cBlackColor,
                                    thickness: 1,
                                    indent: 10,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24.0),

                            // Botões sociais
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CustomIconButton(iconName: 'google'),
                                SizedBox(width: 8.0),
                                CustomIconButton(iconName: 'apple_logo'),
                                SizedBox(width: 8.0),
                                CustomIconButton(iconName: 'microsoft'),
                              ],
                            ),

                            const SizedBox(height: 24.0),

                            // Link para registo
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Não tem uma conta?', style: tNormal),
                                const SizedBox(width: 4.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    ' Registe-se aqui',
                                    style: tSmallTitle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
