import 'package:flutter/material.dart';
import 'package:ganesha/backend/Auth.dart';
import 'package:ganesha/backend/models/auth_models.dart';
import 'package:ganesha/backend/models/user_models.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/screens/admin_home_screen.dart';
import 'package:ganesha/screens/forgot_password_screen.dart';
import 'package:ganesha/screens/home_screen.dart';
import 'package:ganesha/screens/save_my_voice_screen.dart';
import 'package:ganesha/screens/sign_up_screen.dart';
import 'package:ganesha/uikit/ui_colors.dart';
import 'package:ganesha/utils/utilities.dart';
import 'package:ganesha/utils/widget_utils.dart';


class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => LoginScreenState();

}


class LoginScreenState extends State<LoginScreen>{
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
            buildTextFormField("Enter your email address", emailController, prefixIcon: const Icon(Icons.email_outlined)),
            const SizedBox(height: 20,),
            buildTextFormField("Enter your password", passwordController, prefixIcon: const Icon(Icons.lock_outline), obscureText: true),
            const SizedBox(height: 30,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(UiColor.buttonAuthBackgroundColor), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                onPressed: () => login(),
                child: const Text("Log in your account", style: TextStyle(color: Colors.white, fontSize: 18),),
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?", style: TextStyle(color: UiColor.textColor, fontSize: 16),),
                TextButton(onPressed: ()=>GlobalVariable.navState.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => const SignUpScreen(),)), child: const Text("Sign up", style: TextStyle(color: UiColor.linkTextColor, fontSize: 16),)),
              ],
            ),
            TextButton(onPressed: ()=>GlobalVariable.navState.currentState!.push(MaterialPageRoute(builder: (context) => const ForgotPasswordScreen(),)), child: const Text("Forgot Password", style: TextStyle(color: UiColor.linkTextColor, fontSize: 13),)),
          ],
        ),
      ),
    );
  }


  login() async{
    AuthResponse? response = await Auth.login(email: emailController.text, password: passwordController.text);

    if(response != null){
      GlobalVariable.navState.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => response.user.role != UserRole.END_USER.name ? const AdminHomeScreen() : response.user.recognizedUser ? const HomeScreen() : const SaveMyVoiceScreen(),));
    } else {
      showMessage('email or password is wrong!');
    }
  }
}
