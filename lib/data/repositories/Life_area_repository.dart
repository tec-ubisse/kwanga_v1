

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:kwanga/data/database/life_area_dao.dart';
import 'package:kwanga/data/services/api_service.dart';

class LifeAreaRepository{

  final LifeAreaDao _dao = LifeAreaDao();
  final ApiService _api = ApiService();


  Future<void> syncPendingLifeAreas() async{

    final pendingAreas = await _dao.getPendingSync();

   for (final area in pendingAreas) {
     try {
       final res = await _api.post('life_areas',
         {
           'id': area.id,
           'user_id': area.userId,
           'designation': area.designation,
           'icon_path': area.iconPath,
           'created_at': area.createdAt,
           'updated_at': area.updatedAt,
         }, auth: true,);


       if (res.statusCode == 200 || res.statusCode == 201){
         await _dao.markAsSynced(area.id);
         debugPrint("Area '${area.designation}' sincronizada.");
       } else {
         debugPrint("Falha ao enviar '${area.designation}': ${res.body}");
       }
       }catch(e){
       debugPrint("Erro ao sincronizar '${area.designation}': $e");
     }
   }

  }

  Future<void> fetchAndSaveRemoteLifeAreas() async {
    try {
      final res = await _api.get('life_areas', auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List areas = data['data'] ?? [];

        for (final area in areas) {
          // TODO: Inserir ou atualizar no SQLite
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar areas do servidor: $e");
    }
  }
}


