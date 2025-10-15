import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kwanga/screens/login_screens/login_screen.dart';
import 'package:kwanga/screens/main_screen.dart';
import 'package:kwanga/utils/secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final token = await SecureStorage.getToken();

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kwanga App',
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}
