import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:huntfishai/screen/AISettingsScreen.dart';
import 'package:huntfishai/screen/Setting.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../apiModel/UpdateTheme/updateThemeResponse.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../Wlcome/welcomeScreen.dart';
import '../huntfishAiSettingsData.dart';

class BackgroundThemeScreen extends StatefulWidget {
  const BackgroundThemeScreen({Key? key}) : super(key: key);

  @override
  State<BackgroundThemeScreen> createState() => _BackgroundThemeScreenState();
}

class _BackgroundThemeScreenState extends State<BackgroundThemeScreen> {
  bool isGrayChecked = false;
  bool isBlueChecked = false;
  bool isWhiteChecked = false;
  @override
  void initState() {
    isGrayChecked = AddSettingsData.themeValue == 0 ? true : false;
    isBlueChecked = AddSettingsData.themeValue == 1 ? true : false;
    isWhiteChecked = AddSettingsData.themeValue == 2 ? true : false;

    super.initState();
  }

  int? themeValue;
  UpdateThemeResponse updateThemeResponse = UpdateThemeResponse();
  void updateThemeApi(value) async {
    var response = await DioClient.get()
        .dioGetMethod("${ApiUrl.updateTheme}?theme=$value");
    updateThemeResponse =
        UpdateThemeResponse.fromJson(jsonDecode(response.toString()));
    if (updateThemeResponse.code == 200) {
      AddSettingsData.themeValue =
          int.parse(updateThemeResponse.body.toString());
      print("valueeee::::::::${AddSettingsData.themeValue}");

      Navigator.of(context).pop();
    }
    setState(() {});
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
                color: Color.fromRGBO(50, 50, 50, 1)),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 3.h,
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.theme_appBarTitle,
          style: TextStyle(
            color:
                AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(1.h),
            margin: EdgeInsets.symmetric(
              horizontal: 4.w,
            ),
            decoration: BoxDecoration(
              color: AddSettingsData.themeValue == 2
                  ? const Color(0xffEBEBEB)
                  : const Color(0x0fffffff).withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 15.w,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(1.h),
                    border: Border.all(color: Colors.white)),
              ),
              title: Text(
                AppLocalizations.of(context)!.theme_darkGray,
                style: TextStyle(
                    color: AddSettingsData.themeValue == 2
                        ? Colors.black
                        : Colors.white,
                    fontSize: 12.sp),
              ),
              trailing: Transform.scale(
                scale: 1.5, // Increase the size of the checkbox
                child: Checkbox(
                  value: isGrayChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isGrayChecked = value!;
                      isBlueChecked = false;
                      isWhiteChecked = false;
                      AddSettingsData.themeValue = 0;
                    });
                  },
                  activeColor:
                      const Color(0xffFFCE3C), // Color when checkbox is checked
                  checkColor: Colors.black, // Color of the check icon
                  side: const BorderSide(color: Color(0xffFFCE3C), width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        4.0), // Adjust the border radius as needed
                    side: const BorderSide(
                        color: Colors.yellow,
                        width: 2.0), // Border color and width
                  ),
                ),
              ),
            ),
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
                  : const Color(0x0fffffff).withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 15.w,
                decoration: BoxDecoration(
                    color: const Color(0xff000221),
                    borderRadius: BorderRadius.circular(1.h),
                    border: Border.all(color: Colors.white)),
              ),
              title: Text(
                AppLocalizations.of(context)!.theme_blue,
                style: TextStyle(
                    color: AddSettingsData.themeValue == 2
                        ? Colors.black
                        : Colors.white,
                    fontSize: 12.sp),
              ),
              trailing: Transform.scale(
                scale: 1.5, // Increase the size of the checkbox
                child: Checkbox(
                  value: isBlueChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isBlueChecked = value!;
                      isWhiteChecked = false;
                      isGrayChecked = false;
                      AddSettingsData.themeValue = 1;
                    });
                  },
                  activeColor:
                      const Color(0xffFFCE3C), // Color when checkbox is checked
                  checkColor: Colors.black, // Color of the check icon
                  side: const BorderSide(color: Color(0xffFFCE3C), width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        4.0), // Adjust the border radius as needed
                    side: const BorderSide(
                        color: Colors.yellow,
                        width: 2.0), // Border color and width
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Padding(
            padding: EdgeInsets.only(top: 45.h),
            child: GestureDetector(
              onTap: () {
                if (isGrayChecked == true) {
                  themeValue = 0;
                  print("grayapplied");
                  print("value:::::$themeValue");
                } else if (isBlueChecked == true) {
                  themeValue = 1;
                  print("value:::::$themeValue");
                  print("blueapplied");
                } else if (isWhiteChecked == true) {
                  themeValue = 2;
                  print("value:::::$themeValue");
                }
                updateThemeApi(themeValue);
              },
              child: Container(
                  width: double.maxFinite,
                  height: 7.h,
                  margin: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 10.h),
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
                        color: Color.fromRGBO(255, 206, 60, 1),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff1F1F1F),
                            decoration: TextDecoration.none),
                      ))),
            ),
          ),
        ],
      ),
    );
  }
}
