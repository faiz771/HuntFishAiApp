import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:huntfishai/apiModel/getMyDetail/GetMyDetailResponse.dart';
import 'package:huntfishai/constants/constants.dart';
import 'package:huntfishai/apiModel/loginModel/LoginRequest.dart';
import 'package:huntfishai/helper/TextField_widget.dart';
import 'package:huntfishai/screen/Login/SignupScreen.dart';
import 'package:huntfishai/screen/Login/forgotPassword.dart';
import 'package:huntfishai/screen/Login/verifyEmail.dart';
import 'package:huntfishai/screen/Wlcome/welcomeScreen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import '../../apiModel/loginModel/LoginResponse.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../../helper/shared_prefrence.dart';
import '../helperModel/validations.dart';
import '../huntfishAiSettingsData.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscure = true;
  String? customerId = "";

  final loginFormKey = GlobalKey<FormState>();
  bool userInteraction = false;
  bool isLoading = false;
  LoginResponse loginResponse = LoginResponse();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> initPlatformState(userId) async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(googleApiKey)..appUserID = userId;
      await Purchases.configure(configuration);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(appleApiKey)..appUserID = userId;
      await Purchases.configure(configuration);
    }
  }

  void setRevenueCatAttributes(responseBody) {
    if (responseBody != null) {
      Purchases.setEmail(responseBody.email);
      Purchases.setDisplayName(responseBody.fullName);
      Purchases.setAttributes({
        "location": responseBody.location,
        "equipment": responseBody.equipment,
        "experienceLevel": responseBody.experience,
        "interests": responseBody.intrests,
        "regulations": responseBody.regulatoryUnderstanding,
      });
      print('revenuecat attributes set');
    } else {
      print('revenuecat attributes not set');
    }
  }

  loginApi() async {
    try {
      final request = LoginRequest(
        email: emailController.text,
        password: passwordController.text,
      );
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.loginApi, request);
      loginResponse = LoginResponse.fromJson(response.data);
      if (loginResponse.code == 200) {
        String? token = loginResponse.body?.token;
        String? userId = loginResponse.body?.user!.customer_id;
        print("token---->$token");
        PreferenceManager.get()
            .preferenceSet(PreferenceConstants.accessToken, token);
        initPlatformState("$userId");
        isLoading = false;

        setState(() {});
        if (loginResponse.body?.user?.otpVerify == "1") {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const WelcomeScreen()));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => VerifyEmail(
                  email: emailController.text,
                  name: loginResponse.body?.user?.fullName.toString() ?? "")));
          setState(() {});
          setRevenueCatAttributes(loginResponse.body?.user);
        }
      } else if (loginResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        DioClient.get().toAst(loginResponse.message.toString());
        isLoading = false;
        setState(() {});
      } else {
        DioClient.get().toAst(loginResponse.message.toString());
        isLoading = false;
        setState(() {});
      }
    } catch (e) {
      print(loginResponse.message.toString());
      print(e);
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
              key: loginFormKey,
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
                        "Welcome Back !",
                        style: TextStyle(
                            color: AddSettingsData.themeValue == 2
                                ? Colors.black
                                : Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Sign In",
                        style: TextStyle(
                            color: const Color(0xffFFCE3C),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4.h),
                      TextFieldWidget(
                          style: const TextStyle(color: Color(0xffADADAD)),
                          cursorColor: const Color(0xffADADAD),
                          hintText: "E-Mail",
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.emailAddress,
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
                              "assets/images/msg.png",
                              height: 1.h,
                              color: AddSettingsData.themeValue == 1
                                  ? Colors.white
                                  : const Color(0xffADADAD),
                            ),
                          ),
                          hintStyle: const TextStyle(
                              color: Color(0xffADADAD),
                              fontStyle: FontStyle.italic),
                          controller: emailController),
                      SizedBox(height: 2.5.h),
                      TextFieldWidget(
                          style: const TextStyle(color: Color(0xffADADAD)),
                          cursorColor: const Color(0xffADADAD),
                          textInputAction: TextInputAction.done,
                          textInputType: TextInputType.text,
                          hintText: "Password",
                          obscureText: isObscure,
                          fillColor: AddSettingsData.themeValue == 2
                              ? const Color(0xffEBEBEB)
                              : AddSettingsData.themeValue == 1
                                  ? Colors.white.withOpacity(0.10)
                                  : const Color(0xff323232),
                          validatorText: (e) =>
                              Validators().validatepassword(e ?? ""),
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
                          suffixIcon: GestureDetector(
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
                          hintStyle: const TextStyle(
                              color: Color(0xffADADAD),
                              fontStyle: FontStyle.italic),
                          controller: passwordController),
                      SizedBox(height: 2.2.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const ForgotPassword()));
                        },
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "Forgot Your Password?",
                            style: TextStyle(
                                color: AddSettingsData.themeValue == 1
                                    ? Colors.white
                                    : const Color(0xffADADAD),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Need an account? - ",
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AddSettingsData.themeValue == 2
                                    ? const Color(0xffADADAD)
                                    : Colors.white),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            )),
                            child: Text(
                              "Sign Up Here!",
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
                                if (loginFormKey.currentState!.validate()) {
                                  isLoading = true;
                                  loginApi();
                                }
                                setState(() {});
                              },
                              child: Container(
                                  width: double.maxFinite,
                                  height: 7.h,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3.w),
                                    color: const Color(0xffFFCE3C),
                                  ),
                                  child: Text(
                                    "Sign In",
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
