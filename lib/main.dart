import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/screens/lists_screens/lists_screen.dart';
import 'package:kwanga/screens/login_screens/login_screen.dart';
import 'package:kwanga/services/connection_wrapper.dart';

/// Apenas para migrações iniciais controladas
import 'data/database/lists_dao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    debugPrint("AVISO: Não foi possível carregar .env");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Kwanga App',
      debugShowCheckedModeBanner: false,
      home: authState.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),

        error: (error, stack) => const Scaffold(
          body: Center(child: Text("Ocorreu um erro ao iniciar.")),
        ),

        data: (user) {
          if (user != null) {
            // Utilizador autenticado → entra direto na lista "entry"
            return const ConnectionWrapper(
              child: ListsScreen(listType: 'entry'),
            );
          }

          // Sem login → vai para ecrã de autenticação
          return const LoginScreen();
        },
      ),
    );
  }
}
