import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/extensions/widget_extention.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/ui/screens/login/login_viewmodel.dart';
import 'package:chat_app/ui/widgets/buttton_widget.dart';
import 'package:chat_app/ui/widgets/textfiled_widgte.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewmodel(
        AuthService(),
      ),
      child: Consumer<LoginViewmodel>(
          // with the help of consumer, we can listen to the changes in the viewmodel, and rebuild the UI
          builder: (context, model, _) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 1.sw * 0.05,
              vertical: 10.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //45.verticalSpace,
                Text('Login', style: heading),
                5.verticalSpace,
                Text(
                  "Please Login to your account",
                  style: body.copyWith(color: grey),
                ),
                24.verticalSpace,
                CustomTextfield(
                  hintText: "Enter Email",
                  onChanged: model
                      .setEmail, //When the user types something, onChanged will be called, it will help to update the value of the textfield, p0 is proxyprovider, just used no reason
                ),
                20.verticalSpace,
                CustomTextfield(
                  hintText: "Enter Password",
                  onChanged: model
                      .setPassword, //When the user types something, onChanged will be called, it will help to update the value of the textfield, p0 is proxyprovider, just used no reason
                ),
                30.verticalSpace,
                CustomButton(
                    loading: model.state == ViewState.loading,
                    onPressed: model.state == ViewState.loading
                        ? null
                        : () async {
                            try {
                              final user = await model.login();
                              if (user != null && context.mounted) {
                                context.showSnackBar('Login Successful');
                                // Navigate to bottom navigation screen instead of home
                                Navigator.pushReplacementNamed(
                                  context,
                                  wrapper,
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              if (context.mounted) {
                                context.showSnackBar(e.message ?? e.toString());
                              }
                            } catch (e) {
                              if (context.mounted) {
                                context.showSnackBar(e.toString());
                              }
                            }
                          },
                    text: 'Login'),
                20.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?',
                        style: body.copyWith(color: grey)),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, signup);
                      },
                      child: Text(
                        'Sign Up',
                        style: body.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
