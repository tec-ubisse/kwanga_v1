import 'package:flutter/material.dart';
import 'package:kwanga/models/list_model.dart';
import '../../../custom_themes/text_style.dart';

class SelectListDialog extends StatelessWidget {
  final List<ListModel> lists;

  const SelectListDialog({
    super.key,
    required this.lists,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF235E8B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              spacing: 8.0,
              children: [
                Icon(Icons.send, color: Colors.white, size: 18.0,),
                const Text(
                  "Alocar à lista",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Área scrollável com altura máxima
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: lists.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final l = lists[i];
                  return ListTile(
                    title: Text(l.description, style: tNormal),
                    onTap: () => Navigator.pop(context, l.id),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}