class LoginModel{
  String email;
  String password;

  LoginModel(this.email, this.password);

  Map toJson() => {
    'email': email,
    'password': password,
  };
}

class RegisterModel{
  String fullName;
  String email;
  String password;

  RegisterModel(this.fullName, this.email, this.password);

  Map toJson() => {
    'full_name': fullName,
    'email': email,
    'password': password,
  };
}

class AuthTokens{
  String accessToken;
  String refreshToken;

  AuthTokens(this.accessToken, this.refreshToken);
  AuthTokens.fromJson(Map<String, dynamic> json)
    : accessToken = json['access_token'] as String,
      refreshToken = json['refresh_token'] as String;

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken
  };
}

class UserResponseModel{
  String id;
  String fullName;
  String email;
  bool recognizedUser;
  String role;

  UserResponseModel(
      this.id, this.fullName, this.email, this.recognizedUser, this.role);
  UserResponseModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      fullName = json['full_name'] as String,
      email = json['email'] as String,
      recognizedUser = bool.parse(json['recognized_user'].toString()),
      role = json['role'] as String;


  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'recognized_user': recognizedUser,
    'role': role
  };
}

class AuthResponse{
  UserResponseModel user;
  AuthTokens tokens;

  AuthResponse(this.user, this.tokens);
  AuthResponse.fromJson(Map<String, dynamic> json)
    : user = UserResponseModel.fromJson(json['user']),
      tokens = AuthTokens.fromJson(json['tokens']);

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'tokens': tokens.toJson()
  };
}

