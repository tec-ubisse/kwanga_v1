import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kwanga/domain/usecases/life_area_usecases.dart';
import 'package:kwanga/screens/login_screens/login_screen.dart';
import 'package:kwanga/screens/task_screens/task_screen.dart';
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
      home: isLoggedIn
          ? const ConnectionWrapper(child: TaskScreen())
          : const LoginScreen(),
      //home: const TaskScreen(),
    );
  }
}


class ConnectionWrapper extends StatefulWidget {

  final Widget child;
  const ConnectionWrapper({
  super.key, required this.child
});

  @override
State<ConnectionWrapper> createState() => _ConnectionWrapperState();

}

class _ConnectionWrapperState extends State<ConnectionWrapper>{

  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOnline = true;
  final LifeAreaUseCases _lifeAreaUseCases = LifeAreaUseCases();

  @override
  void initState(){
    super.initState();

  //Ira escutar as mudancas da conexao

    _subscription = Connectivity().onConnectivityChanged.listen((results) {

      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      bool hasConnection = result != ConnectivityResult.none;

   if(!mounted) return;

  if(hasConnection != _isOnline){

    setState(() => _isOnline = hasConnection);

    //Mostrar mensagem de conexao
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasConnection
                ? "Conexao restaurada!"
                : "Voce esta offline.",
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    });

    //Quando volta a ficar online, faz a sincronizacao
    if(hasConnection){
      _sincronizarDados();
}
}
});
}

  Future<void> _sincronizarDados() async {
    debugPrint("Sincornizando dados...");

    try {
      // Envia areas criadas localmente para o servidor
      await _lifeAreaUseCases.syncPendingLifeAreas();

      // Puxa as areas atualizados do servidor e salva localmente
      await _lifeAreaUseCases.fetchAndSaveRemoteLifeAreas();

      debugPrint("Sincronizacao concluida com sucesso");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sincronizacao concluída com sucesso.")),
      );
    } catch (e) {
      debugPrint("Erro ao sincronizar dados: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao sincronizar dados.")),
      );
    }
  }


@override
void dispose() {
_subscription.cancel();
super.dispose();
}

@override
Widget build(BuildContext context) {
return widget.child;
}

}
