import 'package:flutter/material.dart';
import 'package:ganesha/backend/User.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/screens/welcome_screen.dart';
import 'package:ganesha/uikit/ui_colors.dart';
import 'package:ganesha/utils/utilities.dart';
import 'package:ganesha/utils/widget_utils.dart';

class RenewPasswordScreen extends StatefulWidget{
  String email;
  String otpCode;

  RenewPasswordScreen({super.key, required this.email, required this.otpCode});

  @override
  State<StatefulWidget> createState() => RenewPasswordScreenState(email, otpCode);

}

class RenewPasswordScreenState extends State<RenewPasswordScreen>{
  String email;
  String otpCode;

  RenewPasswordScreenState(this.email, this.otpCode);

  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordAgainController = TextEditingController();

  bool showPass = false;
  bool showPassAgain = false;

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTextFormField('Password', passwordController, obscureText: !showPass, suffixIcon: IconButton(onPressed: () {
              showPass = !showPass;
              setState(() {});
            }, icon: Icon(showPass ? Icons.visibility : Icons.visibility_off))),
            const SizedBox(height: 15,),
            buildTextFormField('Password Again', passwordAgainController, obscureText: !showPassAgain, suffixIcon: IconButton(onPressed: () {
              showPassAgain = !showPassAgain;
              setState(() {});
            }, icon: Icon(showPassAgain ? Icons.visibility : Icons.visibility_off))),
            const SizedBox(height: 25,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ()=>renewPassword(),
                style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(Colors.blueAccent), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                child: const Text('Renew Password', style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  renewPassword() async{
    String password = passwordController.text;
    String passwordAgain = passwordAgainController.text;

    if(password.isEmpty || password.length < 8) {
      showMessage('password must be at least 8 long');
      return;
    }

    if(password != passwordAgain) {
      showMessage('Passwords do not match');
      return;
    }

    bool checkRenewStatus = await User.renewPassword(email, otpCode, password);

    if(checkRenewStatus){
      showMessage('Your password has been changed. Please login');
      GlobalVariable.navState.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomeScreen(),), ModalRoute.withName('/'),);
    } else {
      showMessage('Ganesha said you can not change your password. Please try again later :(');
      GlobalVariable.navState.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const WelcomeScreen(),), ModalRoute.withName('/'),);
    }
  }


}
