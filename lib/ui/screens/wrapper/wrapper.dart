import 'dart:developer';

import 'package:chat_app/ui/others/user_provider.dart';
import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_screen.dart';
import 'package:chat_app/ui/screens/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Error');
          }

          final user = snapshot.data;
          if (user == null) {
            log('User Loged Out');
            return const LoginScreen();
          } else {
            // Load user data when auth state changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              userProvider.loadUser(user.uid);
              log('User loged In');
            });
            return const BottomNavigationScreen();
          }
        });
  }
}
