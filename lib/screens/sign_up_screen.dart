import 'package:flutter/material.dart';
import 'package:ganesha/backend/Auth.dart';
import 'package:ganesha/backend/models/auth_models.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/screens/home_screen.dart';
import 'package:ganesha/screens/login_screen.dart';
import 'package:ganesha/screens/save_my_voice_screen.dart';
import 'package:ganesha/uikit/ui_colors.dart';
import 'package:ganesha/utils/utilities.dart';
import 'package:ganesha/utils/widget_utils.dart';


class SignUpScreen extends StatefulWidget{
  const SignUpScreen({super.key});

  @override
  State<StatefulWidget> createState() => SignUpScreenState();

}

class SignUpScreenState extends State<SignUpScreen>{
  TextEditingController fullNameController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiColor.backgroundColor,
      body: buildBody(),
    );
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTextFormField("Your full name", fullNameController, prefixIcon: const Icon(Icons.person_outline_rounded)),
            const SizedBox(height: 20,),
            buildTextFormField("Enter your email address", emailController, prefixIcon: const Icon(Icons.email_outlined)),
            const SizedBox(height: 20,),
            buildTextFormField("Enter your password", passwordController, prefixIcon: const Icon(Icons.lock_outline), obscureText: true),
            const SizedBox(height: 30,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(UiColor.buttonAuthBackgroundColor), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                onPressed: () => signUp(),
                child: const Text("Sign up", style: TextStyle(color: Colors.white, fontSize: 18),),
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("have an account?", style: TextStyle(color: UiColor.textColor, fontSize: 16),),
                TextButton(onPressed: ()=>GlobalVariable.navState.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen(),)), child: const Text("Log in", style: TextStyle(color: UiColor.linkTextColor, fontSize: 16),)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  signUp() async{
    AuthResponse? response = await Auth.signUp(fullName: fullNameController.text, email: emailController.text, password: passwordController.text);

    if(response != null){
      GlobalVariable.navState.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => const SaveMyVoiceScreen(),));
    }

  }

}
