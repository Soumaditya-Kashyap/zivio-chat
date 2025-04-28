import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_room/chat_screen.dart';
import 'package:chat_app/ui/screens/wrapper/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/ui/screens/splash_screens/splash_screen.dart';
import 'package:chat_app/ui/screens/home_screen/home_screen.dart';
import 'package:chat_app/ui/screens/signup/signup_screen.dart';
import 'package:chat_app/ui/screens/login/login_screen.dart';

class RouteUtils {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    //setting is the route that is to be navigated to, can be home, splash, etc.
    switch (settings.name) {
      //Splash Screen Navigation route
      case splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());

      //Auth Screens Navigation routes
      case signup:
        return MaterialPageRoute(builder: (context) => SignupScreen());
      case login:
        return MaterialPageRoute(builder: (context) => LoginScreen());

      //Home screen navigation route
      case home:
        return MaterialPageRoute(builder: (context) => HomeScreen());
      case wrapper:
        return MaterialPageRoute(builder: (context) => Wrapper());
      case chatRoom:
        return MaterialPageRoute(
            builder: (context) => ChatScreen(
                  receiver: args as UserModels,
                ));
      default:
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: Center(
                    child: Text(
                        'No route defined for ${settings.name}'), // of the specified route is not defined, this message will be displayed
                  ),
                ));
    }
  }
}
