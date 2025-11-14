

import 'package:kwanga/data/repositories/lists_repository.dart';

class ListsUseCases {
  final ListsRepository _repo = ListsRepository();



  Future<void> syncPendingLists() async{
    await _repo.syncPendingLists();
  }

  // Future<void> fetchAndSaveRemoteLifeAreas() async {
  //   await _repo.fetchAndSaveRemoteLifeAreas();
  // }

}