import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/screens/login_screens/login_screen.dart';
import 'package:kwanga/screens/task_screens/task_screen.dart';
import 'package:kwanga/widgets/connection_wrapper.dart';

import 'data/database/list_dao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('ERRO CRÍTICO DE INICIALIZAÇÃO: \$e');
  }

  await ListDao().normalizeAllListTypes();

  final all = await ListDao().getAllByUser(1); // ou o ID do teu user
  for (final l in all) {
    debugPrint("LISTA: ${l.description}  |  TYPE: ${l.listType}");
  }


  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
        error: (error, stackTrace) => const Scaffold(
          body: Center(child: Text('Ocorreu um erro.')),
        ),
        data: (user) {
          if (user != null) {
            return const ConnectionWrapper(child: TaskScreen());
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
