import 'dart:convert';
import 'dart:io';

import 'package:ganesha/backend/api_configuration.dart';
import 'package:ganesha/backend/models/auth_models.dart';
import 'package:ganesha/utils/utilities.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_models.dart';

class Auth{
  static Future<AuthResponse?> login({required String email, required String password}) async{
    String loginUrl = '$baseUrl/user/login';

    LoginModel authData = LoginModel(email, password);
    http.Response? response = await Requests.post(url: loginUrl, body: authData, isAccessKeyNecessary: false);

    print(response == null);
    print(response!.body);

    if(response == null){
      return null;
    }

    if(response.statusCode == 400 || response.statusCode == 403){
      print(response.body);
      showMessage(response.body);
    }
    if(response.statusCode != 200) {
      return null;
    }

    final responseJson = jsonDecode(response.body);
    AuthResponse authResponse = AuthResponse.fromJson(responseJson);

    var now = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessKey', authResponse.tokens.accessToken);
    await prefs.setString('refreshKey', authResponse.tokens.refreshToken);
    await prefs.setString('user_id', authResponse.user.id);
    await prefs.setString('username', authResponse.user.fullName);
    await prefs.setBool('isAdmin', authResponse.user.role != UserRole.END_USER.name);
    await prefs.setInt('loginDate', DateTime(now.year, now.month, now.day).millisecondsSinceEpoch);
    await prefs.setInt('lastAdviceDate', -1);
    await prefs.setBool('microphone', Platform.isAndroid || Platform.isIOS);

    return authResponse;
  }

  static Future<AuthResponse?> signUp({required String fullName, required String email, required String password}) async{
    String registerUrl = '$baseUrl/user/register';

    RegisterModel authData = RegisterModel(fullName, email, password);
    http.Response? response = await Requests.post(url: registerUrl, body: authData, isAccessKeyNecessary: false);

    if(response == null){
      return null;
    }

    if(response.statusCode == 400) {
      showMessage(response.body);
    }

    if(response.statusCode != 201) {
      return null;
    }

    final responseJson = jsonDecode(response.body);
    AuthResponse authResponse = AuthResponse.fromJson(responseJson);

    var now = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessKey', authResponse.tokens.accessToken);
    await prefs.setString('refreshKey', authResponse.tokens.refreshToken);
    await prefs.setString('user_id', authResponse.user.id);
    await prefs.setString('username', authResponse.user.fullName);
    await prefs.setBool('isAdmin', authResponse.user.role != UserRole.END_USER.name);
    await prefs.setInt('loginDate', DateTime(now.year, now.month, now.day).millisecondsSinceEpoch);
    await prefs.setInt('lastAdviceDate', -1);
    await prefs.setBool('microphone', Platform.isAndroid || Platform.isIOS);

    return authResponse;
  }

}