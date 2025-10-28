

import 'package:kwanga/data/repositories/Life_area_repository.dart';

class LifeAreaUseCases {
  final LifeAreaRepository _repo = LifeAreaRepository();



  Future<void> syncPendingLifeAreas() async{
    await _repo.syncPendingLifeAreas();
  }

  Future<void> fetchAndSaveRemoteLifeAreas() async {
    await _repo.fetchAndSaveRemoteLifeAreas();
  }

}