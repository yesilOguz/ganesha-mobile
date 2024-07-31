import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ganesha/backend/Character.dart';
import 'package:ganesha/backend/Coach.dart';
import 'package:ganesha/backend/User.dart';
import 'package:ganesha/backend/models/character_models.dart';
import 'package:ganesha/backend/models/user_models.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/icons/ganesha_icons_icons.dart';
import 'package:ganesha/screens/welcome_screen.dart';
import 'package:ganesha/service/background_listener.dart';
import 'package:ganesha/uikit/ui_colors.dart';
import 'package:ganesha/utils/utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => ProfileScreenState();

}

class ProfileScreenState extends State<ProfileScreen>{
  List<String> characters = List<String>.empty();
  String selectedModel = '';

  bool isMicrophoneOn = false;

  bool disableLogoutButton = false;
  bool disableDeleteButton = false;

  String username = "";
  String email = "";

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
    getUserData();
    getMicrophoneStatus();
    getCharaterList();
  }

  getCharaterList() async{
    CharacterGetModelList? characterList = await Character.getModelList();

    if(characterList == null){
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(const SnackBar(content: Text('check your internet connection!'), duration: Duration(seconds: 5),));
      Future.delayed(const Duration(seconds: 6), () => exit(0),);
    }

    characterList!.characters.remove('environment');
    characters = characterList.characters;

    final prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey('selected_model')){
      prefs.setString('selected_model', characters.first);
    }
    selectedModel = prefs.getString('selected_model')!;

    setState(() {});
  }

  void getMicrophoneStatus() async{
    final prefs = await SharedPreferences.getInstance();
    isMicrophoneOn = prefs.getBool('microphone')!;
  }

  getUserData() async{
    UserGetModel? user = await User.getMe();
    username = user!.fullName;
    email = user.email;
    setState(() {});
  }

  buildBody() {
    if(username.isEmpty || email.isEmpty){
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: ()=>GlobalVariable.navState.currentState!.pop(), icon: const Icon(Icons.arrow_back_ios_new))),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: ()=>GlobalVariable.navState.currentState!.pop(), icon: const Icon(Icons.arrow_back_ios_new))),
                const Icon(GaneshaIcons.profile, size: 55, color: Colors.blueGrey,),
                const SizedBox(height: 13,),
                const Text('User Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.blueGrey),),
              ],
            ),
          ),
          SizedBox(child: Column(
            children: [
              buildTextContainer(text: utf8.decode(username.codeUnits), icon: Icons.person),
              const SizedBox(height: 20,),
              buildTextContainer(text: utf8.decode(email.codeUnits), icon: Icons.email),
            ],
          ),),
          SizedBox(child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Align(alignment: Alignment.centerLeft, child: Text('Settings:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: UiColor.textColor),)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('Always Listen', style: TextStyle(color: UiColor.textColor, fontSize: 14, fontWeight: FontWeight.w500),),
                  Switch(value: isMicrophoneOn, onChanged: (value) async{
                    if (Platform.isAndroid || Platform.isIOS) {
                      isMicrophoneOn = value;

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('microphone', value);

                      if (value) {
                        startListener();
                      } else {
                        stopRecording();
                      }
                    } else {
                      showMessage('Your system does not supporting this feature!');
                    }

                    setState(() {});
                  },)
                ],
              ),
              const SizedBox(height: 20,),
              const Text('Select your coach', style: TextStyle(color: UiColor.textColor, fontSize: 14, fontWeight: FontWeight.w500),),
              const SizedBox(height: 5,),
              DropdownMenu(
                  initialSelection: selectedModel,
                  onSelected: (value) async{
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('selected_model', value!);
                  },
                  dropdownMenuEntries: characters.map((e) {
                    return DropdownMenuEntry(value: e, label: e);
                  },).toList())
            ],
          ),),
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(Colors.blueAccent), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                    onPressed: () => disableLogoutButton ? null : logout(),
                    child: const Text("Log out your account", style: TextStyle(color: Colors.white, fontSize: 18),),
                  ),
                ),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(Colors.redAccent), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                      onPressed: () => disableDeleteButton ? null : deleteAccount(),
                      child: const Text("Delete account", style: TextStyle(color: Colors.white, fontSize: 18),),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  buildTextContainer({required String text, required IconData? icon}){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: PhysicalModel(
        elevation: 15,
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white60,
            borderRadius: BorderRadius.circular(15)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon),
              Text(text),
              const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  logout() async{
    disableDeleteButton = true;
    disableLogoutButton = true;

    logoutAsync();
    setState(() {});
  }

  logoutAsync() async{
    await stopRecording();

    Directory docsPath = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = docsPath.listSync();

    for (FileSystemEntity file in files) {
      if (file.path.endsWith('.m4a')) {
        file.delete();
      }
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

    GlobalVariable.navState.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomeScreen(),), ModalRoute.withName('/'),);
  }

  deleteAccount() {
    disableDeleteButton = true;
    disableLogoutButton = true;

    deleteAccountAsync();
    setState(() {});
  }

  deleteAccountAsync() async{
    bool response = await User.deleteMe();

    if(response){
      logoutAsync();
    } else {
      showMessage('Ganesha stopped us while we trying to delete your account. Please try again later.');
    }
  }

}
