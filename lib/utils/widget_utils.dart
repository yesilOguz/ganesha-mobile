import 'package:flutter/material.dart';
import 'package:ganesha/uikit/ui_colors.dart';

buildTextFormField(String text, TextEditingController controller, {maxLength, prefixIcon, suffixIcon, obscureText=false, bool readOnly=false, void Function()? onTap}){
  return PhysicalModel(
    elevation: 20,
    shadowColor: Colors.black87,
    color: Colors.transparent,
    child: TextFormField(
      maxLength: maxLength,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
        counterText: '',
        hintText: text,
        filled: true,
        fillColor: UiColor.formFieldColor,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: const BorderSide(color: Colors.transparent)),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon
      ),
      obscureText: obscureText,
      controller: controller,
    ),
  );
}
