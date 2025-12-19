import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/text_style.dart';

class SelectListDialog extends StatelessWidget {
  final List actionLists;

  const SelectListDialog({
    super.key,
    required this.actionLists,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.55;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF235E8B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_copy_sharp, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Mover tarefa para',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // LISTA COM SEPARADORES
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: actionLists.length,
                itemBuilder: (_, i) {
                  final p = actionLists[i];
                  final isLast = i == actionLists.length - 1;

                  return Column(
                    children: [
                      ListTile(
                        title: Text(p.title, style: tNormal),
                        onTap: () => Navigator.pop(context, p.id),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                      ),

                      // SEPARADOR ENTRE PROJECTOS
                      if (!isLast)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(height: 1, color: Colors.black12),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
