import 'package:flutter/material.dart';
import 'package:huntfishai/screen/Billing.dart';
import 'package:huntfishai/screen/Login/profileScreen.dart';
import 'package:huntfishai/screen/settings/GeographicalRegion.dart';
import 'package:huntfishai/screen/settings/backgroundTheme.dart';
import 'package:huntfishai/screen/settings/contactFeedBack.dart';
import 'package:huntfishai/screen/settings/feedbackPage.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'AISettingsScreen.dart';
import 'huntfishAiSettingsData.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            onTap: () => Navigator.of(context).pop(),
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
            AppLocalizations.of(context)!.settings_appBarTitle,
            style: TextStyle(
              color:
                  AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 2.5.h,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(1.h),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AddSettingsData.themeValue == 2
                      ? const Color(0xffEBEBEB)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        )),
                    leading: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xffD6FF7E).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(1.h)),
                        padding: EdgeInsets.only(
                            top: 1.25.h, bottom: 2.h, left: 2.w, right: 2.w),
                        child: Icon(Icons.person,
                            color: Colors.white, size: 3.5.h)),
                    title: Text(
                      AppLocalizations.of(context)!.settings_profile,
                      style: TextStyle(
                          color: AddSettingsData.themeValue == 2
                              ? const Color(0xff1C1C1C)
                              : Colors.white,
                          fontSize: 12.sp),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 3.5.h,
                      color: AddSettingsData.themeValue == 2
                          ? const Color(0xff1C1C1C)
                          : Colors.white,
                    )),
              ),
              SizedBox(
                height: 3.h,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(1.h),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AddSettingsData.themeValue == 2
                      ? const Color(0xffEBEBEB)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AISettingsScreen(),
                        )),
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xff394346),
                          borderRadius: BorderRadius.circular(1.h)),
                      padding: EdgeInsets.only(
                          top: 1.25.h, bottom: 2.h, left: 2.w, right: 2.w),
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 3.5.h,
                      ),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.settings_insights,
                      style: TextStyle(
                          color: AddSettingsData.themeValue == 2
                              ? const Color(0xff1C1C1C)
                              : Colors.white,
                          fontSize: 12.sp),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 3.5.h,
                        color: AddSettingsData.themeValue == 2
                            ? const Color(0xff1C1C1C)
                            : Colors.white)),
              ),
              SizedBox(
                height: 3.h,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(1.h),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AddSettingsData.themeValue == 2
                      ? const Color(0xffEBEBEB)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const GeographicalRegionScreen(),
                        )),
                    leading: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xff473B3B),
                            borderRadius: BorderRadius.circular(1.h)),
                        padding: EdgeInsets.only(
                            top: 1.25.h, bottom: 2.h, left: 2.w, right: 2.w),
                        child: Icon(Icons.location_on,
                            color: Colors.white, size: 3.5.h)),
                    title: Text(
                      AppLocalizations.of(context)!.settings_geoLocation,
                      style: TextStyle(
                          color: AddSettingsData.themeValue == 2
                              ? const Color(0xff1C1C1C)
                              : Colors.white,
                          fontSize: 12.sp),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 3.5.h,
                      color: AddSettingsData.themeValue == 2
                          ? const Color(0xff1C1C1C)
                          : Colors.white,
                    )),
              ),
              SizedBox(
                height: 3.h,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(1.h),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AddSettingsData.themeValue == 2
                      ? const Color(0xffEBEBEB)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const BackgroundThemeScreen(),
                        )),
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xff39473D),
                          borderRadius: BorderRadius.circular(1.h)),
                      padding: EdgeInsets.only(
                          top: 1.25.h, bottom: 2.h, left: 2.w, right: 2.w),
                      child: Icon(Icons.color_lens,
                          color: Colors.white, size: 3.5.h),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.settings_bgTheme,
                      style: TextStyle(
                          color: AddSettingsData.themeValue == 2
                              ? const Color(0xff1C1C1C)
                              : Colors.white,
                          fontSize: 12.sp),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 3.5.h,
                        color: AddSettingsData.themeValue == 2
                            ? const Color(0xff1C1C1C)
                            : Colors.white)),
              ),
              SizedBox(
                height: 3.h,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(1.h),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AddSettingsData.themeValue == 2
                      ? const Color(0xffEBEBEB)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const BillingScreen(
                            hitLimit: false,
                          ),
                        )),
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xff463A47),
                          borderRadius: BorderRadius.circular(1.h)),
                      padding: EdgeInsets.only(
                          top: 1.25.h, bottom: 2.h, left: 2.w, right: 2.w),
                      child: Icon(Icons.account_balance,
                          color: Colors.white, size: 3.5.h),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.settings_subscription,
                      style: TextStyle(
                          color: AddSettingsData.themeValue == 2
                              ? const Color(0xff1C1C1C)
                              : Colors.white,
                          fontSize: 12.sp),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 3.5.h,
                        color: AddSettingsData.themeValue == 2
                            ? const Color(0xff1C1C1C)
                            : Colors.white)),
              ),
              SizedBox(
                height: 3.h,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(1.h),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AddSettingsData.themeValue == 2
                      ? const Color(0xffEBEBEB)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ContactFeedbackScreen(),
                        )),
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xff47463A),
                          borderRadius: BorderRadius.circular(1.h)),
                      padding: EdgeInsets.only(
                          top: 1.25.h, bottom: 2.h, left: 2.w, right: 2.w),
                      child: Icon(Icons.contact_support,
                          color: Colors.white, size: 3.5.h),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.settings_contactUs,
                      style: TextStyle(
                          color: AddSettingsData.themeValue == 2
                              ? const Color(0xff1C1C1C)
                              : Colors.white,
                          fontSize: 12.sp),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 3.5.h,
                        color: AddSettingsData.themeValue == 2
                            ? const Color(0xff1C1C1C)
                            : Colors.white)),
              ),
              SizedBox(
                height: 3.h,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(1.h),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AddSettingsData.themeValue == 2
                      ? const Color(0xffEBEBEB)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const FeedbackPageScreen(),
                        )),
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xff47463A),
                          borderRadius: BorderRadius.circular(1.h)),
                      padding: EdgeInsets.only(
                          top: 1.25.h, bottom: 2.h, left: 2.w, right: 2.w),
                      child: Icon(Icons.feedback_rounded,
                          color: Colors.white, size: 3.5.h),
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.settings_feedback,
                      style: TextStyle(
                          color: AddSettingsData.themeValue == 2
                              ? const Color(0xff1C1C1C)
                              : Colors.white,
                          fontSize: 12.sp),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 3.5.h,
                        color: AddSettingsData.themeValue == 2
                            ? const Color(0xff1C1C1C)
                            : Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
