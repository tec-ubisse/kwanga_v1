import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:kwanga/models/list_model.dart';
import 'package:kwanga/data/database/list_dao.dart';
import 'package:kwanga/data/services/api_service.dart';

class ListsRepository {
  final ListDao _dao = ListDao();
  final ApiService _api = ApiService();

  Future<void> syncPendingLists() async{
    final pendingLists = await _dao.getPendingSync();
    for (final list in pendingLists) {
      try {
        final res = await _api.post('lists',
          {
            'id': list.id,
            'user_id': list.userId,
            'designation': list.description,
            'type': list.listType,
          }, auth: true,);


        if (res.statusCode == 200 || res.statusCode == 201){
          await _dao.markAsSynced(list.id);
          debugPrint("Lista '${list.description}' sincronizada.");
        } else {
          debugPrint("Falha ao enviar '${list.description}': ${res.body}");
        }
      }catch(e){
        debugPrint("Erro ao sincronizar '${list.description}': $e");
      }
    }

  }
}