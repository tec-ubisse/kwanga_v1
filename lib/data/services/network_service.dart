import 'package:connectivity_plus/connectivity_plus.dart';

class NeteorkService{

  final Connectivity _connectivity = Connectivity();


  // FUncao para verificar o estado atual da conexao

Future<bool> isConnected() async {
  var result = await _connectivity.checkConnectivity();
  return result != ConnectivityResult.none;
}


//Emite atyalizacoes quando a conexao muda

Stream<List<ConnectivityResult>> get onConnectivityChanged {
  return _connectivity.onConnectivityChanged;
}


}