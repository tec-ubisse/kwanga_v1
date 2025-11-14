import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/screens/login_screens/email_verification_screen.dart';
import 'package:kwanga/screens/login_screens/login_screen.dart';
import 'package:kwanga/widgets/buttons/icon_button.dart';
import 'package:kwanga/widgets/buttons/main_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _acceptTerms = false;
  bool _isLoading = false;

  // 👁️ Controla se a senha está visível ou oculta
  bool _obscurePassword = true;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('É obrigatório aceitar os termos e condições')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada! Verifique o seu email.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EmailVerificationScreen(email: _emailController.text.trim()),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration:
                                const InputDecoration(labelText: 'Email'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Digite um email';
                                  }
                                  final emailRegex = RegExp(
                                      r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$");
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Email inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24.0),

                              // 👇 Campo de senha com botão de visibilidade
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
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
                                    return 'Digite uma senha';
                                  }
                                  if (value.length < 8) {
                                    return 'A senha deve ter pelo menos 8 caracteres';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24.0),
                              GestureDetector(
                                onTap: () => setState(
                                        () => _acceptTerms = !_acceptTerms),
                                child: Row(
                                  children: [
                                    Icon(
                                      _acceptTerms
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: cSecondaryColor,
                                    ),
                                    const SizedBox(width: 8.0),
                                    const Expanded(
                                      child: Text(
                                          'Aceito os Termos de Condições de Uso'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24.0),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : GestureDetector(
                                onTap: _submit,
                                child: const MainButton(
                                    buttonText: 'Criar'),
                              ),
                              const SizedBox(height: 24.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: cBlackColor,
                                      thickness: 1,
                                      endIndent: 10,
                                    ),
                                  ),
                                  Text('ou crie com', style: tNormal),
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Já tem uma conta?', style: tNormal),
                                  const SizedBox(width: 4.0),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) =>
                                        const LoginScreen(),
                                      ),
                                    ),
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
