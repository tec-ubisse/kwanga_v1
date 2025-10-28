import 'package:uuid/uuid.dart';

class Tarefa {
  final int status;
  final String content;
  final String id;

  static const _uuid = Uuid();

  Tarefa({String? id, required this.status, required this.content})
    : id = id ?? _uuid.v4();
}
