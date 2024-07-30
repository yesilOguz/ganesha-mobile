import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ganesha/backend/Character.dart';
import 'package:ganesha/backend/models/character_models.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/uikit/fonts.dart';
import 'package:ganesha/uikit/ui_colors.dart';
import 'package:ganesha/utils/widget_utils.dart';

class AdminAddNewModelScreen extends StatefulWidget{
  const AdminAddNewModelScreen({super.key});

  @override
  State<AdminAddNewModelScreen> createState() => AdminAddNewModelScreenState();
}

class AdminAddNewModelScreenState extends State<AdminAddNewModelScreen> {
  String? selectedFilePath = '';

  TextEditingController modelFileController = TextEditingController();
  TextEditingController modelNameController = TextEditingController();
  TextEditingController cameraOrbitThetaController = TextEditingController();
  TextEditingController cameraOrbitPhiController = TextEditingController();
  TextEditingController cameraOrbitRadiusController = TextEditingController();
  TextEditingController cameraTargetXController = TextEditingController();
  TextEditingController cameraTargetYController = TextEditingController();
  TextEditingController cameraTargetZController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiColor.backgroundColor,
      body: buildBody(),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: ()=>GlobalVariable.navState.currentState!.pop(), icon: const Icon(Icons.arrow_back_ios_outlined)),
              Text('Ganesha - ADMIN', style: TextStyle(color: UiColor.textColor, fontSize: 30, fontFamily: Fonts.sedan.name)),
              const SizedBox()
            ],
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  child: Column(
                    children: [
                      buildTextFormField('Model File', modelFileController, readOnly: true, onTap: ()=>selectFile()),
                      const SizedBox(height: 8,),
                      buildTextFormField('Model Name', modelNameController),
                      const SizedBox(height: 10,),
                      const Align(alignment: Alignment.centerLeft, child: Text('Camera Orbit:', style: TextStyle(color: UiColor.textColor, fontWeight: FontWeight.w800, fontSize: 18),)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            buildTextFormField('theta', cameraOrbitThetaController),
                            const SizedBox(height: 5,),
                            buildTextFormField('phi', cameraOrbitPhiController),
                            const SizedBox(height: 5,),
                            buildTextFormField('radius', cameraOrbitRadiusController),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10,),
                      const Align(alignment: Alignment.centerLeft, child: Text('Camera Target:', style: TextStyle(color: UiColor.textColor, fontWeight: FontWeight.w800, fontSize: 18),)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            buildTextFormField('x', cameraTargetXController),
                            const SizedBox(height: 5,),
                            buildTextFormField('y', cameraTargetYController),
                            const SizedBox(height: 5,),
                            buildTextFormField('z', cameraTargetZController),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(UiColor.buttonBackgroundColor), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
              onPressed: ()=>uploadFile(),
              child: const Text('Upload Data', style: TextStyle(color: UiColor.textColor),),
            ),
          )
        ],
      ),
    );
  }

  selectFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false,
                                                                  allowedExtensions: ['glb'],
                                                                  type: FileType.custom);

    if(result == null){
      return;
    }

    selectedFilePath = result.files.first.path;
    modelFileController.text = result.files.first.name;

    setState(() {});
  }

  uploadFile() async {
    CharacterCameraSettings character = CharacterCameraSettings(modelNameController.text,
        CameraOrbitSettings(
          double.parse(cameraOrbitThetaController.text),
          double.parse(cameraOrbitPhiController.text),
          double.parse(cameraOrbitRadiusController.text),
          ), CameraTargetSettings(
          double.parse(cameraTargetXController.text),
          double.parse(cameraTargetYController.text),
          double.parse(cameraTargetZController.text),
        ));

    await Character.saveModel(character, selectedFilePath!);

    modelFileController.text = '';
    modelNameController.text = '';
    cameraOrbitThetaController.text = '';
    cameraOrbitPhiController.text = '';
    cameraOrbitRadiusController.text = '';
    cameraTargetXController.text = '';
    cameraTargetYController.text = '';
    cameraTargetZController.text = '';

    selectedFilePath = '';

    setState(() {});
  }
}