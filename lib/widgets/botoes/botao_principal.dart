import 'package:flutter/material.dart';
import 'package:kwanga/temas/foco_sereno.dart';
import 'package:kwanga/temas/texto.dart';

class BotaoPrincipal extends StatelessWidget {
  final String texto;
  const BotaoPrincipal({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: cPrincipal
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Center(child: Text(texto, style: tBotao,),),
      ),
    );
  }
}
