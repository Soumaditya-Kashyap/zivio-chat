import 'package:chat_app/core/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chat_app/core/constants/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    required this.text,
    this.loading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  final void Function()? onPressed;
  final String text;
  final bool loading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 40.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? primary,
          foregroundColor: textColor ?? white,
          side: borderColor != null ? BorderSide(color: borderColor!) : null,
        ),
        onPressed: onPressed,
        child:
            loading //if loading is true, then show circular progress indicator, else show text
                ? Center(
                    child: CircularProgressIndicator(
                      color: textColor ?? white,
                    ),
                  )
                : Text(
                    text,
                    style: body.copyWith(color: textColor ?? white),
                  ),
      ),
    );
  }
}
