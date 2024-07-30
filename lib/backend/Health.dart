import 'dart:convert';

import 'package:ganesha/backend/api_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Health{
  static Future<bool> checkServerHealth() async{
    String serverHealthUrl = '$baseUrl/health/';

    http.Response? response = await Requests.get(url: serverHealthUrl, isAccessKeyNecessary: false).timeout(const Duration(minutes: 1),);

    return (response != null && response.statusCode == 200);
  }

  static Future<bool> checkKeyHealth() async{
    String keyHealthUrl = '$baseUrl/health/check-key';

    http.Response? response = await Requests.get(url: keyHealthUrl, isAccessKeyNecessary: true);

    return (response != null && response.statusCode == 200);
  }

  static Future<bool> refreshKey() async{
    String refreshUrl = '$baseUrl/user/refresh-token';

    http.Response? response = await Requests.get(url: refreshUrl, isRefreshKeyNecessary: true, isAccessKeyNecessary: false);

    if(response == null || response.statusCode != 200){
      return false;
    }

    final responseJson = jsonDecode(response.body);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessKey', responseJson['access_token']);
    await prefs.setString('refreshKey', responseJson['refresh_token']);

    return true;
  }

}