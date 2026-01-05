import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:kwanga/providers/auth_provider.dart';
import 'package:kwanga/screens/lists_screens/lists_screen.dart';
import 'package:kwanga/screens/login_screens/phone_login.dart';
import 'package:kwanga/services/connection_wrapper.dart';

import 'package:kwanga/custom_themes/app_colors.dart';

import 'data/database/lists_dao.dart';
import 'data/services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ReminderService.init();

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

      theme: ThemeData(
        colorScheme: AppColors.lightScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: AppColors.darkScheme,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,

      locale: const Locale('pt'),
      supportedLocales: const [
        Locale('pt'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: authState.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => const Scaffold(
          body: Center(child: Text("Ocorreu um erro ao iniciar.")),
        ),
        data: (user) {
          if (user != null) {
            return const ConnectionWrapper(
              child: ListsScreen(listType: 'entry'),
            );
          }

          return const PhoneLogin(isLogin: true);
        },
      ),
    );
  }
}
