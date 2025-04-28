import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/ui/others/user_provider.dart';
import 'package:chat_app/ui/screens/splash_screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chat_app/core/utils/route_utils.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gmgymwmqhdteckfwaqhq.supabase.co',  // Your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtZ3ltd21xaGR0ZWNrZndhcWhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIxMzUyMjAsImV4cCI6MjA1NzcxMTIyMH0.4f_BzadqaPFwdxWEkm6Ce3_w5d5oKPXhItHdZas0bHU',  // Your Supabase anon key
  );

  // Disable debug print
  debugPrint = (String? message, {int? wrapWidth}) {};

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    kDebugMode
        ? debugPrintRebuildDirtyWidgets =
            true //to debug the widgets that are rebuilt
        : debugPrintRebuildDirtyWidgets =
            false; //to debug the widgets that are rebuilt

    return ScreenUtilInit(
      builder: (context, child) => ChangeNotifierProvider(
        create: (context) => UserProvider(DatabaseService()),
        child: MaterialApp(
          onGenerateRoute: RouteUtils.onGenerateRoute,
          home: SplashScreen(),
        ),
      ),
    );
  }
}
