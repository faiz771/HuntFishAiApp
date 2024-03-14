// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:huntfishai/apiModel/ResetPassword/ResetPasswordRequest.dart';
import 'package:huntfishai/screen/Login/LoginScreen.dart';
import 'package:sizer/sizer.dart';

import '../../apiModel/ResetPassword/ResetPasswordResponse.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../../helper/TextField_widget.dart';
import '../helperModel/validations.dart';
import '../huntfishAiSettingsData.dart';

class ResetPassword extends StatefulWidget {
  String email;
  ResetPassword({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool isObscure = true;
  bool isConfirmObscure = true;
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswprdController = TextEditingController();
  final resetFormKey = GlobalKey<FormState>();
  bool userInteraction = false;
  bool isLoading = false;
  ResetOtpResponse resetOtpResponse = ResetOtpResponse();
  resetPsswordApi() async {
    try {
      final request = ResetOtpRequest(
          email: widget.email,
          confirmPassword: newPasswprdController.text,
          password: passwordController.text);
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.resetPassword, request);
      resetOtpResponse = ResetOtpResponse.fromJson(response.data);
      if (resetOtpResponse.code == 200) {
        isLoading = false;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const LoginScreen()));
      } else if (resetOtpResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        DioClient.get().toAst(resetOtpResponse.message.toString());
        isLoading = false;
        setState(() {});
      } else {
        DioClient.get().toAst(resetOtpResponse.message.toString());
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
    return Scaffold(
      backgroundColor: AddSettingsData.themeValue == 2
          ? Colors.white
          : AddSettingsData.themeValue == 1
              ? const Color(0xff000221)
              : Colors.black,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 11.h,
        leadingWidth: 20.w,
        backgroundColor: AddSettingsData.themeValue == 2
            ? Colors.white
            : AddSettingsData.themeValue == 1
                ? const Color(0xff000221)
                : Colors.black,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            height: 6.2.h,
            margin: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 2.4.h),
            width: 12.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.5.w),
                color: AddSettingsData.themeValue == 1
                    ? Colors.white.withOpacity(0.10)
                    : const Color(0xff323232)),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 3.2.h,
            ),
          ),
        ),
        title: Text(
          "Forgot Password",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color:
                AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: Form(
          key: resetFormKey,
          autovalidateMode: userInteraction == true
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            children: [
              SizedBox(
                height: 4.h,
              ),
              SvgPicture.asset(
                "assets/images/Illustration1.svg",
                height: 25.h,
              ),
              SizedBox(
                height: 4.h,
              ),
              Center(
                child: Text(
                  "Please Enter your email to reset your\n                           password",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AddSettingsData.themeValue == 2
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 6.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: TextFieldWidget(
                    fillColor: AddSettingsData.themeValue == 2
                        ? const Color(0xffEBEBEB)
                        : AddSettingsData.themeValue == 1
                            ? Colors.white.withOpacity(0.10)
                            : const Color(0xff323232),
                    style: const TextStyle(color: Color(0xffADADAD)),
                    cursorColor: const Color(0xffADADAD),
                    hintText: "New Password",
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
                        color: const Color(0xffADADAD),
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
              ),
              SizedBox(
                height: 2.5.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: TextFieldWidget(
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
                    validatorText: (e) => Validators().validateConfirmPassword(
                        newPasswprdController.text, passwordController.text),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(1.8.h),
                      child: Image.asset(
                        "assets/images/pass.png",
                        height: 1.5.h,
                        color: const Color(0xffADADAD),
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
                    controller: newPasswprdController),
              ),
              SizedBox(
                height: 6.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: isLoading == false
                    ? GestureDetector(
                        onTap: () {
                          userInteraction = true;
                          if (resetFormKey.currentState!.validate()) {
                            isLoading = true;
                            resetPsswordApi();
                          }
                          setState(() {});
                        },
                        child: Container(
                            width: double.maxFinite,
                            height: 6.5.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.w),
                              color: const Color(0xffFFCE3C),
                            ),
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff1F1F1F),
                                  decoration: TextDecoration.none),
                            )),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xffFFCE3C))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
