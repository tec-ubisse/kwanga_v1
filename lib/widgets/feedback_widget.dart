import 'package:flutter/material.dart';

void showFeedbackScaffoldMessenger(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(message),
          Image.asset('assets/gifs/check.gif', width: 40.0),
        ],
      ),
    ),
  );
}
