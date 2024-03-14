import 'dart:async';
import 'package:flutter/material.dart';
import 'package:huntfishai/apiModel/createRoom/CreateRoomResponse.dart';
import 'package:sizer/sizer.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../../constants/constants.dart';
import '../../models/feature/feature_data.dart';
import '../Login/LoginScreen.dart';
import '../chatbot/chatbot.dart';
import '../huntfishAiSettingsData.dart';

class ChooseScreen extends StatefulWidget {
  final bool? isBrook;
  final FeatureData? data;

  const ChooseScreen({Key? key, this.data, this.isBrook}) : super(key: key);

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  CreateRoomResponse createRoomResponse = CreateRoomResponse();

  int roomId = 0;

  bool isLoading = false;

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
    return Scaffold(
        backgroundColor: AddSettingsData.themeValue == 2
            ? Colors.white
            : const Color(0xff1C1C1C),
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: const Color(0xff1C1C1C),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AddSettingsData.themeValue == 2
                      ? const AssetImage("assets/images/whitequestion.png")
                      : const AssetImage("assets/images/bg.png"))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 6.2.h,
                    width: 12.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.5.w),
                        color: const Color(0xff323232)),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 3.5.h,
                    ),
                  ),
                ),
                isLoading == true
                    ? Center(
                        child: Padding(
                            padding: EdgeInsets.only(top: 40.h),
                            child: const CircularProgressIndicator(
                                color: Color(0xffFFCE3C))))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            SizedBox(
                              height: 4.h,
                            ),
                            Text(
                              "Choose your",
                              style: TextStyle(
                                  color: AddSettingsData.themeValue == 2
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 0.5.h,
                            ),
                            Text(
                              "Guide",
                              style: TextStyle(
                                  color: const Color(0xffFFCE3C),
                                  fontSize: 27.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4.h),
                            GestureDetector(
                              onTap: () {
                                createRoom(true);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2.5.w),
                                child: Container(
                                  height: 30.h,
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(2.5.w),
                                      color: const Color(0xff303030)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 24.h,
                                            width: 35.w,
                                            decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: AssetImage(
                                                        "assets/images/brook.png"))),
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Guide: Brook",
                                                style: TextStyle(
                                                    color:
                                                        const Color(0xffFFFFFF),
                                                    fontSize: 18.sp,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              SizedBox(
                                                  height: 15.h,
                                                  width: 50.w,
                                                  child: SingleChildScrollView(
                                                      child: Text(
                                                    "AI enhanced Brook is quite the outdoorswoman!    She excels at helping beginners and experts alike ensuring your outdoor trip is fun, memorable and safe! ",
                                                    style: TextStyle(
                                                        color: const Color(
                                                            0xffFFFFFF),
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ))),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        color: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w),
                                        height: 6.h,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Ask me a question!",
                                              style: TextStyle(
                                                  color:
                                                      const Color(0xff1F1F1F),
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 5.h,
                                              color: const Color(0xff1F1F1F),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            GestureDetector(
                              onTap: () {
                                createRoom(false);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2.5.w),
                                child: Container(
                                  height: 30.h,
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(2.5.w),
                                      color: const Color(0xff303030)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 24.h,
                                            width: 35.w,
                                            decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: AssetImage(
                                                        "assets/images/joey.png"))),
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Guide: Joe",
                                                style: TextStyle(
                                                    color:
                                                        const Color(0xffFFFFFF),
                                                    fontSize: 18.sp,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              SizedBox(
                                                  height: 15.h,
                                                  width: 50.w,
                                                  child: SingleChildScrollView(
                                                      child: Text(
                                                    "AI enhanced Joe is a world traveled outdoorsmen.   DIY & Guided excursions from Argentina to Alaska and from the Gulf Stream to a tiny creek, he’s done it all.   ",
                                                    style: TextStyle(
                                                        color: const Color(
                                                            0xffFFFFFF),
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ))),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        color: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w),
                                        height: 6.h,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Ask me a question!",
                                              style: TextStyle(
                                                  color:
                                                      const Color(0xff1F1F1F),
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 5.h,
                                              color: const Color(0xff1F1F1F),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ])
              ],
            ),
          ),
        ));
  }
}
