import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
/*

Actually this service do nothing
Service helping me to recording voice in background
If I use recorder in this service, plugin don't run normally
When the application is minimized and this service is not running, the recorder shuts down after a while.

 */

Future<void> initializeService() async{
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground
    ),
    androidConfiguration: AndroidConfiguration(
        onStart: onStart, isForegroundMode: true, autoStart: false, autoStartOnBoot: false,
        initialNotificationContent: 'Ganesha listening to you :)'
    ),
  );
}


void startBackgroundService() async {
  final service = FlutterBackgroundService();

  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

// Ensure initialization in your onStart and onIosBackground methods
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on("stop").listen((event) async {
    service.stopSelf();
  });

  Timer.periodic(const Duration(hours: 1), (timer) async{

  },);
}
