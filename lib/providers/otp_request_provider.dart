import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/data/repositories/auth_repository.dart';

import 'otp_provider.dart';

final otpRequestProvider =
AsyncNotifierProvider<OtpRequestNotifier, void>(
  OtpRequestNotifier.new,
);

class OtpRequestNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  /// 📤 ENVIO DE OTP
  Future<void> requestOTP(String phoneWithPrefix, bool isLogin) async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(authRepositoryProvider);

      Map<String, dynamic> otpResponse;

      if (isLogin) {
        // ✅ LOGIN → backend gera OTP diretamente
        print('📱 Solicitando LOGIN OTP para: $phoneWithPrefix');
        otpResponse = await repo.requestLoginOTP(phoneWithPrefix);
      } else {
        // ✅ CADASTRO → primeiro verifica se pode registar
        print('📱 Verificando se pode REGISTAR: $phoneWithPrefix');
        final registerResponse = await repo.requestRegisterOTP(phoneWithPrefix);

        // Se chegou aqui, o registo foi aceite
        print('✅ Registo aceite, solicitando OTP...');

        // ⏱️ Pequeno delay para evitar sobrecarga no backend
        await Future.delayed(const Duration(milliseconds: 500));

        // Agora solicita o OTP via login
        otpResponse = await repo.requestLoginOTP(phoneWithPrefix);
      }

      /// 🔎 EXTRAÇÃO DO OTP
      final message = otpResponse['otp_message'] ?? otpResponse['message'];

      String? otp;
      if (message is String) {
        final match = RegExp(r'\d{6}').firstMatch(message);
        if (match != null) {
          otp = match.group(0);
        }
      }

      if (otp != null) {
        ref.read(otpProvider.notifier).setOTP(otp);
        print('🔐 OTP EXTRAÍDO (FRONTEND): $otp');
      } else {
        print('⚠️ OTP não encontrado na mensagem: $message');
      }

      print('✅ OTP ENVIADO (EVENTO)');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      print('❌ ERRO ao solicitar OTP: $e');
      state = AsyncValue.error(e, st);
    }
  }
}