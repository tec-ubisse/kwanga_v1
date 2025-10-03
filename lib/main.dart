import 'package:flutter/material.dart';
import 'package:kwanga/telas/tela_cadastro.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff2C5F8D))),
    home: TelaCadastro(),
  ));
}
