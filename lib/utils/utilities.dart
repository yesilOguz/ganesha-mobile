import 'package:flutter/material.dart';
import 'package:ganesha/global_variable.dart';

showMessage(String text){
  ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(
    SnackBar(content: Text(text))
  );
}