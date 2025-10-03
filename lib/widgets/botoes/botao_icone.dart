import 'package:flutter/material.dart';
import 'package:kwanga/temas/foco_sereno.dart';

class BotaoIcone extends StatelessWidget {
  final String nome_icone;
  const BotaoIcone({super.key, required this.nome_icone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: cPreto,
          style: BorderStyle.solid,
          width: 1.0,
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset('assets/icons/$nome_icone.png', width: 24.0,),
      ),
    );
  }
}
