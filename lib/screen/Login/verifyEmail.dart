// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../../apiModel/ConfirmOtp/ConfirmOtpRequest.dart';
import '../../apiModel/ConfirmOtp/ConfrimOtpResponse.dart';
import '../../apiModel/ResendOtp/ResendOtpRequest.dart';
import '../../apiModel/ResendOtp/ResendOtpResponse.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../../constants/constants.dart';
import '../../models/feature/feature_data.dart';
import '../../service/otpfield.dart';
import '../Wlcome/provideMeSomeInsights.dart';
import '../huntfishAiSettingsData.dart';
import 'LoginScreen.dart';

class VerifyEmail extends StatefulWidget {
  String email;
  String name;
  VerifyEmail({Key? key, required this.email, required this.name})
      : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
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
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ProvideMeInsights(
                isBrook: true,
                name: widget.name,
                data: FeatureData(
                    image: "assets/images/q_and_a.png",
                    title: "Question and Answer",
                    imageColor: Colors.indigo,
                    bgColor: Colors.indigoAccent,
                    type: FeatureType.kCompletion))));
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
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const LoginScreen()));
          },
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
          "Verify E-Mail",
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
              height: 10.h,
            ),
            SizedBox(
              height: 4.h,
            ),
            Center(
              child: Text(
                "Please Enter the Verification Code\n                sent to your E-Mail.",
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
              cursorColor: Colors.black,
              fillColor: Colors.black,
              textStyle: const TextStyle(color: Colors.black),
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
                if (verificationCode.isEmpty) {
                  // OtpTextField is empty
                  // You can add your logic here to handle the case when it's empty
                } else {
                  // OtpTextField is not empty
                  // You can add your logic here to handle the case when it's not empty
                }
              }, // end onSubmit
            ),
            SizedBox(
              height: 4.h,
            ),
            GestureDetector(
              onTap: () {
                DioClient.get().toAst("OTP was re-sent to your E-Mail.");
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
                          DioClient.get().toAst("OTP Field is required!");
                        } else {
                          isLoading = true;
                          confirmOtpApi();
                        }
                        setState(() {});
                      },
                      child: Container(
                          width: double.maxFinite,
                          height: 7.h,
                          margin: EdgeInsets.only(
                              left: 4.w, right: 4.w, bottom: 10.h),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: const Offset(4,
                                    4), // Adjust the values for the desired shadow position
                              ),
                            ],
                            borderRadius: BorderRadius.circular(3.w),
                            color: const Color(0xffFFCE3C),
                          ),
                          child: Container(
                              width: double.maxFinite,
                              height: 7.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.w),
                                color: const Color(0xffFFCE3C),
                              ),
                              child: Text(
                                "Submit OTP",
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xff1F1F1F),
                                    decoration: TextDecoration.none),
                              ))),
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
