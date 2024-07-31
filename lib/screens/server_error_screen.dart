import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ganesha/uikit/fonts.dart';
import 'package:ganesha/uikit/ui_colors.dart';

class ServerErrorScreen extends StatelessWidget{
  const ServerErrorScreen({super.key});

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
              child: Text("Ganesha", style: TextStyle(color: UiColor.textColor, fontSize: 60, fontFamily: Fonts.sedan.name),),
            ),
            SizedBox(
              child: Text('We are working on something good in your coach ganesha please try again later', textAlign: TextAlign.center, style: TextStyle(color: UiColor.textColor, fontSize: 25, fontFamily: Fonts.sedan.name),),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                  backgroundColor: const WidgetStatePropertyAll(Colors.blueAccent)
                ),
                onPressed: ()=>exit(0),
                child: const Text('Leave Ganesha alone', style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }

}