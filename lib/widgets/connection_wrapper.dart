import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/providers/lists_provider.dart';

/// Envolve a tela principal e observa mudanças na conexão.
/// Mostra mensagens e faz sincronização automática ao voltar online.
class ConnectionWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const ConnectionWrapper({super.key, required this.child});

  @override
  ConsumerState<ConnectionWrapper> createState() => _ConnectionWrapperState();
}

class _ConnectionWrapperState extends ConsumerState<ConnectionWrapper> {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((results) async {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      final hasConnection = result != ConnectivityResult.none;

      if (!mounted) return;

      if (hasConnection != _isOnline) {
        setState(() => _isOnline = hasConnection);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                hasConnection ? 'Conexão restaurada!' : 'Você está offline.',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        });

        if (hasConnection) {
          await _sincronizarDados();
        }
      }
    });
  }

  Future<void> _sincronizarDados() async {
    debugPrint('Sincronizando dados...');
    try {
      // Chama o método de sincronização do provider
      await ref.read(listsProvider.notifier).syncPending();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronização concluída com sucesso.')),
      );
    } catch (e) {
      debugPrint('Erro ao sincronizar dados: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao sincronizar dados.')),
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
