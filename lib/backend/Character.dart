import 'dart:convert';

import 'package:ganesha/backend/api_configuration.dart';
import 'package:ganesha/backend/models/character_models.dart';
import 'package:http/http.dart' as http;

class Character{
  static Future<CharacterGetModelList?> getModelList() async{
    String getModelListUrl = '$baseUrl/character/get-model-list';

    http.Response? response = await Requests.get(url: getModelListUrl, isAccessKeyNecessary: true);

    if(response == null || response.statusCode != 200){
      return null;
    }

    final characterList = CharacterGetModelList.fromJson(jsonDecode(response.body));
    return characterList;
  }

  static Future<bool> deleteModel(String modelName) async{
    String deleteModelUrl = '$baseUrl/character/remove-model/$modelName';

    http.Response? response = await Requests.get(url: deleteModelUrl, isAccessKeyNecessary: true);

    if(response == null){
      return false;
    }

    return response.statusCode == 200;
  }

  static Future<CharacterCameraSettings?> saveModel(CharacterCameraSettings character,
                                                    String filePath) async{
    String saveModelUrl = '$baseUrl/character/save-model';

    http.StreamedResponse? streamedResponse = await Requests.multipart(url: saveModelUrl, filePath: filePath, fileFieldName: 'object_file', body: character, bodyFieldName: 'camera_settings');

    if(streamedResponse == null){
      return null;
    }

    var response = await http.Response.fromStream(streamedResponse);

    CharacterCameraSettings jsonResponse = CharacterCameraSettings.fromJson(jsonDecode(response.body));
    return jsonResponse;
  }

  static Future<CharacterCameraSettings?> getCameraSettings(String characterName) async{
    String getSettingsUrl = '$baseUrl/character/get-model-camera-settings/$characterName';

    http.Response? response = await Requests.get(url: getSettingsUrl, isAccessKeyNecessary: true);

    if(response == null || response.statusCode != 200){
      return null;
    }

    CharacterCameraSettings cameraSettings = CharacterCameraSettings.fromJson(jsonDecode(response.body));
    return cameraSettings;
  }

}