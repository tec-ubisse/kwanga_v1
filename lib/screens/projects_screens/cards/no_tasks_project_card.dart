import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

class NoTasksProjectCard extends StatelessWidget {
  const NoTasksProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/gifs/no_tasks_project.gif", width: 100),
          Text(
            'Sem tarefas ainda',
            style: tSmallTitle.copyWith(color: cBlackColor),
          ),
          Text(
            'Clique no botão abaixo para adicionar tarefas e melhor organizar o seu projecto',
            style: tNormal, textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
