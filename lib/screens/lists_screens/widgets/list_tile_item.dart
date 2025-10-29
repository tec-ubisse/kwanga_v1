import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/data/database/task_dao.dart';

import '../../task_screens/list_task_screen.dart';

class ListTileItem extends StatelessWidget {
  final ListModel listModel;
  const ListTileItem({super.key, required this.listModel});

  Future<Map<String, int>> _loadTaskCount() async {
    final taskDao = TaskDao();

    // Apenas listas de ação têm tarefas concluídas
    if (listModel.listType != 'Lista de Acção') {
      return {'completed': 0, 'total': 0};
    }

    return await taskDao.getTaskProgress(listModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _loadTaskCount(),
      builder: (context, snapshot) {
        int completed = 0;
        int total = 0;

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Enquanto carrega, mostra placeholders sutis
          return ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(listModel.description, style: tNormal),
            subtitle: listModel.listType == 'Lista de Acção'
                ? Text('A carregar tarefas...', style: tNormal.copyWith(color: Colors.grey))
                : Text(listModel.listType, style: tNormal.copyWith(color: Colors.grey)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          );
        }

        if (snapshot.hasData) {
          completed = snapshot.data!['completed'] ?? 0;
          total = snapshot.data!['total'] ?? 0;
        }

        return ListTile(
          tileColor: Color(0xffEAEFF4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(listModel.description, style: tTitle.copyWith(color: cBlackColor)),
          subtitle: Row(
            spacing: 8.0,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (listModel.listType == 'Lista de Acção')
                if(total > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: CircularProgressIndicator(
                        value: completed / total,
                        backgroundColor: cSecondaryColor.withAlpha(50),
                        color: cSecondaryColor.withAlpha(200),
                      ),
                    ),
                  ),

              listModel.listType == 'Lista de Acção'
                  ? Text(
                '$completed / $total tarefas concluídas',
                style: tNormal.copyWith(color: Colors.grey[700]),
              )
                  : Text(
                listModel.listType,
                style: tNormal.copyWith(color: Colors.grey[700]),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ListTasksScreen(listModel: listModel),
                ),
              );
            },
        );
      },
    );
  }
}
