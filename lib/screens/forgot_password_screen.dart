import 'package:flutter/material.dart';
import 'package:ganesha/backend/User.dart';
import 'package:ganesha/global_variable.dart';
import 'package:ganesha/screens/renew_password_screen.dart';
import 'package:ganesha/uikit/ui_colors.dart';
import 'package:ganesha/utils/utilities.dart';
import 'package:ganesha/utils/widget_utils.dart';

class ForgotPasswordScreen extends StatefulWidget{
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordScreenState();

}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen>{
  bool isCodeSent = false;

  TextEditingController mailController = TextEditingController();
  TextEditingController otpController = TextEditingController();

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
            buildTextFormField('Email', mailController, suffixIcon: TextButton(onPressed: ()=>sendCode(), child: const Text('Send Code', style: TextStyle(color: Colors.purple, fontSize: 15),))),
            const SizedBox(height: 15,),
            buildTextFormField('Code', otpController, maxLength: 6, obscureText: false, prefixIcon: const Icon(Icons.password_outlined)),
            const SizedBox(height: 25,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ()=>checkOTP(),
                style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(Colors.blueAccent), shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                child: const Text('Reset Password', style: TextStyle(color: Colors.white),),
              ),
            ),

          ],
        ),
      ),
    );
  }

  sendCode() async{
    if(isCodeSent){
      showMessage('check your spams. If there is no mail wait for a minute then click send code button again');
      return;
    }

    Future.delayed(const Duration(minutes: 1), () => isCodeSent=false,);

    String email = mailController.text;
    bool sendOtp = await User.sendOTPCodeForRenewPassword(email);

    if(sendOtp) {
      isCodeSent = true;
      showMessage('code just sent!');
    } else {
      showMessage('There is an error with your connection or our server please try again later');
    }
  }

  checkOTP() async{
    String email = mailController.text;
    String otpCode = otpController.text;

    if(email.isEmpty || otpCode.isEmpty || otpCode.length != 6){
      showMessage('email or otp code can not be empty and otp code must be 6 of length');
      return;
    }

    bool isOTPValid = await User.checkOTP(email, otpCode);

    if(isOTPValid) {
      GlobalVariable.navState.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => RenewPasswordScreen(email: email, otpCode: otpCode,),));
    } else {
      showMessage('Your code is not valid');
    }
  }

}
