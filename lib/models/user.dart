class UserModel {
  final int? id;
  final String? email;
  final String? password;

  UserModel({
    this.id,
    this.email,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      email: map['email']?.toString(),
      password: map['password']?.toString(),
    );
  }
}
