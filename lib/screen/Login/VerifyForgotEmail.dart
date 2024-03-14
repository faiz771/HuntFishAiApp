import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:huntfishai/apiModel/ConfirmOtp/ConfirmOtpRequest.dart';
import 'package:huntfishai/apiModel/ConfirmOtp/ConfrimOtpResponse.dart';
import 'package:huntfishai/apiModel/ResendOtp/ResendOtpRequest.dart';
import 'package:huntfishai/apiModel/ResendOtp/ResendOtpResponse.dart';
import 'package:huntfishai/screen/Login/resetPassword.dart';
import 'package:sizer/sizer.dart';

import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../../service/otpfield.dart';
import '../huntfishAiSettingsData.dart';
import 'LoginScreen.dart';

class VerifyForgotEmail extends StatefulWidget {
  String email;
  VerifyForgotEmail({Key? key, required this.email}) : super(key: key);

  @override
  State<VerifyForgotEmail> createState() => _VerifyForgotEmailState();
}

class _VerifyForgotEmailState extends State<VerifyForgotEmail> {
  String? otp;
  bool isLoading = false;
  ConfirmOtpResponse confirmOtpResponse = ConfirmOtpResponse();
  ResendOtpResponse resendOtpResponse = ResendOtpResponse();

  resendOtpApi() async {
    try {
      final request = ResendOtpRequest(
        email: widget.email,
      );
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.resendOtp, request);
      resendOtpResponse = ResendOtpResponse.fromJson(response.data);
      if (resendOtpResponse.code == 200) {
        DioClient.get().toAst(resendOtpResponse.message.toString());
      } else if (resendOtpResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        DioClient.get().toAst(resendOtpResponse.message.toString());
        isLoading = false;
        setState(() {});
      } else {
        DioClient.get().toAst(resendOtpResponse.message.toString());
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

  confirmOtpApi() async {
    try {
      final request = ConfirmOtpRequest(email: widget.email, otp: otp);
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.confirmOtp, request);
      confirmOtpResponse = ConfirmOtpResponse.fromJson(response.data);
      if (confirmOtpResponse.code == 200) {
        isLoading = false;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ResetPassword(
                      email: widget.email,
                    )));
        setState(() {});
      } else if (confirmOtpResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        DioClient.get().toAst(confirmOtpResponse.message.toString());
        isLoading = false;
        setState(() {});
      } else {
        DioClient.get().toAst(confirmOtpResponse.message.toString());
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
          "Verify Email",
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
              "assets/images/Illustration.svg",
              height: 25.h,
            ),
            SizedBox(
              height: 4.h,
            ),
            Center(
              child: Text(
                "Please Enter the Verification Code\n                sent to your Email",
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
            OtpTextField(
              textStyle: TextStyle(
                color: AddSettingsData.themeValue == 1
                    ? Colors.white
                    : Colors.black,
              ),
              numberOfFields: 6,
              borderColor: const Color(0xFF512DA8),
              //set to true to show as box or false to show as dash
              showFieldAsBox: true,
              //runs when a code is typed in
              onCodeChanged: (String code) {
                otp = code; // Update otp variable as the user types
              },
              //runs when every textfield is filled
              onSubmit: (String verificationCode) {
                otp = verificationCode;
              }, // end onSubmit
            ),
            SizedBox(
              height: 4.h,
            ),
            GestureDetector(
              onTap: () {
                resendOtpApi();
              },
              child: Text(
                "Resend OTP",
                textAlign: TextAlign.center,
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
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: isLoading == false
                  ? GestureDetector(
                      onTap: () {
                        if (otp?.isEmpty == true) {
                          DioClient.get().toAst("otp field is required");
                        } else {
                          isLoading = true;
                          confirmOtpApi();
                        }

                        setState(() {});
                      },
                      child: Container(
                          width: double.maxFinite,
                          height: 6.h,
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
                      child:
                          CircularProgressIndicator(color: Color(0xffFFCE3C))),
            )
          ],
        ),
      ),
    );
  }
}
