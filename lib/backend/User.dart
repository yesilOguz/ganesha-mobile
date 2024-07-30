import 'dart:convert';

import 'package:ganesha/backend/api_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'models/user_models.dart';

class User{
  static Future<UserGetModel?> getMe() async{
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    
    String userGetMeUrl = '$baseUrl/user/get-user/$userId';
    
    http.Response? response = await Requests.get(url: userGetMeUrl, isAccessKeyNecessary: true);

    if(response == null || response.statusCode != 200){
      return null;
    }

    UserGetModel user = UserGetModel.fromJson(jsonDecode(response.body));
    return user;
  }

  static Future<bool> deleteMe() async{
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    String deleteUserUrl = '$baseUrl/user/delete-user/$userId';

    http.Response? response = await Requests.get(url: deleteUserUrl, isAccessKeyNecessary: true);

    if(response == null || response.statusCode != 200){
      return false;
    }

    return true;
  }

  static Future<bool> sendOTPCodeForRenewPassword(String email) async{
    String sendForgotOTPUrl = '$baseUrl/user/send-forgot-otp/$email';

    http.Response? response = await Requests.get(url: sendForgotOTPUrl, isAccessKeyNecessary: false);

    if(response == null){
      return false;
    }

    return response.statusCode == 200;
  }

  static Future<bool> checkOTP(String email, String otpCode) async{
    String checkOTPUrl = '$baseUrl/user/check-otp/$email/$otpCode';

    http.Response? response = await Requests.get(url: checkOTPUrl, isAccessKeyNecessary: false);

    if(response == null){
      return false;
    }

    return response.statusCode == 200;
  }

  static Future<bool> renewPassword(String email, String otpCode, String newPassword) async{
    String renewPasswordUrl = '$baseUrl/user/renew-password/$email/$otpCode';

    RenewPasswordModel renewPasswordModel = RenewPasswordModel(newPassword);
    http.Response? response = await Requests.post(url: renewPasswordUrl, body: renewPasswordModel, isAccessKeyNecessary: false);

    if(response == null){
      return false;
    }

    return response.statusCode == 200;
  }

}