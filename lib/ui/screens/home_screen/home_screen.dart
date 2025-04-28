import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/others/user_provider.dart';
import 'package:chat_app/ui/screens/home_screen/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider(
      create: (context) => HomeViewmodel(DatabaseService()),
      child: Consumer<HomeViewmodel>(builder: (context, model, _) {
        return Scaffold(
          body: Center(
            child: userProvider.user == null
                ? const CircularProgressIndicator()
                : InkWell(
                    onTap: () async {
                      try {
                        await AuthService().logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout failed: $e')),
                          );
                        }
                      }
                    },
                    child: Text(userProvider.user.toString()),
                  ),
          ),
        );
      }),
    );
  }
}
