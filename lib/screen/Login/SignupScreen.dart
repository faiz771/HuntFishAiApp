import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:huntfishai/apiModel/signupModel/SignUpRequest.dart';
import 'package:huntfishai/apiModel/signupModel/signUpResponse.dart';
import 'package:huntfishai/constants/constants.dart';
import 'package:huntfishai/models/feature/feature_data.dart';
import 'package:huntfishai/screen/Login/LoginScreen.dart';
import 'package:huntfishai/screen/Login/verifyEmail.dart';
import 'package:huntfishai/screen/Wlcome/provideMeSomeInsights.dart';
import 'package:sizer/sizer.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../../helper/TextField_widget.dart';
import '../../helper/shared_prefrence.dart';
import '../helperModel/validations.dart';
import '../huntfishAiSettingsData.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isObscure = true;
  bool isConfirmObscure = true;
  final signupFormKey = GlobalKey<FormState>();
  bool userInteraction = false;
  bool isLoading = false;
  SignUpResponse signUpResponse = SignUpResponse();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  getDeviceType() {
    if (Platform.isAndroid) {
      return "android";
    }
    if (Platform.isIOS) {
      return "iOS";
    }

    return "unknown";
  }

  signupApi() async {
    try {
      final request = SignUpRequest(
          email: emailController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
          fullName: nameController.text,
          deviceType: getDeviceType());
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.signUpApi, request);
      signUpResponse = SignUpResponse.fromJson(response.data);
      if (signUpResponse.code == 200) {
        String? token = signUpResponse.body?.token;
        print("token---->$token");
        PreferenceManager.get()
            .preferenceSet(PreferenceConstants.accessToken, token);
        isLoading = false;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => VerifyEmail(
                      email: emailController.text,
                      name: nameController.text,
                    )));

        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //     builder: (context) => ProvideMeInsights(
        //         isBrook: true,
        //         name: nameController.text,
        //         data: FeatureData(
        //             image: "assets/images/q_and_a.png",
        //             title: "Question and Answer",
        //             imageColor: Colors.indigo,
        //             bgColor: Colors.indigoAccent,
        //             type: FeatureType.kCompletion))));
        setState(() {});
      } else if (signUpResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        DioClient.get().toAst(signUpResponse.message.toString());
        isLoading = false;
        setState(() {});
      } else {
        DioClient.get().toAst(signUpResponse.message.toString());
        isLoading = false;
        setState(() {});
      }
    } catch (e) {
      Timer(const Duration(seconds: 1), () {
        isLoading = false;
        setState(() {});
      });
      //DioClient.get().toAst(loginResponse.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AddSettingsData.themeValue == 2
            ? Colors.white
            : AddSettingsData.themeValue == 1
                ? const Color(0xff000221)
                : Colors.black,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Form(
              key: signupFormKey,
              autovalidateMode: userInteraction == true
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5.h),
                      Center(
                          child: AddSettingsData.themeValue == 2
                              ? Image.asset(
                                  "assets/images/black_large.png",
                                  height: 10.h,
                                )
                              : Image.asset(
                                  "assets/images/Group 6.png",
                                  height: 10.h,
                                )),
                      SizedBox(height: 7.h),
                      Text(
                        "Welcome to HuntFishAI!",
                        style: TextStyle(
                            color: AddSettingsData.themeValue == 2
                                ? Colors.black
                                : Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                            color: const Color(0xffFFCE3C),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4.h),
                      TextFieldWidget(
                          style: const TextStyle(color: Color(0xffADADAD)),
                          cursorColor: const Color(0xffADADAD),
                          hintText: "Full Name",
                          fillColor: AddSettingsData.themeValue == 2
                              ? const Color(0xffEBEBEB)
                              : AddSettingsData.themeValue == 1
                                  ? Colors.white.withOpacity(0.10)
                                  : const Color(0xff323232),
                          textInputType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          validatorText: (e) =>
                              Validators().validateName(e ?? ""),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(2.h),
                            child: Image.asset(
                              "assets/images/contact.png",
                              height: 1.h,
                              color: AddSettingsData.themeValue == 1
                                  ? Colors.white
                                  : const Color(0xffADADAD),
                            ),
                          ),
                          hintStyle: TextStyle(
                              color: const Color(0xffADADAD),
                              fontStyle: FontStyle.italic,
                              fontSize: 13.sp),
                          controller: nameController),
                      SizedBox(height: 2.5.h),
                      TextFieldWidget(
                          fillColor: AddSettingsData.themeValue == 2
                              ? const Color(0xffEBEBEB)
                              : AddSettingsData.themeValue == 1
                                  ? Colors.white.withOpacity(0.10)
                                  : const Color(0xff323232),
                          style: const TextStyle(color: Color(0xffADADAD)),
                          cursorColor: const Color(0xffADADAD),
                          hintText: "E-Mail",
                          textInputType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validatorText: (e) =>
                              Validators().validateEmailForm(e ?? ""),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(2.h),
                            child: Image.asset(
                              "assets/images/msg.png",
                              height: 1.h,
                              color: AddSettingsData.themeValue == 1
                                  ? Colors.white
                                  : const Color(0xffADADAD),
                            ),
                          ),
                          hintStyle: TextStyle(
                              color: const Color(0xffADADAD),
                              fontStyle: FontStyle.italic,
                              fontSize: 13.sp),
                          controller: emailController),
                      SizedBox(height: 2.5.h),
                      TextFieldWidget(
                          fillColor: AddSettingsData.themeValue == 2
                              ? const Color(0xffEBEBEB)
                              : AddSettingsData.themeValue == 1
                                  ? Colors.white.withOpacity(0.10)
                                  : const Color(0xff323232),
                          style: const TextStyle(color: Color(0xffADADAD)),
                          cursorColor: const Color(0xffADADAD),
                          hintText: "Password",
                          textInputType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          obscureText: isObscure,
                          validatorText: (e) =>
                              Validators().validatePassword(e ?? ""),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(1.8.h),
                            child: Image.asset(
                              "assets/images/pass.png",
                              height: 1.5.h,
                              color: AddSettingsData.themeValue == 1
                                  ? Colors.white
                                  : const Color(0xffADADAD),
                            ),
                          ),
                          suffixIcon: InkWell(
                              onTap: () {
                                isObscure = !isObscure;
                                setState(() {});
                              },
                              child: isObscure
                                  ? Icon(
                                      Icons.visibility_off,
                                      color: AddSettingsData.themeValue == 2
                                          ? const Color(0xffADADAD)
                                          : Colors.white,
                                      size: 2.9.h,
                                    )
                                  : Icon(
                                      Icons.visibility,
                                      color: AddSettingsData.themeValue == 2
                                          ? const Color(0xffADADAD)
                                          : Colors.white,
                                      size: 2.9.h,
                                    )),
                          hintStyle: TextStyle(
                              color: const Color(0xffADADAD),
                              fontStyle: FontStyle.italic,
                              fontSize: 13.sp),
                          controller: passwordController),
                      SizedBox(height: 2.5.h),
                      TextFieldWidget(
                          fillColor: AddSettingsData.themeValue == 2
                              ? const Color(0xffEBEBEB)
                              : AddSettingsData.themeValue == 1
                                  ? Colors.white.withOpacity(0.10)
                                  : const Color(0xff323232),
                          style: const TextStyle(color: Color(0xffADADAD)),
                          cursorColor: const Color(0xffADADAD),
                          hintText: "Confirm Password",
                          textInputType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          obscureText: isConfirmObscure,
                          validatorText: (e) => Validators()
                              .validateConfirmPassword(
                                  confirmPasswordController.text,
                                  passwordController.text),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(1.8.h),
                            child: Image.asset(
                              "assets/images/pass.png",
                              height: 1.5.h,
                              color: AddSettingsData.themeValue == 1
                                  ? Colors.white
                                  : const Color(0xffADADAD),
                            ),
                          ),
                          suffixIcon: InkWell(
                              onTap: () {
                                isConfirmObscure = !isConfirmObscure;
                                setState(() {});
                              },
                              child: isConfirmObscure
                                  ? Icon(
                                      Icons.visibility_off,
                                      color: AddSettingsData.themeValue == 2
                                          ? const Color(0xffADADAD)
                                          : Colors.white,
                                      size: 2.9.h,
                                    )
                                  : Icon(
                                      Icons.visibility,
                                      color: AddSettingsData.themeValue == 2
                                          ? const Color(0xffADADAD)
                                          : Colors.white,
                                      size: 2.9.h,
                                    )),
                          hintStyle: TextStyle(
                              color: const Color(0xffADADAD),
                              fontStyle: FontStyle.italic,
                              fontSize: 13.sp),
                          controller: confirmPasswordController),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an Account? - ",
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AddSettingsData.themeValue == 2
                                    ? const Color(0xffADADAD)
                                    : Colors.white),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            )),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 11.sp,
                                color: const Color(0xffFFCE3C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      isLoading == false
                          ? GestureDetector(
                              onTap: () {
                                userInteraction = true;
                                if (signupFormKey.currentState!.validate()) {
                                  isLoading = true;
                                  signupApi();
                                }
                                setState(() {});
                              },
                              child: Container(
                                  width: double.maxFinite,
                                  height: 7.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3.w),
                                    color: const Color(0xffFFCE3C),
                                  ),
                                  child: Container(
                                      width: double.maxFinite,
                                      height: 7.h,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(3.w),
                                        color: const Color(0xffFFCE3C),
                                      ),
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xff1F1F1F),
                                            decoration: TextDecoration.none),
                                      ))),
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xffFFCE3C),
                              ),
                            ),
                      SizedBox(height: 4.h),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
