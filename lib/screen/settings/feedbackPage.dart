// ignore: file_names
import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:huntfishai/apiModel/applicationFeedback/applicationFeedbackRequest.dart';
import 'package:huntfishai/apiModel/applicationFeedback/applicationFeedbackResponse.dart';
import 'package:huntfishai/api_collection/api_url_collection.dart';
import 'package:huntfishai/api_collection/dio_api_method.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../huntfishAiSettingsData.dart';

class FeedbackPageScreen extends StatefulWidget {
  const FeedbackPageScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackPageScreen> createState() => _FeedbackPageScreenState();
}

class _FeedbackPageScreenState extends State<FeedbackPageScreen> {
  late ConfettiController _controllerCenter;
  late ConfettiController _controllerCenterRight;
  late ConfettiController _controllerCenterLeft;
  late ConfettiController _controllerTopCenter;
  late ConfettiController _controllerBottomCenter;

  bool submitVisible = true;
  double? ratingBarValue = 0.0;
  final textEditingController = TextEditingController();
  ApplicationFeedbackResponse applicationFeedbackResponse =
      ApplicationFeedbackResponse();
  final textScrollKey = GlobalKey();

  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 4));
    _controllerCenterRight =
        ConfettiController(duration: const Duration(seconds: 4));
    _controllerCenterLeft =
        ConfettiController(duration: const Duration(seconds: 4));
    _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 4));
    _controllerBottomCenter =
        ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _controllerCenter.dispose();
    _controllerCenterRight.dispose();
    _controllerCenterLeft.dispose();
    _controllerTopCenter.dispose();
    _controllerBottomCenter.dispose();
    super.dispose();
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  submitFeedback(String? starRating, String? feedback) async {
    try {
      final request = ApplicationFeedbackRequest(
          starRating: starRating, feedback: feedback);
      var response = await DioClient.get()
          .dioPostMethod(ApiUrl.applicationFeedback, request);

      applicationFeedbackResponse =
          ApplicationFeedbackResponse.fromJson(response.data);

      if (applicationFeedbackResponse.code == 200) {
        DioClient.get().toAst('Thanks for your feedback!');
        submitVisible = false;
        textEditingController.text = "";
        ratingBarValue = 0.0;
        setState(() {});
        Navigator.of(context).pop();
      }
    } catch (e) {
      Timer(const Duration(seconds: 1), () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
                      color: const Color(0xff323232)),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 3.h,
                  ),
                ),
              ),
              title: Text(
                AppLocalizations.of(context)!.feedback_appBarTitle,
                style: TextStyle(
                  color: AddSettingsData.themeValue == 2
                      ? Colors.black
                      : Colors.white,
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
                // SizedBox(height: 3.h),
                Stack(
                  children: [
                    Image.asset(
                      "assets/images/feedback.jpg",
                      height: 25.h,
                      fit: BoxFit.fitWidth,
                      width: double.maxFinite,
                      alignment: Alignment.centerRight,
                    ),
                    Positioned(
                        left: 4.w,
                        top: 21.h,
                        child: Text(
                          AppLocalizations.of(context)!.feedback_headerText,
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                              // ignore: prefer_const_literals_to_create_immutables
                              shadows: [
                                const Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 0,
                                )
                              ]),
                        )),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(AppLocalizations.of(context)!.feedback_rateUs,
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
                SizedBox(height: 2.h),
                Align(
                  alignment: Alignment.center,
                  child: ConfettiWidget(
                    confettiController: _controllerCenter,
                    blastDirectionality: BlastDirectionality
                        .explosive, // don't specify a direction, blast randomly
                    shouldLoop:
                        false, // start again as soon as the animation is finished
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ], // manually specify the colors to be used
                    createParticlePath: drawStar, // define a custom shape/path.
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: const AlignmentDirectional(0.00, 0.00),
                        child: RatingBar.builder(
                          onRatingUpdate: (newValue) {
                            setState(() => ratingBarValue = newValue);
                            if (newValue > 3.0) {
                              _controllerCenter.play();
                            }
                          },
                          itemBuilder: (context, index) => Icon(
                            Icons.star_rounded,
                            color: Colors.yellow.shade600,
                          ),
                          direction: Axis.horizontal,
                          initialRating: ratingBarValue ??= 3.0,
                          unratedColor: Colors.grey.shade800,
                          itemCount: 5,
                          itemSize: 60.0,
                          glowColor: Colors.lime.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                          AppLocalizations.of(context)!.feedback_additional,
                          style: const TextStyle(color: Colors.white)),
                    )
                  ],
                ),
                SizedBox(height: 2.h),
                Wrap(children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: TextFormField(
                        onTap: () {
                          Scrollable.ensureVisible(
                              textScrollKey.currentContext!);
                        },
                        keyboardType: TextInputType.text,
                        maxLines: 8,
                        controller: textEditingController,
                        style: TextStyle(
                          color: Colors.grey.shade300,
                        ),
                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2.0,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            border: OutlineInputBorder()),
                      ))
                ]),
                SizedBox(height: 2.h),
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Visibility(
                      visible: submitVisible,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            submitVisible = false;
                          });

                          if (ratingBarValue == 0.0 &&
                              textEditingController.text == "") {
                            DioClient.get().toAst(
                                'Please at least fill in one feedback option!');
                          } else if (ratingBarValue == 0.0 &&
                              textEditingController.text != "") {
                            submitFeedback(ratingBarValue.toString(),
                                textEditingController.text);
                          } else {
                            submitFeedback(ratingBarValue.toString(),
                                textEditingController.text);
                          }
                        },
                        child: Container(
                            key: textScrollKey,
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
                                  AppLocalizations.of(context)!
                                      .feedback_sendFeedback,
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xff1F1F1F),
                                      decoration: TextDecoration.none),
                                ))),
                      ));
                }),
              ]))),
            )));
  }
}
