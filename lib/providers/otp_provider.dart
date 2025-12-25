import 'package:flutter_riverpod/flutter_riverpod.dart';

final otpProvider = NotifierProvider<OtpNotifier, String>(
  OtpNotifier.new,
);

class OtpNotifier extends Notifier<String> {
  @override
  String build() => '';

  bool get isValid => state.length == 6;

  void addDigit(String digit) {
    if (state.length >= 6) return;
    state += digit;
  }

  void deleteLast() {
    if (state.isEmpty) return;
    state = state.substring(0, state.length - 1);
  }

  void clear() {
    state = '';
  }

  /// Método para preencher o OTP diretamente (usado ao colar da área de transferência)
  void setOTP(String otp) {
    // Valida que tem exatamente 6 dígitos
    if (otp.length == 6 && int.tryParse(otp) != null) {
      state = otp;
    }
  }
}