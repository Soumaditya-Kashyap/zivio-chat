import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/others/user_provider.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_list_viewmodel.dart';
import 'package:chat_app/ui/widgets/textfiled_widgte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  late ChatListViewmodel _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentUser = Provider.of<UserProvider>(context).user;
    if (currentUser != null) {
      _viewModel = ChatListViewmodel(DatabaseService(), currentUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ChatListViewmodel>(builder: (context, model, _) {
        return RefreshIndicator(
          onRefresh: () => model.refreshUsers(),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 10.h),
            child: Column(
              children: [
                30.verticalSpace,
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Link-Up Chats', style: heading)),
                20.verticalSpace,
                CustomTextfield(
                  isSearch: true,
                  hintText: 'Search here..',
                  onChanged: model.search,
                ),
                10.verticalSpace,
                Expanded(
                  child: model.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : model.users.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No other users found yet.\nInvite your friends to chat!',
                                    textAlign: TextAlign.center,
                                    style: body.copyWith(color: grey),
                                  ),
                                  10.verticalSpace,
                                  TextButton(
                                    onPressed: () => model.refreshUsers(),
                                    child: Text(
                                      'Refresh',
                                      style: body.copyWith(color: primary),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 0),
                              itemCount: model.filteredUsers.length,
                              separatorBuilder: (context, index) =>
                                  8.verticalSpace,
                              itemBuilder: (context, index) {
                                final user = model.filteredUsers[index];
                                return ChatTile(
                                  user: user,
                                  onTap: () => Navigator.pushNamed(
                                      context, chatRoom,
                                      arguments: user),
                                );
                              },
                            ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, this.onTap, required this.user});

  final void Function()? onTap;
  final UserModels user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: grey.withAlpha(30),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      leading: CircleAvatar(
        backgroundColor: grey.withAlpha(75),
        radius: 25,
        child: user.imageUrl != null && user.imageUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  user.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Text(
                    user.name != null && user.name!.isNotEmpty
                        ? user.name![0]
                        : '?',
                    style: heading,
                  ),
                ),
              )
            : Text(
                user.name != null && user.name!.isNotEmpty
                    ? user.name![0]
                    : '?',
                style: heading,
              ),
      ),
      title: Text(user.name ?? 'User'),
      subtitle: Text(
        user.lastMessage != null ? user.lastMessage!['content'] : '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            user.lastMessage == null ? '' : getFormattedTime(),
            style: TextStyle(color: grey),
          ),
          8.verticalSpace,
          user.unreadCounter == 0 || user.unreadCounter == null
              ? SizedBox(
                  height: 15,
                )
              : CircleAvatar(
                  radius: 9.r,
                  backgroundColor: primary,
                  child: Text(
                    '${user.unreadCounter}',
                    style: small.copyWith(color: white),
                  ),
                )
        ],
      ),
    );
  }

  String getFormattedTime() {
    if (user.lastMessage == null) return '';

    final DateTime now = DateTime.now();
    final DateTime lastMessageTime = DateTime.fromMillisecondsSinceEpoch(
        user.lastMessage!['timestamp'] as int);
    final Duration difference = now.difference(lastMessageTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${lastMessageTime.day}/${lastMessageTime.month}/${lastMessageTime.year}";
    }
  }
}
