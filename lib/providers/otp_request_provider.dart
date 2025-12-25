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

  /// 📤 ENVIO DE OTP (DEV – SMS ainda não ativo)
  Future<void> requestOTP(String phoneWithPrefix, bool isLogin) async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(authRepositoryProvider);

      Map<String, dynamic>? otpResponse;

      if (isLogin) {
        // LOGIN → backend gera OTP
        otpResponse = await repo.requestLoginOTP(phoneWithPrefix);
      } else {
        // CADASTRO → backend NÃO gera OTP
        await repo.requestRegisterOTP(phoneWithPrefix);

        // 🔁 FRONTEND FORÇA GERAÇÃO DE OTP VIA LOGIN
        otpResponse = await repo.requestLoginOTP(phoneWithPrefix);
      }

      /// 🔎 EXTRAÇÃO DO OTP (AGORA SEMPRE EXISTE)
      final message =
          otpResponse['otp_message'] ?? otpResponse['message'];

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
        print('❌ OTP NÃO ENCONTRADO MESMO APÓS LOGIN');
      }

      print('✅ OTP ENVIADO (EVENTO)');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

}
