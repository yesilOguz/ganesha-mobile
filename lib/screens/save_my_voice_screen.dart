import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ganesha/backend/Coach.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/screens/home_screen.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:ganesha/icons/ganesha_icons_icons.dart';
import 'package:ganesha/uikit/fonts.dart';
import 'package:ganesha/uikit/ui_colors.dart';
import 'package:ganesha/utils/permission.dart';
import 'package:ganesha/utils/utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SaveMyVoiceScreen extends StatefulWidget{
  const SaveMyVoiceScreen({super.key});

  @override
  State<StatefulWidget> createState() => SaveMyVoiceScreenState();

}

class SaveMyVoiceScreenState extends State<SaveMyVoiceScreen>{
  bool disableContinueButton = false;

  String? recordedPath = "";
  final recorder = GlobalVariable.recorder;
  
  bool recorded = false;
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiColor.backgroundColor,
      body: buildBody(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    recorder.closeRecorder();
  }

  @override
  void initState() {
    super.initState();
    recorder.openRecorder();
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(child: Text('Ganesha', style: TextStyle(color: UiColor.textColor, fontSize: 40, fontFamily: Fonts.sedan.name))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Column(
              children: [
                IconButton(onPressed: () async{
                  isRecording = !isRecording;
                  recorded = false;

                  if(!isRecording){
                    recordedPath = await recorder.stopRecorder();
                    recorded = true;
                    setState(() {});
                    return;
                  }

                  bool recordPermission = await requestPermission(Permission.microphone);
                  if(recordPermission){
                    Directory docsPath = await getApplicationDocumentsDirectory();
                    recorder.openRecorder();
                    await recorder.startRecorder(codec: Codec.aacMP4, toFile: '${docsPath.path}/my-voice.m4a');
                  }else {
                    if (kDebugMode) {
                      print('Audio permission is required.');
                    }
                  }
                  setState(() {});
                }, icon:
                Icon(GaneshaIcons.voice, size: 95, color: isRecording ? Colors.blue : Colors.blueGrey,)),
                const SizedBox(height: 8,),
                const Text('Say something so Ganesha can recognize you.', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, color: Colors.blueGrey),),
                const SizedBox(height: 35,),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 1.3)),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SizedBox(width: double.infinity, child: Center(child: Text("Try saying: 'Hello Ganesha, I'm so happy to know you and to have you to coach me.'"))),
                  ),
                ),
                SizedBox(height: recorded ? 35 : 0,),
                !recorded ? const SizedBox() : SizedBox(width: double.infinity, child: ElevatedButton(onPressed: ()=> disableContinueButton ? null : continueToHome(), style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(UiColor.buttonAuthBackgroundColor)),
                  child: buildButtonRow(),)),
    ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            child: Text('When you ready click to icon and when it turns blue you can speak. Click the icon again to stop recording!', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),),
          ),
        ],
      ),
    );
  }

  continueToHome() {
    disableContinueButton = true;

    continueToHomeAsync();
    setState(() {});
  }

  continueToHomeAsync() async{
      bool response = await Coach.recognizeMe(recordedPath!);

      if(response){
        GlobalVariable.navState.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen(),));
      } else {
        showMessage('Ganesha seems a bit busy. Sorry about that please try again later :(');
        disableContinueButton = false;
        setState(() {});
      }
  }

  buildButtonRow() {
    var children = <Widget>[];

    if(disableContinueButton){
      children.add(const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)));
    }
    children.add(const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 18),));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }

}
