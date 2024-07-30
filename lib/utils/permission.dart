import 'package:permission_handler/permission_handler.dart';


Future<bool> requestPermission(Permission permission) async {
  var status = await permission.request();
  print(status);
  if (status != PermissionStatus.granted) {
    return false;
  }
  return true;
}
