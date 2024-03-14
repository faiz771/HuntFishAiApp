import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:huntfishai/apiModel/forgotpassword/forgotPasswordResponse.dart';
import 'package:huntfishai/apiModel/forgotpassword/forgotpasswordrequest.dart';
import 'package:huntfishai/screen/Login/VerifyForgotEmail.dart';
import 'package:sizer/sizer.dart';

import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../../helper/TextField_widget.dart';
import '../helperModel/validations.dart';
import '../huntfishAiSettingsData.dart';
import 'LoginScreen.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  final forgotFormKey = GlobalKey<FormState>();
  bool userInteraction = false;
  bool isLoading = false;
  ForgotPasswordResponse forgotPasswordResponse = ForgotPasswordResponse();

  forgotApi() async {
    try {
      final request = ForgotPasswordRequest(
        email: emailController.text,
      );
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.resendOtp, request);

      forgotPasswordResponse = ForgotPasswordResponse.fromJson(response.data);
      print("forgotPasswordResponse${forgotPasswordResponse.code}");
      if (forgotPasswordResponse.code == 200) {
        isLoading = false;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => VerifyForgotEmail(
                      email: emailController.text,
                    )));
        setState(() {});
      } else if (forgotPasswordResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        DioClient.get().toAst(forgotPasswordResponse.message.toString());
        isLoading = false;
        setState(() {});
      } else {
        DioClient.get().toAst(forgotPasswordResponse.message.toString());
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
                "Enter your E-Mail to reset your password",
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
            Form(
              key: forgotFormKey,
              autovalidateMode: userInteraction == true
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: TextFieldWidget(
                    style: const TextStyle(color: Color(0xffADADAD)),
                    cursorColor: const Color(0xffADADAD),
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.text,
                    hintText: "Enter your E-Mail",
                    fillColor: AddSettingsData.themeValue == 2
                        ? const Color(0xffEBEBEB)
                        : AddSettingsData.themeValue == 1
                            ? Colors.white.withOpacity(0.10)
                            : const Color(0xff323232),
                    validatorText: (e) =>
                        Validators().validateEmailForm(e ?? ""),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(2.h),
                      child: Image.asset(
                        "assets/images/mesage.png",
                        height: 1.5.h,
                        color: AddSettingsData.themeValue == 1
                            ? Colors.white
                            : const Color(0xffADADAD),
                      ),
                    ),
                    hintStyle: const TextStyle(
                        color: Color(0xffADADAD), fontStyle: FontStyle.italic),
                    controller: emailController),
              ),
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
                        if (forgotFormKey.currentState!.validate()) {
                          isLoading = true;
                          forgotApi();
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
                            "Request Password Reset",
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff1F1F1F),
                                decoration: TextDecoration.none),
                          )),
                    )
                  : const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xffFFCE3C))),
            )
          ],
        ),
      ),
    );
  }
}
