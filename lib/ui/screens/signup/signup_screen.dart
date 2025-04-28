//import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/extensions/widget_extention.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/screens/signup/signup_viewmode.dart';
import 'package:chat_app/ui/widgets/buttton_widget.dart';
import 'package:chat_app/ui/widgets/textfiled_widgte.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

//import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignupViewmodel(
        AuthService(),
        DatabaseService(),
      ),
      child: Consumer<SignupViewmodel>(builder: (context, model, _) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 1.sw * 0.05,
                vertical: 10.h,
              ), //screen width sw, 10.h means a sizebox created with 10 height, by flutter util
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  45.verticalSpace,
                  Text('Create Your Account', style: heading),
                  5.verticalSpace, //a sizebox creted of 10 height , by flutter utils
                  Text(
                    "Please Provide the details",
                    style: body.copyWith(color: grey),
                  ),
                  24.verticalSpace,
                  CustomTextfield(
                    hintText: "Enter Your Name",
                    onChanged: model.setName,
                  ),
                  20.verticalSpace,
                  CustomTextfield(
                    hintText: "Enter Email",
                    onChanged: model.setEmail,
                  ),
                  20.verticalSpace,
                  CustomTextfield(
                    hintText: "Enter Password",
                    onChanged: model.setPassword,
                    isPassword: true,
                  ),
                  20.verticalSpace,
                  CustomTextfield(
                    hintText: "Confirm Password",
                    onChanged: model
                        .setConfirmPassword, //When the user types something, onChanged will be called, it will help to update the value of the textfield, p0 is proxyprovider, just used no reason
                    isPassword: true,
                  ),
                  30.verticalSpace,
                  CustomButton(
                      loading: model.state == ViewState.loading,
                      onPressed: model.state == ViewState.loading
                          ? null
                          : () async {
                              try {
                                await model.signup();
                                context.showSnackBar(
                                    'Account Created Successfully');
                                Navigator.pop(
                                    context); // after signup, pop the screen and go to login screen, in  the login screen it will move to wrapper screen and then to home screen.
                              } on FirebaseAuthException catch (e) {
                                // ignore: use_build_context_synchronously
                                context.showSnackBar(e.toString());
                              } catch (e) {
                                // ignore: use_build_context_synchronously
                                context.showSnackBar(e.toString());
                              }
                            },
                      text: 'Sign Up'),
                  20.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?',
                          style: body.copyWith(color: grey)),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, login);
                        },
                        child: Text('Login',
                            style: body.copyWith(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            )),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
