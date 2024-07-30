import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/screens/welcome_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Health.dart';

const baseUrl = 'http://10.0.2.2:8000'; /* local */
const modelBaseUrl = '$baseUrl/character/get-model';


class Requests{
  static http.Response timeOut() {
    return http.Response('TimeOut', 408);
  }

  static http.StreamedResponse streamedTimeOut() {
    return http.StreamedResponse(const Stream.empty(), 408);
  }

  static Future<String?> getAccessKey() async{
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessKey');
    return accessToken;
  }

  static Future<String?> getRefreshKey() async{
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshKey');
    return refreshToken;
  }

  static Future<Map<String, String>> getHeaders(bool isAccessKeyNecessary, bool isRefreshKeyNecessary) async{
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if(isAccessKeyNecessary){
      String? accessKey = await getAccessKey();
      headers["Authorization"] = "bearer $accessKey";
    } else if(isRefreshKeyNecessary){
      String? refreshKey = await getRefreshKey();
      headers["Authorization"] = "bearer $refreshKey";
    }

    return headers;
  }

  static Future<Map<String, String>> getHeadersForFile(bool isAccessKeyNecessary, bool isRefreshKeyNecessary) async{
    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data;',
    };

    if(isAccessKeyNecessary){
      String? accessKey = await getAccessKey();
      headers["Authorization"] = "bearer $accessKey";
    } else if(isRefreshKeyNecessary){
      String? refreshKey = await getRefreshKey();
      headers["Authorization"] = "bearer $refreshKey";
    }

    return headers;
  }

  static Future<http.Response?> get({required String url, bool isAccessKeyNecessary=true, bool isRefreshKeyNecessary=false}) async{
    try{
      Map<String, String> headers = await getHeaders(isAccessKeyNecessary, isRefreshKeyNecessary);
      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(minutes: 1), onTimeout: ()=> Requests.timeOut(),);

      if(response.statusCode == 401 && !isRefreshKeyNecessary){
        bool refreshed = await Health.refreshKey();

        if(refreshed){
          return Requests.get(url: url, isAccessKeyNecessary: isAccessKeyNecessary, isRefreshKeyNecessary: isRefreshKeyNecessary);
        } else {
          GlobalVariable.navState.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomeScreen(),), ModalRoute.withName('/'),);
        }
      }

      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<http.Response?> post({required String url, bool isAccessKeyNecessary=true, bool isRefreshKeyNecessary=false, required dynamic body}) async{
    try{
      Map<String, String> headers = await getHeaders(isAccessKeyNecessary, isRefreshKeyNecessary);
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(minutes: 2), onTimeout: ()=> Requests.timeOut(),);

      if(response.statusCode == 401){
        bool refreshed = await Health.refreshKey();

        if(refreshed){
          return Requests.post(url: url, isAccessKeyNecessary: isAccessKeyNecessary, isRefreshKeyNecessary: isRefreshKeyNecessary, body: body);
        } else {
          GlobalVariable.navState.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomeScreen(),), ModalRoute.withName('/'),);
        }
      }

      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<http.StreamedResponse?> multipart({required String url, required String filePath, required String fileFieldName, bool isAccessKeyNecessary=true, bool isRefreshKeyNecessary=false, dynamic body, String? bodyFieldName}) async {
    try {
      Map<String, String> headers = await getHeadersForFile(isAccessKeyNecessary, isRefreshKeyNecessary);
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.files.add(
        await http.MultipartFile.fromPath(
          fileFieldName,
          filePath
        )
      );

      if(bodyFieldName != null){
        request.fields[bodyFieldName] = jsonEncode(body);
      }

      http.StreamedResponse response = await request.send().timeout(const Duration(minutes: 1), onTimeout: ()=> Requests.streamedTimeOut(),);

      if(response.statusCode == 401){
        bool refreshed = await Health.refreshKey();

        if(refreshed){
          return Requests.multipart(url: url, filePath: filePath, fileFieldName: fileFieldName, isAccessKeyNecessary: isAccessKeyNecessary, isRefreshKeyNecessary: isRefreshKeyNecessary, body: body, bodyFieldName: bodyFieldName);
        } else {
          GlobalVariable.navState.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomeScreen(),), ModalRoute.withName('/'),);
        }
      }

      return response;
    } catch (e) {
      return null;
    }
  }
}
