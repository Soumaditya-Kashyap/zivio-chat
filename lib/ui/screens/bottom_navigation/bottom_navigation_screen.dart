import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/ui/others/user_provider.dart';
import 'package:chat_app/ui/screens/bottom_navigation/Profile/profile_screen.dart';
import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_viewmodel.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chats_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

List<Widget> screens = [
  ChatsListScreen(),
  ChatsListScreen(),
  ChatsListScreen(),
];

class BottomNavigationScreen extends StatelessWidget {
  const BottomNavigationScreen({super.key});

  static final List<Widget> _screens = [
    Center(child: const Text('Home Screen')),
    const ChatsListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    final items = [
      BottomNavigationBarItem(
          label: '', icon: BottomNavButton(iconPath: homeIcon)),
      BottomNavigationBarItem(
          label: '', icon: BottomNavButton(iconPath: chatsIcon)),
      BottomNavigationBarItem(
          label: '', icon: BottomNavButton(iconPath: profileIcon)),
    ];
    return ChangeNotifierProvider(
      create: (context) => BottomNavigationViewmodel(),
      child: Consumer<BottomNavigationViewmodel>(builder: (context, model, _) {
        return currentUser == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                body: BottomNavigationScreen._screens[model.currentIndex],
                bottomNavigationBar: CustomNavBar(
                  onTap: model.setIndex,
                  items: items,
                ),
              );
      }),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
    this.onTap,
    required this.items,
  });

  final void Function(int)? onTap;
  final List<BottomNavigationBarItem> items;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    );
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              spreadRadius: 0,
              blurRadius: 10,
            )
          ]),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BottomNavigationBar(
          onTap: onTap,
          items: items,
        ),
      ),
    );
  }
}

class BottomNavButton extends StatelessWidget {
  const BottomNavButton({
    super.key,
    required this.iconPath,
  });

  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Image.asset(
        iconPath,
        height: 40,
        width: 40,
      ),
    );
  }
}
