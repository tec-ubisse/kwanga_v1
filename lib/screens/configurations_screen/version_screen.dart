import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/screens/configurations_screen/version_tile.dart';
import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';

class VersionScreen extends StatelessWidget {
  final String currentVersion;

  const VersionScreen({super.key, required this.currentVersion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text('Versão'),
      ),
      // drawer: CustomDrawer(),
      body: Padding(
        padding: defaultPadding,
        child: ListView(
          children: [
            VersionTile(title: 'Nome do Aplicativo', description: 'Kwanga'),
            VersionTile(
              title: 'Versão do Aplicativo',
              description: currentVersion,
            ),
            VersionTile(
              title: 'Data de Lançamento',
              description: '30 de Outubro de 2025',
            ),
            VersionTile(
              title: 'Destaques da Versão',
              description:
                  'Esta nova versão traz grandes melhorias na organização da informação e facilita a instalação do aplicativo! \n'
                      '🧿 Instalação Direta: Agora você pode instalar o aplicativo diretamente no seu celular Android através do nosso novo ficheiro APK! \n'
                      '🧿 Visualização Clara: Separamos as suas Listas e Tarefas em abas diferentes para que a sua tela fique muito mais organizada e fácil de usar.',
            ),
            VersionTile(
              title: 'Novas Funcionalidades',
              description:
              'Disponibilidade do Ficheiro APK: Lançamento de um ficheiro APK para permitir a instalação direta do aplicativo em dispositivos Android, oferecendo uma opção de instalação mais flexível fora das lojas de aplicativos.',
            ),
            VersionTile(
              title: 'Correções de Bugs',
              description: 'Erros de renderização de Layout (não havia espaço suficente para albergar todos os itens de uma tela)',
            ),
            VersionTile(
              title: 'Melhorias',
              description:
              'Visualização Separada de Listas e Tarefas: A interface principal foi redesenhada para separar claramente a exibição das suas Listas e das Tarefas individuais. Isso resolve o problema de confusão visual, tornando o acompanhamento das suas atividades muito mais eficiente.',
            ),
          ],
        ),
      ),
    );
  }
}
