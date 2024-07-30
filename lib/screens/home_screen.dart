import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:ganesha/backend/Character.dart';
import 'package:ganesha/backend/Coach.dart';
import 'package:ganesha/backend/api_configuration.dart';
import 'package:ganesha/backend/models/character_models.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/icons/ganesha_icons_icons.dart';
import 'package:ganesha/screens/profile_screen.dart';
import 'package:ganesha/service/background_service.dart';
import 'package:ganesha/uikit/fonts.dart';
import 'package:ganesha/uikit/ui_colors.dart';
import 'package:ganesha/utils/permission.dart';
import 'package:ganesha/utils/utilities.dart';
import 'package:ganesha/utils/widget_utils.dart';
import 'package:o3d/o3d.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final recorder = GlobalVariable.recorder;

  bool disableSendMessageButtons = false;
  bool isRecording = false;
  bool isThereDailyAdvice = false;

  TextEditingController messageController = TextEditingController();

  String modelUrl = '';

  final O3DController chrController = O3DController();

  CameraOrbit cameraOrbit = CameraOrbit(0, 75, 105);
  CameraTarget cameraTarget = CameraTarget(0, 0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiColor.backgroundColor,
      body: buildBody(),
    );
  }

  @override
  void initState() {
    super.initState();
    getModelStuff();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    startMicrophoneStuff();
  }

  Future<void> getModelStuff() async{
    final prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey('selected_model')){
      CharacterGetModelList? characterList = await Character.getModelList();

      if(characterList == null){
        ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(const SnackBar(
          content: Text('Check your internet connection!'),
          duration: Duration(seconds: 5),
        ));

        Future.delayed(const Duration(seconds: 6), () => exit(0),);
      }

      String newSelectedModel = characterList!.characters.firstWhere((element) => element != 'environment',);
      prefs.setString('selected_model', newSelectedModel);
    }

    String? selectedModelName = prefs.getString('selected_model');

    modelUrl = '$modelBaseUrl/$selectedModelName';

    CharacterCameraSettings? cameraSettings = await Character.getCameraSettings(selectedModelName!);

    if(cameraSettings != null){
      CameraTargetSettings targetStuff = cameraSettings.cameraTargetSettings;
      CameraOrbitSettings orbitStuff = cameraSettings.cameraOrbitSettings;

      cameraTarget = CameraTarget(targetStuff.x, targetStuff.y, targetStuff.z);
      cameraOrbit = CameraOrbit(orbitStuff.theta, orbitStuff.phi, orbitStuff.radius);
    }

    setState(() {});
  }

  buildBody() {
    checkTodayAdvice();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 15),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 100),
            child: O3D.network(
              backgroundColor: Colors.transparent,
              src: '$modelBaseUrl/environment',
              ar: false,
              autoPlay: false,
              autoRotate: false,
              cameraControls: false,
              // for now I have just 1 environment
              cameraOrbit: CameraOrbit(0, 80, -5),
              cameraTarget: CameraTarget(20, 10, -140),
            ),
          ),
          modelUrl=='' ? const SizedBox() : Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 100),
            child: O3D.network(
              key: ValueKey([modelUrl, cameraOrbit, cameraTarget].toString()),
              backgroundColor: Colors.transparent,
              src: modelUrl,
              controller: chrController,
              ar: false,
              autoPlay: true,
              autoRotate: false,
              cameraControls: false,
              cameraOrbit: cameraOrbit,
              cameraTarget: cameraTarget,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(null, size: 35,),
                  Text('Ganesha', style: TextStyle(color: UiColor.textColor, fontSize: 40, fontFamily: Fonts.sedan.name)),
                  IconButton(onPressed: ()=>openProfileScreen(), icon: const Icon(Icons.person, size: 40,)),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(),
                        isThereDailyAdvice ? GestureDetector(
                          onTap: speakDaily(),
                          child: Card(
                            color: const Color(0xFFB9CEE0),
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusDirectional.circular(9),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 13,),
                                Icon(Icons.calendar_today_outlined, size: 28 ,color: UiColor.textColor,),
                                Text('My Day', style: TextStyle(fontSize: 24, color: UiColor.textColor),),
                                Icon(Icons.arrow_forward_ios_rounded, size: 24, color: UiColor.textColor,)
                              ],
                            ),
                          ),
                        ) : const SizedBox(),
                      ],
                    ),
                  ),
                  isThereDailyAdvice ? const SizedBox(height: 5,) : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(15)),
                        height: 50,
                        child: isRecording ? SizedBox(
                          width: double.infinity,
                          child: IconButton(onPressed: () => sendVoiceMessage(), icon: const Icon(GaneshaIcons.voice, color: Colors.blue, size: 32,),),
                        ) : buildTextFormField('talk to ganesha for guidance', messageController, prefixIcon: IconButton(onPressed: ()=>recordVoice(), icon: const Icon(GaneshaIcons.voice)), suffixIcon: IconButton(onPressed: ()=>sendTextMessage(), icon: const Icon(Icons.send,))),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),]
      ),
    );
  }

  openProfileScreen() async{
    await GlobalVariable.navState.currentState!.push(MaterialPageRoute(builder: (context) => const ProfileScreen(),));
    getModelStuff();
  }

  animateToSpeakPose(){
    chrController.pause();
    chrController.animationName = 'speak-pose';
    chrController.play(repetitions: 1);
  }

  animateToSpeak(){
    chrController.pause();
    chrController.animationName = 'speak1';
    chrController.play();
  }

  animateToIdle(){
    chrController.pause();
    chrController.animationName = 'idle';
    chrController.play();
  }

  speak(String? audioFilePath) async{
    if(audioFilePath == null){
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(
        const SnackBar(content: Text('it seems ganesha so busy to answer please wait a while then try again')),
      );
      return;
    }

    animateToSpeakPose();

    Future.delayed(const Duration(seconds: 2), () async{
      animateToSpeak();

      final soundPlayer = await FlutterSoundPlayer().openPlayer();
      soundPlayer?.startPlayer(fromURI: audioFilePath, codec: Codec.mp3, whenFinished: () {
        animateToIdle();
        disableSendMessageButtons = false;
      },);
    },);
  }

  sendTextMessage() async{
    if(disableSendMessageButtons) {
      showMessage('you can\'t send message now please wait for previous request!');
      return;
    }

    disableSendMessageButtons = true;

    String textMessage = messageController.text;
    messageController.text = '';

    setState(() {});

    String? filePath = await Coach.sendTextMessage(textMessage);
    speak(filePath);
  }

  recordVoice() async{
    if(disableSendMessageButtons){
      showMessage('you can\'t send message now please wait for previous request!');
      return;
    }

    isRecording = true;
    disableSendMessageButtons = true;
    setState(() {});

    bool recordPermission = await requestPermission(Permission.microphone);
    if(recordPermission){
      Directory docsPath = await getApplicationDocumentsDirectory();
      recorder.openRecorder();
      await recorder.startRecorder(codec: Codec.aacMP4, toFile: '${docsPath.path}/voice-message.m4a');
    }else {
      if (kDebugMode) {
        print('Audio permission is required.');
      }
    }
  }

  sendVoiceMessage() async{
    isRecording = false;
    setState(() {});

    String? audioFilePath = await recorder.stopRecorder();
    if(audioFilePath==null){
      showMessage('there is something wrong with your microphone!');
      return;
    }

    String? answerAudioFilePath = await Coach.sendVoiceMessage(audioFilePath);
    speak(answerAudioFilePath);
  }

  void checkTodayAdvice() async{
    var now = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    isThereDailyAdvice = prefs.getInt('lastAdviceDate')! == DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    setState(() {});
  }

  speakDaily() async{
    if(disableSendMessageButtons){
      showMessage('you can\'t listen daily message now please wait for previous request!');
      return;
    }

    Directory docs = await getApplicationDocumentsDirectory();
    String dailyVoicePath = '${docs.path}/daily-voice.m4a';

    disableSendMessageButtons = true;
    setState(() {});

    speak(dailyVoicePath);
  }

  void startMicrophoneStuff() async{
    final service = FlutterBackgroundService();

    if(!(await service.isRunning())) {
      final prefs = await SharedPreferences.getInstance();
      bool recordPermission = await requestPermission(Permission.microphone);
      if(recordPermission && (Platform.isAndroid || Platform.isIOS)){
        if(prefs.getBool('microphone')!){
          startBackgroundService();
        } else {
          stopBackgroundService();
        }
      }
    }
  }
}