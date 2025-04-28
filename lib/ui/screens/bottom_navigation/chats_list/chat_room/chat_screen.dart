import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/extensions/widget_extention.dart';
import 'package:chat_app/core/models/message_model.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:chat_app/ui/others/user_provider.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_room/chat_viewmodel.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_room/chat_widgets.dart';
import 'package:chat_app/ui/widgets/textfiled_widgte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.receiver});

  final UserModels receiver;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    return ChangeNotifierProvider(
      create: (context) =>
          ChatViewmodel(ChatService(), currentUser!, widget.receiver),
      child: Consumer<ChatViewmodel>(builder: (context, model, _) {
        // Scroll to bottom when messages change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 1.sw * 0.05, vertical: 10.h),
                    child: Column(
                      children: [
                        10.verticalSpace,
                        _buildHeader(context,
                            name: widget.receiver.name ?? 'Chat',
                            isSelfChat: model.isSelfChat),
                        17.verticalSpace,
                        Expanded(
                          child: model.messages.isEmpty
                              ? Center(
                                  child: Text(
                                    'No messages yet. Start chatting!',
                                    style: body.copyWith(color: grey),
                                  ),
                                )
                              : ListView.separated(
                                  controller: _scrollController,
                                  padding: EdgeInsets.all(0),
                                  itemCount: model.messages.length,
                                  separatorBuilder: (context, index) =>
                                      10.verticalSpace,
                                  itemBuilder: (context, index) {
                                    final message = model.messages[index];
                                    return ChatBubble(
                                      isCurrentUser: model.isSelfChat
                                          ? true
                                          : message.senderId ==
                                              currentUser!.uid,
                                      message: message,
                                    );
                                  },
                                ),
                        )
                      ],
                    ),
                  ),
                ),
                BottomField(
                  controller: model.controller,
                  onTap: () async {
                    try {
                      await model.saveMessage();
                      _scrollToBottom();
                    } catch (e) {
                      context.showSnackBar(e.toString());
                    }
                  },
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Row _buildHeader(BuildContext context, {String name = '', bool isSelfChat = false}) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: grey.withAlpha(45),
            ),
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        15.horizontalSpace,
        Expanded(
          child: Text(
            name,
            style: heading.copyWith(
              fontSize: 20.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: grey.withAlpha(45),
          ),
          child: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
