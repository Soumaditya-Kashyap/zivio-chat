import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: camel_case_types
class CustomTextfield extends StatelessWidget {
  const CustomTextfield({
    super.key,
    this.onChanged,
    this.hintText,
    this.focusNode,
    this.isChatText = false,
    this.isSearch = false,
    this.controller,
    this.onTap,
    this.isPassword = false,
  });
  final void Function(String)?
      onChanged; //This will be called when the user types something in the textfield
  final String? hintText;
  final FocusNode? focusNode;
  final bool isSearch;
  final bool isChatText;
  final TextEditingController? controller;
  final void Function()? onTap;
  final bool isPassword;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isChatText ? 45.h : null,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        textCapitalization: TextCapitalization.sentences,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: isChatText
              ? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)
              : null,
          filled: true,
          fillColor: isChatText ? white : grey.withAlpha(25),
          hintText: hintText,
          hintStyle: TextStyle(
            color: grey,
          ),
          suffixIcon: isSearch
              ? Container(
                  height: 55,
                  width: 55,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Image.asset(searchIcon),
                )
              : isChatText
                  ? IconButton(
                      onPressed: onTap,
                      icon: Icon(Icons.send, color: primary),
                    )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isChatText ? 25.r : 10.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
