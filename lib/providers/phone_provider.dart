import 'package:flutter_riverpod/flutter_riverpod.dart';

final phoneLoginProvider =
NotifierProvider<PhoneLoginNotifier, String>(
  PhoneLoginNotifier.new,
);

class PhoneLoginNotifier extends Notifier<String> {
  @override
  String build() => '';

  void addDigit(String digit) {
    if (state.length >= 9) return;
    state = state + digit;
  }

  void deleteLast() {
    if (state.isEmpty) return;
    state = state.substring(0, state.length - 1);
  }

  void clear() {
    state = '';
  }
}
