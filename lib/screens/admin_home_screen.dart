import 'package:flutter/material.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/screens/home_screen.dart';
import 'package:ganesha/screens/model_manage_screen.dart';
import 'package:ganesha/uikit/fonts.dart';
import 'package:ganesha/uikit/ui_colors.dart';

class AdminHomeScreen extends StatelessWidget{
  const AdminHomeScreen({super.key});

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
      child: Center(
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
            Column(
              children: [
                SizedBox(width: double.infinity, child: ElevatedButton(style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(UiColor.buttonBackgroundColor), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))), onPressed: ()=>GlobalVariable.navState.currentState!.push(MaterialPageRoute(builder: (context) => const ModelManageScreen(),)), child: const Text('Model Management', style: TextStyle(color: UiColor.textColor),))),
                const SizedBox(height: 15,),
                SizedBox(width: double.infinity, child: ElevatedButton(style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(UiColor.buttonBackgroundColor), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))), onPressed: ()=>GlobalVariable.navState.currentState!.push(MaterialPageRoute(builder: (context) => const HomeScreen(),)), child: const Text('Home Screen', style: TextStyle(color: UiColor.textColor),)))
              ],
            ),
            const SizedBox()
          ],
        ),  
      ),
    );
  }

}