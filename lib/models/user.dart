class UserModel {
  // Identidade
  final int? id;
  final String phone; // 🔴 obrigatório

  // Dados pessoais (opcionais)
  final String? nome;
  final String? apelido;
  final String? email;
  final String? genero;
  final DateTime? dataNascimento;

  // Controlo e sync
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  final bool isDeleted;

  // Auth
  final String? token;

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
    this.token,
    this.isSynced = true,
    this.isDeleted = false,
  });

  /// ------------------ TO MAP ------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'nome': nome,
      'apelido': apelido,
      'email': email,
      'genero': genero,
      'data_nascimento': dataNascimento?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_synced': isSynced,
      'is_deleted': isDeleted,
      'token': token,
    };
  }

  /// ------------------ FROM MAP ------------------

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final phone = map['phone']?.toString();

    if (phone == null || phone.isEmpty) {
      throw Exception('UserModel inválido: phone é obrigatório');
    }

    return UserModel(
      id: _parseInt(map['id']),
      phone: phone,
      nome: map['nome']?.toString(),
      apelido: map['apelido']?.toString(),
      email: map['email']?.toString(),
      genero: map['genero']?.toString(),
      dataNascimento: _parseDate(map['data_nascimento']),
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
      isSynced: _parseBool(map['is_synced'], defaultValue: true),
      isDeleted: _parseBool(map['is_deleted'], defaultValue: false),
      token: map['token']?.toString(),
    );
  }

  /// ------------------ COPY WITH ------------------

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
    String? token,
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
      token: token ?? this.token,
    );
  }

  /// ------------------ HELPERS ------------------

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return defaultValue;
  }
}
