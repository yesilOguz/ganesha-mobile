class CharacterGetModelList{
  List<String> characters = List<String>.empty();

  CharacterGetModelList(this.characters);
  CharacterGetModelList.fromJson(Map<String, dynamic> json)
    : characters = List<String>.from(json['characters']);

  Map<String, dynamic> toJson() => {
    'characters': characters
  };
}

class CameraOrbitSettings{
  double theta;
  double phi;
  double radius;

  CameraOrbitSettings(this.theta, this.phi, this.radius);
  CameraOrbitSettings.fromJson(Map<String, dynamic> json)
    : theta = double.parse(json['theta'].toString()),
      phi = double.parse(json['phi'].toString()),
      radius = double.parse(json['radius'].toString());

  Map<String, dynamic> toJson() => {
    'theta': theta,
    'phi': phi,
    'radius': radius
  };
}

class CameraTargetSettings{
  double x;
  double y;
  double z;

  CameraTargetSettings(this.x, this.y, this.z);
  CameraTargetSettings.fromJson(Map<String, dynamic> json)
    : x = double.parse(json['x'].toString()),
      y = double.parse(json['y'].toString()),
      z = double.parse(json['z'].toString());

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z
  };

}

class CharacterCameraSettings{
  String objectName;
  CameraOrbitSettings cameraOrbitSettings;
  CameraTargetSettings cameraTargetSettings;

  CharacterCameraSettings(
      this.objectName, this.cameraOrbitSettings, this.cameraTargetSettings);
  CharacterCameraSettings.fromJson(Map<String, dynamic> json)
    : objectName = json['object_name'] as String,
      cameraOrbitSettings = CameraOrbitSettings.fromJson(json['camera_orbit']),
      cameraTargetSettings = CameraTargetSettings.fromJson(json['camera_target']);


  Map<String, dynamic> toJson() => {
    'object_name': objectName,
    'camera_orbit': cameraOrbitSettings.toJson(),
    'camera_target': cameraTargetSettings.toJson()
  };

}
