import 'package:uuid/uuid.dart';

class ListModel {
  String id;
  int userId; // chave estrangeira
  String listType;
  String description;

  static const _uuid = Uuid();

  ListModel({
    String? id,
    required this.userId,
    required this.listType,
    required this.description,
  }) : id = id ?? _uuid.v4();

  factory ListModel.fromMap(Map<String, dynamic> map) {
    return ListModel(
      id: map['id'] as String,
      userId: map['userId'] as int,
      listType: map['listType'] as String,
      description: map['description'] as String,
    );
  }
}
