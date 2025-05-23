import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/models/message_model.dart';
import 'package:chat_app/ui/widgets/textfiled_widgte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class BottomField extends StatelessWidget {
  const BottomField({
    super.key,
    this.onTap,
    this.onChanged,
    this.controller,
  });

  final void Function()? onTap;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: grey.withAlpha(60),
      padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 15.h),
      child: Row(
        children: [
          InkWell(
            onTap: null,
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: white,
              child: Icon(Icons.add),
            ),
          ),
          10.horizontalSpace,
          Expanded(
              child: CustomTextfield(
            controller: controller,
            isChatText: true,
            hintText: 'Write Message..',
            onChanged: onChanged,
            onTap: onTap,
          ))
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    this.isCurrentUser = true,
    required this.message,
  });

  final bool isCurrentUser;
  final Message message;

  @override
  Widget build(BuildContext context) {
    final alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = isCurrentUser
        ? BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          );
    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: 1.sw * 0.75, minWidth: 50.w),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser ? primary : grey.withAlpha(40),
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content ?? '',
              style: body.copyWith(color: isCurrentUser ? white : null),
            ),
            5.verticalSpace,
            Text(
              message.timestamp != null
                  ? DateFormat('hh:mm a').format(message.timestamp!)
                  : '',
              style: small.copyWith(color: isCurrentUser ? white : grey),
            )
          ],
        ),
      ),
    );
  }
}
