import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:huntfishai/api_collection/dio_api_method.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../huntfishAiSettingsData.dart';

class ContactFeedbackScreen extends StatefulWidget {
  const ContactFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<ContactFeedbackScreen> createState() => _ContactFeedbackScreenState();
}

class _ContactFeedbackScreenState extends State<ContactFeedbackScreen> {
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
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
          AppLocalizations.of(context)!.contactUs_appBarTitle,
          style: TextStyle(
            color:
                AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 28.h,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  height: 18.h,
                  margin: EdgeInsets.only(left: 4.w, right: 4.w, top: 8.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.h),
                    color: AddSettingsData.themeValue == 2
                        ? const Color(0xffEBEBEB)
                        : AddSettingsData.themeValue == 1
                            ? const Color(0xff212457)
                            : const Color(0xff323232),
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: TextButton(
                        onPressed: () async {
                          final emailAddress = Uri(
                              scheme: 'mailto',
                              path: 'team@huntfish.ai',
                              query: encodeQueryParameters(<String, String>{
                                'subject':
                                    'Question regarding HuntfFish.ai App!'
                              }));
                          if (await canLaunchUrl(emailAddress)) {
                            launchUrl(emailAddress);
                          } else {
                            DioClient.get().toAst("can't send email!");
                          }
                        },
                        child: Text(
                          "team@huntfish.ai",
                          style: TextStyle(
                            color: AddSettingsData.themeValue == 2
                                ? Colors.black
                                : Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 1.h),
                width: double.infinity,
                child: CircleAvatar(
                  radius: 7.6.h,
                  backgroundColor: AddSettingsData.themeValue == 2
                      ? Colors.white
                      : AddSettingsData.themeValue == 1
                          ? const Color(0xff000221)
                          : Colors.black,
                  child: CircleAvatar(
                    radius: 6.h,
                    backgroundColor: const Color(0xffFFCE3C),
                    child: Padding(
                      padding: EdgeInsets.all(2.5.h),
                      child: Image.asset("assets/images/mesage.png"),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 4.h,
          ),
          Stack(
            children: [
              SizedBox(
                height: 28.h,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  height: 18.h,
                  margin: EdgeInsets.only(left: 4.w, right: 4.w, top: 8.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.h),
                    color: AddSettingsData.themeValue == 2
                        ? const Color(0xffEBEBEB)
                        : AddSettingsData.themeValue == 1
                            ? const Color(0xff212457)
                            : const Color(0xff323232),
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: TextButton(
                        onPressed: () async {
                          final telNumber = Uri.parse('tel:+18646014834');
                          if (await canLaunchUrl(telNumber)) {
                            launchUrl(telNumber);
                          } else {
                            DioClient.get().toAst("can't make call!");
                          }
                        },
                        child: Text(
                          "864-601-4834",
                          style: TextStyle(
                            color: AddSettingsData.themeValue == 2
                                ? Colors.black
                                : Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 1.h),
                width: double.infinity,
                child: CircleAvatar(
                  radius: 7.6.h,
                  backgroundColor: AddSettingsData.themeValue == 2
                      ? Colors.white
                      : AddSettingsData.themeValue == 1
                          ? const Color(0xff000221)
                          : Colors.black,
                  child: CircleAvatar(
                    radius: 6.h,
                    backgroundColor: const Color(0xffFFCE3C),
                    child: Padding(
                      padding: EdgeInsets.all(2.5.h),
                      child: Image.asset("assets/images/phn.png"),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 4.h,
          ),
          Center(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            InkWell(
                onTap: () =>
                    launchUrl(Uri.parse("https://www.huntfish.ai/privacy-tos")),
                child: Text(AppLocalizations.of(context)!.tos,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline))),
            const SizedBox(width: 20),
            InkWell(
                onTap: () =>
                    launchUrl(Uri.parse("https://www.huntfish.ai/privacy-tos")),
                child: Text(AppLocalizations.of(context)!.privacy,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline))),
          ])),
        ],
      ),
    );
  }
}
