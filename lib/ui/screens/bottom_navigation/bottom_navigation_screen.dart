import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/ui/others/user_provider.dart';
import 'package:chat_app/ui/screens/bottom_navigation/Profile/profile_screen.dart';
import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_viewmodel.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chats_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class BottomNavigationScreen extends StatelessWidget {
  const BottomNavigationScreen({super.key});

  static final List<Widget> _screens = [
    const Center(child: Text('Home Screen')),
    const ChatsListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    final items = [
      BottomNavigationBarItem(
          icon: BottomNavButton(iconPath: homeIcon), label: 'Home'),
      BottomNavigationBarItem(
          icon: BottomNavButton(iconPath: chatsIcon), label: 'Chats'),
      BottomNavigationBarItem(
          icon: BottomNavButton(iconPath: profileIcon), label: 'Profile'),
    ];

    return ChangeNotifierProvider(
      create: (context) => BottomNavigationViewmodel(),
      child: Consumer<BottomNavigationViewmodel>(builder: (context, model, _) {
        return currentUser == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                body: _screens[model.currentIndex],
                bottomNavigationBar: CustomNavBar(
                  currentIndex: model.currentIndex,
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
    required this.currentIndex,
  });

  final void Function(int)? onTap;
  final List<BottomNavigationBarItem> items;
  final int currentIndex;

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
          currentIndex: currentIndex,
          items: items,
          selectedItemColor: primary,
          unselectedItemColor: grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
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
        height: 30,
        width: 30,
      ),
    );
  }
}
