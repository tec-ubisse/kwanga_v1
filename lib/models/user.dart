class UserModel {
  int? id;       // gerado automaticamente pelo SQLite
  String email;
  String password;

  UserModel({
    this.id,
    required this.email,
    required this.password,
  });
}
