// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huntfishai/constants/constants.dart';
import 'package:huntfishai/screen/Wlcome/welcomeScreen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api_collection/dio_api_method.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'huntfishAiSettingsData.dart';

class BillingScreen extends StatefulWidget {
  final bool hitLimit;
  const BillingScreen({Key? key, required this.hitLimit}) : super(key: key);

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  String offerPrice = '\$6.99';
  String validUntil = '';
  DateTime dT = DateTime.now();
  Package? package;
  bool isSubscribed = false;
  bool isLoading = false;

  @override
  void initState() {
    getOfferingsFromRevCat();
    getSubscriptionStatus();
    super.initState();
  }

  @override
  void dispose() {
    isSubscribed = false;
    super.dispose();
  }

  void attemptSubscription() async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package!);
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all[entitlementID];
      isSubscribed = entitlement?.isActive ?? false;
      if (isSubscribed) {
        DioClient.get().toAst('Subscription Successful, Thank You!');
        print(customerInfo);
        getSubscriptionStatus();
        print(isSubscribed);
      } else {
        print('failed');
      }
    } on PlatformException catch (e) {
      DioClient.get().toAst(AppLocalizations.of(context)!.getsub_error);
      if (kDebugMode) {
        print(e.message);
        DioClient.get().toAst("${e.message}");
      }
    }
    isLoading = false;
    setState(() {});
    // Navigator.pop(context);
  }

  getSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all[entitlementID] != null &&
          customerInfo.entitlements.all[entitlementID]!.isActive) {
        isSubscribed = true;
        EntitlementInfo? entitlement =
            customerInfo.entitlements.all[entitlementID];
        validUntil = entitlement!.latestPurchaseDate;
        dT = DateTime.tryParse(validUntil)!;
        setState(() {
          if (kDebugMode) {
            print('customer is subscribed to $entitlementID');
          }
        });
      } else {
        isSubscribed = false;
        setState(() {
          if (kDebugMode) {
            print(customerInfo);
            print('customer is NOT subscribed to $entitlementID');
            print(isSubscribed ? 'yes' : 'no');
          }
        });
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  getOfferingsFromRevCat() async {
    Offerings? offerings;
    try {
      offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current?.monthly != null) {
        package = offerings.current!.monthly!;
        offerPrice =
            offerings.current!.monthly!.storeProduct.priceString.toString();
        print(package);
        print(offerPrice);
        setState(() {});
      }
    } on PlatformException catch (e) {
      DioClient.get().toAst(AppLocalizations.of(context)!.getsub_error);
      // Navigator.pop(context);
      if (kDebugMode) {
        print(e);
      }
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
          backgroundColor:
              AddSettingsData.themeValue == 2 ? Colors.white : Colors.black,
          leadingWidth: 15.w,
          toolbarHeight: 7.h,
          centerTitle: true,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => widget.hitLimit
                ? Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const WelcomeScreen()))
                : Navigator.of(context).pop(),
            child: Container(
              width: 12.w,
              margin: EdgeInsets.only(left: 2.w),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.5.w),
                  color: Color(0xff323232)),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 3.h,
              ),
            ),
          ),
          title: Text(
            "Subscription",
            style: TextStyle(
              color:
                  AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(),
          child: Center(
              child: SingleChildScrollView(
                  child: Column(children: [
            SizedBox(height: 1.h),
            Stack(
              children: [
                Image.asset(
                  "assets/images/subscribe_lake.jpg",
                  height: 25.h,
                  fit: BoxFit.fitWidth,
                  width: double.maxFinite,
                  alignment: Alignment.centerRight,
                )
              ],
            ),
            SizedBox(height: 3.h),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Visibility(
                  visible: isSubscribed,
                  child: Column(children: [
                    Text(
                        AppLocalizations.of(context)!.subscription_subbedThanks,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 6.h),
                    Padding(
                        padding: EdgeInsets.only(left: 5.w, right: 5.w),
                        child: Text(
                            AppLocalizations.of(context)!
                                .subscription_subbedBlurb,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white))),
                    SizedBox(height: 10.h),
                    Text(
                        AppLocalizations.of(context)!
                            .subscription_subbedExpires(
                                dT.month, dT.day, dT.year),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(height: 3.h),
                  ]));
            }),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Visibility(
                  visible: !isSubscribed,
                  child: Column(children: [
                    Text(AppLocalizations.of(context)!.subscription_getGuidance,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 2.h),
                    Visibility(
                        visible: widget.hitLimit,
                        child: Text(
                            AppLocalizations.of(context)!.subscription_hitLimit,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
                    SizedBox(height: 5.h),
                    Padding(
                        padding: EdgeInsets.only(left: 5.w, right: 5.w),
                        child: Text(
                            AppLocalizations.of(context)!.subscription_blurb,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white))),
                    SizedBox(height: 5.h),
                    Text(
                        AppLocalizations.of(context)!
                            .subscription_priceLine(offerPrice),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(height: 4.h),
                    isLoading == false
                        ? GestureDetector(
                            onTap: () async {
                              if (!isLoading) {
                                isLoading = true;
                                attemptSubscription();
                                setState(() {});
                              } else {}
                            },
                            child: Container(
                                width: double.maxFinite,
                                height: 6.h,
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
                                    height: 6.h,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.w),
                                      color: const Color(0xffFFCE3C),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .subscription_subButton,
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xff1F1F1F),
                                          decoration: TextDecoration.none),
                                    ))),
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xffFFCE3C)),
                          ),
                  ]));
            }),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              InkWell(
                  onTap: () => launchUrl(
                      Uri.parse("https://www.huntfish.ai/privacy-tos")),
                  child: Text(AppLocalizations.of(context)!.tos,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline))),
            ])
          ]))),
        ));
  }
}
