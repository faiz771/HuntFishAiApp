import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huntfishai/apiModel/getMyDetail/GetMyDetailResponse.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:huntfishai/screen/Billing.dart';
import 'package:huntfishai/screen/Setting.dart';
import 'package:huntfishai/screen/chatbot/chatbot.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import '../../apiModel/createRoom/CreateRoomResponse.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../../constants/constants.dart';
import '../../models/feature/feature_data.dart';
import '../Login/LoginScreen.dart';
import '../huntfishAiSettingsData.dart';

class WelcomeScreen extends StatefulWidget {
  final bool? isBrook;
  final FeatureData? data;
  const WelcomeScreen({Key? key, this.data, this.isBrook}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  CreateRoomResponse createRoomResponse = CreateRoomResponse();
  int roomId = 0;
  int? checkCount = 0;
  bool isLoading = false;
  bool isSubscribed = false;
  String? customerId;

  @override
  void initState() {
    getCustomerId();
    super.initState();
  }

  GetMyDetailResponse getMyDetailResponse = GetMyDetailResponse();
  void getCustomerId() async {
    var response = await DioClient.get().dioGetMethod(ApiUrl.getMyDetail);
    try {
      getMyDetailResponse =
          GetMyDetailResponse.fromJson(jsonDecode(response.toString()));
      if (getMyDetailResponse.code == 200) {
        customerId = getMyDetailResponse.body?.customer_id;
        await Purchases.logIn("$customerId");
        print("logged in customer with id: $customerId");
        getSubscriptionStatus();
        setRevenueCatAttributes(getMyDetailResponse.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void setRevenueCatAttributes(responseBody) {
    try {
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
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future getSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all[entitlementID] != null &&
          customerInfo.entitlements.all[entitlementID]!.isActive) {
        isSubscribed = true;
      } else {
        isSubscribed = false;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  createRoom(bool isBrook) async {
    try {
      isLoading = true;
      setState(() {});
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.createRoom, null);
      createRoomResponse = CreateRoomResponse.fromJson(response.data);
      if (createRoomResponse.code == 200) {
        print("roomId---->${createRoomResponse.body?.room?.id}");
        roomId = createRoomResponse.body?.room?.id ?? 0;
        checkCount = createRoomResponse.body?.checkCount;
        print(isSubscribed);
        if (checkCount == 1 && isSubscribed == false) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const BillingScreen(hitLimit: true)));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatBotScreen(
              isBrook: isBrook,
              roomId: roomId.toString(),
              data: FeatureData(
                  image: "assets/images/q_and_a.png",
                  title: "Question and Answer",
                  imageColor: Colors.indigo,
                  bgColor: Colors.indigoAccent,
                  type: FeatureType.kCompletion),
            ),
          ));
        }
        isLoading = false;
        setState(() {});
      } else if (createRoomResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        isLoading = false;
        DioClient.get().toAst(createRoomResponse.message.toString());
        setState(() {});
      } else {
        isLoading = false;
        DioClient.get().toAst(createRoomResponse.message.toString());
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
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: const Color(0xff1C1C1C),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AddSettingsData.themeValue == 2
                  ? const AssetImage("assets/images/welcomeWhite.png")
                  : AddSettingsData.themeValue == 1
                      ? const AssetImage("assets/images/Home.png")
                      : const AssetImage("assets/images/home@3x.png"))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcome,
                        style: TextStyle(
                            fontSize: 22.sp,
                            color: const Color(0xffFFCE3C),
                            decoration: TextDecoration.none),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SettingScreen(),
                        )),
                        child: Container(
                          height: 6.2.h,
                          width: 12.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.5.w),
                              color: AddSettingsData.themeValue == 1
                                  ? Colors.white.withOpacity(0.10)
                                  : const Color(0xff323232)),
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 3.5.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.to,
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: AddSettingsData.themeValue == 2
                                ? Colors.black
                                : const Color(0xffFFFFFF),
                            decoration: TextDecoration.none),
                      ),
                      SizedBox(
                        width: 2.w,
                      ),
                      Text(
                        "HuntFish.ai",
                        style: TextStyle(
                            fontSize: 20.sp,
                            color: AddSettingsData.themeValue == 2
                                ? Colors.black
                                : const Color(0xffFFFFFF),
                            decoration: TextDecoration.none),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Text(AppLocalizations.of(context)!.welcome_aiPowered,
                      style: TextStyle(
                          fontSize: 11.2.sp,
                          color: AddSettingsData.themeValue == 2
                              ? Colors.black
                              : const Color(0xffFFFFFF),
                          decoration: TextDecoration.none)),
                ],
              ),
              isLoading == true
                  ? Center(
                      child: Padding(
                          padding: EdgeInsets.only(top: 40.h),
                          child: const CircularProgressIndicator(
                              color: Color(0xffFFCE3C))))
                  : GestureDetector(
                      onTap: () {
                        createRoom(false);
                        /*Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChooseScreen(isBrook: widget.isBrook,data: widget.data,)));*/
                      },
                      child: Container(
                          width: double.maxFinite,
                          height: 8.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.w),
                            color: const Color(0xffFFCE3C),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.welcome_askYourGuide,
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff1F1F1F),
                                decoration: TextDecoration.none),
                          )),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
