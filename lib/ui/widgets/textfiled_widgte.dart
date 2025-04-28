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
    this.isPassword=false,
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
      height: isChatText ? 35.h : null,
      child: TextField(
        controller: controller,
        focusNode: FocusNode(), // when
        obscureText: isPassword,
        onChanged:
            onChanged, //When the user types something, onChanged will be called, it will help to update the value of the textfield

        decoration: InputDecoration(
          contentPadding:
              isChatText ? EdgeInsets.symmetric(horizontal: 12.w) : null,
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
                  ? InkWell(onTap: onTap, child: Icon(Icons.send))
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
