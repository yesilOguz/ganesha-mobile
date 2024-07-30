enum UserRole{
  END_USER
}

class UserGetModel{
  String id;
  String fullName;
  String email;
  bool recognized;

  UserGetModel(this.id, this.fullName, this.email, this.recognized);
  UserGetModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      fullName = json['full_name'] as String,
      email = json['email'] as String,
      recognized = bool.parse(json['recognized_user'].toString());

  Map toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'recognized_user': recognized
  };
}

class RenewPasswordModel{
  String password;

  RenewPasswordModel(this.password);
  RenewPasswordModel.fromJson(Map<String, dynamic> json)
    : password = json['password'] as String;

  Map toJson() => {
    'password': password
  };

}
