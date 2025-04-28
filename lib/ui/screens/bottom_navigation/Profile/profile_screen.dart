import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/ui/others/user_provider.dart';
import 'package:chat_app/ui/widgets/buttton_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            50.verticalSpace,
            Text('Your Profile', style: heading),
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

            // User info
            Text(
              user?.name ?? 'User',
              style: heading.copyWith(fontSize: 24.sp),
            ),
            5.verticalSpace,
            Text(
              user?.email ?? 'Email',
              style: body.copyWith(color: grey),
            ),

            const Spacer(),

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
}
