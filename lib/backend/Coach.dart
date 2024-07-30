import 'dart:convert';
import 'dart:io';

import 'package:ganesha/backend/api_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/coach_models.dart';

class Coach{
  static Future<bool> recognizeMe(String voiceRecordPath) async{
    String recognizeUrl = '$baseUrl/coach/recognize-me';

    http.StreamedResponse? response = await Requests.multipart(url: recognizeUrl, filePath: voiceRecordPath, fileFieldName: 'audio_file', isAccessKeyNecessary: true);

    if(response == null){
      return false;
    }

    return response.statusCode == 200;
  }

  static Future<bool> proccessAudio(String recordPath) async {
    String processUrl = '$baseUrl/coach/process-audio';

    http.StreamedResponse? response = await Requests.multipart(url: processUrl, filePath: recordPath, fileFieldName: 'audio_file', isAccessKeyNecessary: true);

    if(response == null){
      return false;
    }

    return response.statusCode == 200;
  }

  static Future<String?> getDailyAdvice() async{
    final prefs = await SharedPreferences.getInstance();
    String? selectedModel = prefs.getString('selected_model'); 
    
    String dailyAdviceUrl = '$baseUrl/coach/get-daily/$selectedModel';
    http.Response? response = await Requests.get(url: dailyAdviceUrl, isAccessKeyNecessary: true);

    if(response == null || response.statusCode != 200){
      return null;
    }

    var bytes = response.bodyBytes;

    Directory docs = await getApplicationDocumentsDirectory();
    String filePath = '${docs.path}/daily-voice.m4a';
    File file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  static Future<String?> sendTextMessage(String textMessage) async{
    final prefs = await SharedPreferences.getInstance();
    String? selectedModel = prefs.getString('selected_model');

    String textMessageUrl = '$baseUrl/coach/chat/$selectedModel/$textMessage';
    http.Response? response = await Requests.get(url: textMessageUrl, isAccessKeyNecessary: true);

    if(response == null || response.statusCode != 200){
      return null;
    }

    var bytes = response.bodyBytes;

    Directory docs = await getApplicationDocumentsDirectory();
    String filePath = '${docs.path}/answer.m4a';
    File file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  static Future<String?> sendVoiceMessage(String filePath) async{
    final prefs = await SharedPreferences.getInstance();
    String? selectedModel = prefs.getString('selected_model');

    String voiceMessageUrl = '$baseUrl/coach/chat-with-voice/$selectedModel';
    http.StreamedResponse? streamedResponse = await Requests.multipart(url: voiceMessageUrl, filePath: filePath, fileFieldName: 'audio_file', isAccessKeyNecessary: true);

    if(streamedResponse == null || streamedResponse.statusCode != 200){
      return null;
    }

    var response = await http.Response.fromStream(streamedResponse);

    var bytes = response.bodyBytes;

    Directory docs = await getApplicationDocumentsDirectory();
    String answerFilePath = '${docs.path}/answer.m4a';
    File file = File(answerFilePath);
    await file.writeAsBytes(bytes);

    return answerFilePath;
  }

}