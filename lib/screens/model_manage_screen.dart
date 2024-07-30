import 'package:flutter/material.dart';
import 'package:ganesha/backend/Character.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/screens/admin_add_new_model_screen.dart';
import 'package:ganesha/uikit/fonts.dart';
import 'package:ganesha/uikit/ui_colors.dart';

class ModelManageScreen extends StatefulWidget{
  const ModelManageScreen({super.key});

  @override
  State<ModelManageScreen> createState() => ModelManageScreenState();
}

class ModelManageScreenState extends State<ModelManageScreen>{
  List<String> characterList = List<String>.empty(growable: true);
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    getModelList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiColor.backgroundColor,
      body: buildBody(),
    );
  }

  getModelList() async{
    final characterModel = await Character.getModelList();

    isLoaded = true;

    if(characterModel != null){
      characterList = characterModel.characters;
    }
    setState(() {});
  }

  deleteModel(String modelName) async{
    bool isDeleted = await Character.deleteModel(modelName);

    if(isDeleted){
      getModelList();
    }
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
          const SizedBox(height: 20,),
          Expanded(
            child: !isLoaded ? const Center(child: CircularProgressIndicator(),) : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30),
              child: ListView.builder(
                itemCount: characterList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: const Text('Model Name'),
                    subtitle: Text(characterList[index]),
                    trailing: IconButton(onPressed: ()=>deleteModel(characterList[index]), icon: const Icon(Icons.delete_forever),),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(UiColor.buttonBackgroundColor), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
              onPressed: ()=>waitForAddScreen(),
              child: const Text('Add New Model', style: TextStyle(color: UiColor.textColor),),
            ),
          )
        ],
      ),
    );
  }

  waitForAddScreen() async{
    await GlobalVariable.navState.currentState!.push(MaterialPageRoute(builder: (context) => const AdminAddNewModelScreen(),));
    getModelList();
  }

}