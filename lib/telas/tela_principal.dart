import 'package:flutter/material.dart';
import 'package:kwanga/temas/foco_sereno.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: cPrincipal,),
      drawer: Drawer(),
      backgroundColor: cBranco,
    );
  }
}
