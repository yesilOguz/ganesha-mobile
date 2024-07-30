import 'package:flutter/material.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/screens/login_screen.dart';
import 'package:ganesha/screens/sign_up_screen.dart';
import 'package:ganesha/uikit/fonts.dart';
import 'package:ganesha/uikit/ui_colors.dart';

class WelcomeScreen extends StatelessWidget{
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiColor.backgroundColor,
      body: buildBody(),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 110.0, horizontal: 50.0),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Column(
                children: [
                  Text("Ganesha", style: TextStyle(color: UiColor.textColor, fontSize: 60, fontFamily: Fonts.sedan.name),),
                  const Text("Your personal AI coach", style: TextStyle(color: UiColor.textColor, fontSize: 18),)
                ],
              ),
            ),
            SizedBox(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(UiColor.buttonBackgroundColor), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                      onPressed: () => GlobalVariable.navState.currentState!.push(MaterialPageRoute(builder: (context) => const SignUpScreen(),)),
                      child: const Text("Create Your Ganesha", style: TextStyle(color: UiColor.textColor, fontSize: 15),),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(text: "Already have an account?\n", style: TextStyle(color: UiColor.textColor, fontSize: 15),),
                        WidgetSpan(child: TextButton(
                          onPressed: () => GlobalVariable.navState.currentState!.push(MaterialPageRoute(builder: (context) => const LoginScreen(),)),
                          child: const Text("Login"),
                        ))
                      ]
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}