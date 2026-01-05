class UserModel {
  final int? id;
  final String phone;

  final String? nome;
  final String? apelido;
  final String? email;
  final String? genero;
  final DateTime? dataNascimento;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final bool isSynced;
  final bool isDeleted;

  UserModel({
    this.id,
    required this.phone,
    this.nome,
    this.apelido,
    this.email,
    this.genero,
    this.dataNascimento,
    this.createdAt,
    this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  UserModel copyWith({
    int? id,
    String? phone,
    String? nome,
    String? apelido,
    String? email,
    String? genero,
    DateTime? dataNascimento,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      nome: nome ?? this.nome,
      apelido: apelido ?? this.apelido,
      email: email ?? this.email,
      genero: genero ?? this.genero,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
