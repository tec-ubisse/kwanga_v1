import 'package:flutter/material.dart';

Future<void> submitForm({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required Future<void> Function() onValid,
}) async {
  if (!formKey.currentState!.validate()) return;

  try {
    await onValid();
  } catch (e) {
    ScaffoldMessenger(
      child: SnackBar(content: Text(e.toString())),
    );
  }
}
