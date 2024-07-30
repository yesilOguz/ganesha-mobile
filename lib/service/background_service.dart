import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:ganesha/backend/Coach.dart';
import 'package:ganesha/global_variable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


Timer? timer;

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

  final recorder = GlobalVariable.recorder;
  Directory docsPath = await getApplicationDocumentsDirectory();

  if (!recorder.isRecording) {
    await recorder.openRecorder();
    await recorder.startRecorder(
      codec: Codec.aacMP4,
      toFile: '${docsPath.path}/${DateTime.now().millisecondsSinceEpoch}-record.m4a',

    );

    Duration durationOfRecorder = const Duration(hours: 1);

    recorder.setSubscriptionDuration(durationOfRecorder);
    recorder.onProgress?.listen((event) => listenRecorder(event, recorder, docsPath, durationOfRecorder),);
  }

  service.startService();
}

listenRecorder(RecordingDisposition event, recorder, docsPath, durationOfRecorder) async {
  if(event.duration < const Duration(minutes: 20)){
    return;
  }

  await recorder.stopRecorder();
  ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

  if(connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi){
    List<FileSystemEntity> files = docsPath.listSync();

    for (FileSystemEntity file in files) {
      if (file.path.endsWith('.m4a')) {
        await Coach.proccessAudio(file.path);
        file.delete();
      }
    }
  }

  await recorder.startRecorder(
    codec: Codec.aacMP4,
    toFile: '${docsPath.path}/${DateTime.now().millisecondsSinceEpoch}-record.m4a',
  );

  recorder.setSubscriptionDuration(durationOfRecorder);
  recorder.onProgress?.listen((event) => listenRecorder(event, recorder, docsPath, durationOfRecorder),);
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<void> stopRecording() async {
  final recorder = GlobalVariable.recorder;
  if (recorder.isRecording) {
    await recorder.stopRecorder();
  }
  recorder.closeRecorder();
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
    await stopRecording();
    if(timer != null){
      timer!.cancel();
    }
    service.stopSelf();
  });

  timer = Timer.periodic(const Duration(hours: 1), (timer) async{
    if(timer.tick == 1){
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    var now = DateTime.now();
    var nowDate = DateTime(now.year, now.month, now.day);

    int loginDateEpoch = prefs.getInt('loginDate')!;
    int lastTodayAdviceEpoch = prefs.getInt('lastAdviceDate')!;

    DateTime loginDate = DateTime.fromMillisecondsSinceEpoch(loginDateEpoch);
    DateTime lastTodayAdvice = DateTime.fromMillisecondsSinceEpoch(lastTodayAdviceEpoch);

    if(nowDate == loginDate || nowDate == lastTodayAdvice){
      return;
    }

    // if it is end of the day
    if(DateTime.now().hour >= 23){
      String? advicePath = await Coach.getDailyAdvice();

      if(advicePath == null){
        return;
      }

      prefs.setInt('lastAdviceDate', nowDate.millisecondsSinceEpoch);
    }
  },);
}
