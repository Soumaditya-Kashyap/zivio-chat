import 'dart:developer';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:chat_app/ui/others/user_provider.dart';
import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_viewmodel.dart';
import 'package:chat_app/ui/widgets/buttton_widget.dart';
import 'package:chat_app/ui/widgets/textfiled_widgte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(UserModels currentUser) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate new search keywords for the updated name
      final nameSearch =
          UserModels.generateSearchKeywords(_nameController.text.trim());

      // Create updated user model
      final updatedUser = UserModels(
        uid: currentUser.uid,
        name: _nameController.text.trim(),
        email: currentUser.email,
        imageUrl: currentUser.imageUrl,
        unreadCounter: currentUser.unreadCounter,
        nameSearch: nameSearch,
      );

      // Update user via provider
      await Provider.of<UserProvider>(context, listen: false)
          .updateUser(updatedUser);

      log('Profile updated successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    // Initialize name controller with current user name when not editing
    if (!_isEditing && user?.name != null) {
      _nameController.text = user!.name!;
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            50.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Profile', style: heading),
                IconButton(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit,
                      color: primary),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      // Reset name controller when canceling edit
                      if (!_isEditing && user?.name != null) {
                        _nameController.text = user!.name!;
                      }
                    });
                  },
                ),
              ],
            ),
            30.verticalSpace,

            // User avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: grey.withAlpha(75),
              child: user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        user.imageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                          user.name != null && user.name!.isNotEmpty
                              ? user.name![0]
                              : '?',
                          style: heading.copyWith(fontSize: 40.sp),
                        ),
                      ),
                    )
                  : Text(
                      user?.name != null && user!.name!.isNotEmpty
                          ? user.name![0]
                          : '?',
                      style: heading.copyWith(fontSize: 40.sp),
                    ),
            ),
            20.verticalSpace,

            // User info or edit form
            _isEditing
                ? Column(
                    children: [
                      CustomTextfield(
                        controller: _nameController,
                        hintText: "Enter your name",
                      ),
                      20.verticalSpace,
                      CustomButton(
                        text: 'Update Profile',
                        loading: _isLoading,
                        onPressed:
                            _isLoading ? null : () => _updateProfile(user!),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: heading.copyWith(fontSize: 24.sp),
                      ),
                      5.verticalSpace,
                      Text(
                        user?.email ?? 'Email',
                        style: body.copyWith(color: grey),
                      ),
                    ],
                  ),

            const Spacer(),

            // Message Yourself button
            CustomButton(
              text: 'Message Yourself',
              onPressed:
                  user != null ? () => _messageYourself(context, user) : null,
              backgroundColor: Colors.transparent,
              textColor: primary,
              borderColor: primary,
            ),
            15.verticalSpace,

            CustomButton(
              text: 'Log Out',
              onPressed: () async {
                try {
                  await AuthService().logout();
                  // Provider will be updated through the wrapper
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error logging out: $e')),
                  );
                }
              },
            ),
            30.verticalSpace,
          ],
        ),
      ),
    );
  }

  // Method to create or navigate to self-chat
  Future<void> _messageYourself(BuildContext context, UserModels user) async {
    if (user.uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data is incomplete')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Create a special version of the user's own profile for self-chat
      final selfChatUser = UserModels(
        uid: user.uid,
        name: "Its Me (${user.name})",
        email: user.email,
        imageUrl: user.imageUrl,
        unreadCounter: 0,
        nameSearch: user.nameSearch,
      );

      // Check if a chat already exists with this user
      final chatService = ChatService();
      final haveChatted = await chatService.haveChatted(user.uid!, user.uid!);

      if (!haveChatted) {
        // If no self-chat exists, create one with a welcome message
        final now = DateTime.now();

        final messageInfo = {
          'content': "Welcome to your personal space!",
          'timestamp': now.millisecondsSinceEpoch,
          'senderId': user.uid,
        };

        // Add user to chat contacts (with self)
        await chatService.addUserToChatContacts(user.uid!, {
          ...selfChatUser.toMap(),
          'lastMessage': messageInfo,
          'unreadCounter': 0,
        });
      }

      // Navigate to chat screen
      if (mounted) {
        // Switch to chats tab first
        final navViewModel =
            Provider.of<BottomNavigationViewmodel>(context, listen: false);
        navViewModel.setIndex(1);

        // Navigate to chat room with self
        Navigator.pushNamed(
          context,
          chatRoom,
          arguments: selfChatUser,
        );
      }
    } catch (e) {
      log('Error creating self-chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating self-chat: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
