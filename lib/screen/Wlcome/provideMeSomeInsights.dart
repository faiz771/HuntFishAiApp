import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as places;
import 'package:huntfishai/apiModel/getList/getListResponse.dart';
import 'package:huntfishai/apiModel/setProfile/setProfileRequest.dart';
import 'package:huntfishai/screen/Wlcome/welcomeScreen.dart';
import 'package:huntfishai/screen/helperModel/addLocationHelperModel.dart';
import 'package:multiselect/multiselect.dart';
import '../../apiModel/setProfile/setProfileResponse.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../Login/LoginScreen.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../huntfishAiSettingsData.dart';
import '../../models/feature/feature_data.dart';

class ProvideMeInsights extends StatefulWidget {
  String? name;
  bool? isBrook;
  final FeatureData? data;
  ProvideMeInsights({Key? key, this.data, this.isBrook, this.name})
      : super(key: key);

  @override
  State<ProvideMeInsights> createState() => _ProvideMeInsightsState();
}

class _ProvideMeInsightsState extends State<ProvideMeInsights> {
  final insightsFormKey = GlobalKey<FormState>();
  bool userInteraction = false;
  bool isLoading = false;
  SetYourProfileResponse setYourProfileResponse = SetYourProfileResponse();
  late FocusNode fnLocation;
  late places.GooglePlace googlePlace;
  List<places.AutocompletePrediction> predictions = [];
  bool isPlaceListVisible = false;
  bool isDestinationSelected = false;

  List<String> masterInterestList = [];
  List<String> interestSelected = [];

  List<String> masterEquipmentList = [];
  List<String> equipmentSelected = [];

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      predictions = result.predictions!;
      setState(() {});
      log('async');
    }
  }

  //interestApi
  GetListResponse getinterestListResponse = GetListResponse();
  void getInterestApi() async {
    var response =
        await DioClient.get().dioGetMethod("${ApiUrl.allList}?type=3");
    getinterestListResponse =
        GetListResponse.fromJson(jsonDecode(response.toString()));
    print("interstList${getinterestListResponse.body}");

    var body = getinterestListResponse.toJson();
    for (var x in body['body']) {
      masterInterestList.add(x['name']);
    }
    setState(() {});
  }

  //experienceApi
  GetListResponse getExperienceListResponse = GetListResponse();
  void getExperienceApi() async {
    var response =
        await DioClient.get().dioGetMethod("${ApiUrl.allList}?type=2");
    getExperienceListResponse =
        GetListResponse.fromJson(jsonDecode(response.toString()));
    print("ExperienceList${getExperienceListResponse.body}");
    setState(() {});
  }

  //equipmentApi
  GetListResponse getEquipmentListResponse = GetListResponse();
  void getEquipmentApi() async {
    var response =
        await DioClient.get().dioGetMethod("${ApiUrl.allList}?type=1");
    getEquipmentListResponse =
        GetListResponse.fromJson(jsonDecode(response.toString()));
    print("ExperienceList${getEquipmentListResponse.body}");
    var body = getEquipmentListResponse.toJson();
    for (var x in body['body']) {
      masterEquipmentList.add(x['name']);
    }
    setState(() {});
  }

  //RegulatoryApi
  GetListResponse getRegulatoryListResponse = GetListResponse();
  void getRegulatoryApi() async {
    var response =
        await DioClient.get().dioGetMethod("${ApiUrl.allList}?type=5");
    getRegulatoryListResponse =
        GetListResponse.fromJson(jsonDecode(response.toString()));
    print("ExperienceList${getRegulatoryListResponse.body}");
    setState(() {});
  }

  //physicalCapabiltyApi
  GetListResponse getPhysicalCapabiltyResponse = GetListResponse();
  void getphysicalCapabiltyApi() async {
    var response =
        await DioClient.get().dioGetMethod("${ApiUrl.allList}?type=4");
    getPhysicalCapabiltyResponse =
        GetListResponse.fromJson(jsonDecode(response.toString()));
    print("ExperienceList${getPhysicalCapabiltyResponse.body}");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getInterestApi();
    getExperienceApi();
    getEquipmentApi();
    getphysicalCapabiltyApi();
    getRegulatoryApi();
    print("hii${AddLocationData.geographicName}");
    googlePlace = places.GooglePlace("AIzaSyCrPOCUEMHoOXOacOtMkuQxSbSE1lYzpFA");
    fnLocation = FocusNode();
  }

  bool isExperience = false;
  bool isinterest = false;
  bool isEquipment = false;
  bool isPrefrences = false;
  bool isRegulation = false;
  bool isCapability = false;
  bool isSeason = false;
  int activeStep = 0;
  final experienceController = TextEditingController();
  final interertController = TextEditingController();
  final locationController = TextEditingController(
      text: AddLocationData.geographicName ?? "Your Location");
  final equipController = TextEditingController();
  final prefController = TextEditingController();
  final regulController = TextEditingController();
  final seasonController = TextEditingController();
  final capabilityController = TextEditingController();

  //Api
  setProfileApi() async {
    try {
      final request = SetYourProfileRequest(
        full_name: widget.name,
        equipment: equipmentSelected
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', ''),
        experience: experienceController.text,
        intrests:
            interestSelected.toString().replaceAll('[', '').replaceAll(']', ''),
        latitude: locationController.text.isEmpty == true
            ? AddLocationData.pickupLat.toString()
            : AddLocationData.currentPosition?.latitude.toString(),
        longitude: locationController.text.isEmpty == true
            ? AddLocationData.pickupLng.toString()
            : AddLocationData.currentPosition?.longitude.toString(),
        location: locationController.text,
        physicalCapabilities: capabilityController.text,
        preferences: prefController.text,
        regulatoryUnderstanding: regulController.text,
      );
      print("request---->${request.toJson()}");
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.setProfile, request);
      setYourProfileResponse = SetYourProfileResponse.fromJson(response.data);
      if (setYourProfileResponse.code == 200) {
        isLoading = false;
        AddSettingsData.experience = experienceController.text;
        AddSettingsData.location = locationController.text;
        AddSettingsData.equipment = equipmentSelected
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', '');
        AddSettingsData.preferences = prefController.text;
        AddSettingsData.regulations = regulController.text;
        if (AddSettingsData.experience?.isNotEmpty == true) {
          AddSettingsData.experience =
              "my experience level is ${AddSettingsData.experience}";
        }
        if (AddSettingsData.location?.isNotEmpty == true) {
          AddSettingsData.location =
              ", i live near ${AddSettingsData.location}";
        }
        if (AddSettingsData.equipment?.isNotEmpty == true) {
          AddSettingsData.equipment =
              ", i prefer using ${AddSettingsData.equipment} but it is not required";
        }
        if (AddSettingsData.interests?.isNotEmpty == true) {
          AddSettingsData.interests =
              ", i have interest in ${AddSettingsData.interests} but it is not required";
        }
        if (AddSettingsData.preferences?.isNotEmpty == true) {
          AddSettingsData.preferences =
              ", and you should know ${AddSettingsData.preferences}";
        }
        if (AddSettingsData.regulations?.isNotEmpty == true) {
          AddSettingsData.regulations =
              ", my regulation understandings are ${AddSettingsData.regulations} level.";
        }
        AddSettingsData.finalQuestion =
            "my name is ${widget.name} and ${AddSettingsData.experience ?? ""}${AddSettingsData.location ?? ""}${AddSettingsData.equipment ?? ""}${AddSettingsData.interests ?? ""}${AddSettingsData.preferences ?? ""}${AddSettingsData.regulations ?? ""}";
        print("finalQuestion------>${AddSettingsData.finalQuestion}");
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => WelcomeScreen(
                  data: widget.data,
                  isBrook: widget.isBrook,
                )));
        setState(() {});
      } else if (setYourProfileResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        DioClient.get().toAst(setYourProfileResponse.message.toString());
        isLoading = false;
        setState(() {});
      } else {
        DioClient.get().toAst(setYourProfileResponse.message.toString());
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: AddSettingsData.themeValue == 2
              ? Colors.white
              : const Color(0xff1C1C1C),
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            padding: EdgeInsets.only(top: 4.h, left: 3.w, right: 3.w),
            decoration: BoxDecoration(
                color: const Color(0xff1C1C1C),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AddSettingsData.themeValue == 2
                        ? const AssetImage("assets/images/whitequestion.png")
                        : AddSettingsData.themeValue == 1
                            ? const AssetImage("assets/images/bg_blue.png")
                            : const AssetImage("assets/images/questions.png"))),
            child: Form(
              key: insightsFormKey,
              autovalidateMode: userInteraction == true
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height - 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 1.h,
                          ),
                          GestureDetector(
                            onTap: () {
                              activeStep == 0
                                  ? SystemNavigator.pop()
                                  : activeStep--;
                              setState(() {});
                            },
                            child: Container(
                              height: 6.2.h,
                              width: 12.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.5.w),
                                color: AddSettingsData.themeValue == 1
                                    ? Colors.white.withOpacity(0.10)
                                    : const Color(0xff1C1C1C),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 3.5.h,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          Text(
                            AppLocalizations.of(context)!.train_trainYourAI,
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
                            AppLocalizations.of(context)!
                                .train_activeStep(activeStep + 1),
                            style: TextStyle(
                                color: const Color(0xffFFCE3C),
                                fontSize: 27.sp,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 3.5.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 1.3.h),
                            child: SizedBox(
                              height: 6.h,
                              child: ListView.builder(
                                itemCount: 6,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 3.5.w,
                                          height: 3.5.h,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: activeStep < index
                                                    ? const Color(0xff9E9B9B)
                                                    : const Color(0xffFFCE3C),
                                              ),
                                              color: activeStep < index + 1
                                                  ? Colors.transparent
                                                  : const Color(0xffFFCE3C)),
                                        ),
                                        Text("  ${index + 1}",
                                            style: TextStyle(
                                                fontSize: 6.sp,
                                                color: activeStep < index
                                                    ? const Color(0xff9E9B9B)
                                                    : AddSettingsData
                                                                .themeValue ==
                                                            2
                                                        ? Colors.black
                                                        : Colors.white))
                                      ],
                                    ),
                                    index < 5
                                        ? Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 1.2.h),
                                            child: Container(
                                              height: 0.3.h,
                                              width: 13.5.w,
                                              decoration: BoxDecoration(
                                                  color: activeStep < index + 1
                                                      ? const Color(0xff9E9B9B)
                                                      : const Color(0xffFFCE3C),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1.h)),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          activeStep == 0
                              ? question1()
                              : activeStep == 1
                                  ? question2()
                                  : activeStep == 2
                                      ? question3()
                                      : activeStep == 3
                                          ? question4()
                                          : activeStep == 4
                                              ? question5()
                                              : activeStep == 5
                                                  ? question6()
                                                  //    : activeStep == 6 ? question7()
                                                  //     : activeStep==7?  question8()
                                                  : const SizedBox.shrink(),
                        ],
                      ),
                      activeStep == 5 ? submitButton() : nextButton(),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget question4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.train_outdoorInterests,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color:
                AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Center(
            child: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: DropDownMultiSelect(
            onChanged: (List<String> x) {
              setState(() {
                interestSelected = x;
              });
            },
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                  color: Color(0xffADADAD), fontStyle: FontStyle.italic),
              fillColor: AddSettingsData.themeValue == 2
                  ? const Color(0xffEBEBEB)
                  : AddSettingsData.themeValue == 1
                      ? Colors.white.withOpacity(0.10)
                      : const Color(0xff323232),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            selected_values_style: const TextStyle(
                color: Color(0xffADADAD), fontStyle: FontStyle.italic),
            options: masterInterestList,
            selectedValues: interestSelected,
            whenEmpty: 'Select Interests',
          ),
        )),
      ],
    );
  }

  Widget question1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.train_outdoorExperience,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color:
                AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          onTap: () {
            isExperience = !isExperience;
            setState(() {});
          },
          readOnly: true,
          style: TextStyle(
              color: AddSettingsData.themeValue == 2
                  ? const Color(0xffADADAD)
                  : Colors.white60),
          cursorColor: AddSettingsData.themeValue == 2
              ? const Color(0xffADADAD)
              : Colors.white60,
          controller: experienceController,
          decoration: InputDecoration(
            suffixIcon: isExperience
                ? Icon(
                    Icons.keyboard_arrow_up_outlined,
                    color: Colors.white.withOpacity(0.60),
                    size: 3.h,
                  )
                : Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: Colors.white.withOpacity(0.60),
                    size: 3.h,
                  ),
            hintText: AppLocalizations.of(context)!.insights_outdoorExpHint,
            hintStyle: const TextStyle(
                color: Color(0xffADADAD), fontStyle: FontStyle.italic),
            fillColor: AddSettingsData.themeValue == 2
                ? const Color(0xffEBEBEB)
                : AddSettingsData.themeValue == 1
                    ? Colors.white.withOpacity(0.10)
                    : const Color(0xff323232),
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        Visibility(
          visible: isExperience,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 0.5.h),
            color: AddSettingsData.themeValue == 2
                ? const Color(0xffEBEBEB)
                : AddSettingsData.themeValue == 1
                    ? Colors.white.withOpacity(0.10)
                    : Colors.grey.shade800,
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 0.0),
                shrinkWrap: true,
                itemCount: getExperienceListResponse.body?.length ?? 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      getExperienceListResponse.body?[index].name ?? "",
                      style: TextStyle(color: Colors.white.withOpacity(0.60)),
                    ),
                    onTap: () {
                      setState(() {
                        experienceController.text =
                            getExperienceListResponse.body?[index].name ?? "";
                        isExperience = false;
                      });
                    },
                  );
                }),
          ),
        ),
        isExperience == true
            ? const SizedBox.shrink()
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Text(
                  AppLocalizations.of(context)!.train_reasonWhy,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.35,
                    fontWeight: FontWeight.bold,
                    color: AddSettingsData.themeValue == 2
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
        SizedBox(
          height: 0.5.h,
        ),
      ],
    );
  }

  Widget question2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.train_currentLocation,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color:
                AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          style: TextStyle(
              color: AddSettingsData.themeValue == 2
                  ? const Color(0xffADADAD)
                  : Colors.white60),
          cursorColor: AddSettingsData.themeValue == 2
              ? const Color(0xffADADAD)
              : Colors.white60,
          textInputAction: TextInputAction.done,
          controller: locationController,
          onChanged: (text) {
            log('confirm text field: $text');
            autoCompleteSearch(text);
            if (text.isEmpty) {
              isPlaceListVisible = false;
            } else {
              isPlaceListVisible = true;
            }
            setState(() {});
          },
          decoration: InputDecoration(
            suffixIcon: Icon(
              Icons.location_on,
              color: Colors.white,
              size: 3.h,
            ),
            hintText: AppLocalizations.of(context)!.insights_locationHint,
            hintStyle: const TextStyle(
                color: Color(0xffADADAD), fontStyle: FontStyle.italic),
            fillColor: AddSettingsData.themeValue == 2
                ? const Color(0xffEBEBEB)
                : AddSettingsData.themeValue == 1
                    ? Colors.white.withOpacity(0.10)
                    : const Color(0xff323232),
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        Visibility(
          visible: isPlaceListVisible,
          child: Container(
            color: AddSettingsData.themeValue == 2
                ? const Color(0xffEBEBEB)
                : AddSettingsData.themeValue == 1
                    ? Colors.white.withOpacity(0.10)
                    : Colors.grey.shade800,
            height: 30.h,
            width: double.maxFinite,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      predictions[index].description.toString(),
                      style: TextStyle(
                          color: AddSettingsData.themeValue == 2
                              ? Colors.white
                              : const Color(0xffADADAD)),
                    ),
                    onTap: () async {
                      final placeId = predictions[index].placeId!;
                      final details = await googlePlace.details.get(placeId);
                      if (details != null && details.result != null) {
                        locationController.text =
                            details.result!.formattedAddress!;
                        AddLocationData.insightName =
                            details.result!.formattedAddress!;
                        AddLocationData.pickupLat =
                            details.result!.geometry!.location!.lat!;
                        AddLocationData.pickupLng =
                            details.result!.geometry!.location!.lng!;
                        isLatLoading = false;
                        AddLocationData.selectedPosition = LatLng(
                            details.result!.geometry!.location!.lat!,
                            details.result!.geometry!.location!.lng!);
                        isPlaceListVisible = false;
                        log(locationController.text);
                        log(locationController.text);
                        log(AddLocationData.pickupLat.toString());
                        log(AddLocationData.pickupLng.toString());
                        isDestinationSelected = true;
                        setState(() {});
                      }
                    },
                  );
                }),
          ),
        ),
      ],
    );
  }

  bool isLatLoading = true;

  Widget question3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.insights_preferredEquip,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color:
                AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Center(
            child: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: DropDownMultiSelect(
            onChanged: (List<String> x) {
              setState(() {
                equipmentSelected = x;
              });
            },
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                  color: Color(0xffADADAD), fontStyle: FontStyle.italic),
              fillColor: AddSettingsData.themeValue == 2
                  ? const Color(0xffEBEBEB)
                  : AddSettingsData.themeValue == 1
                      ? Colors.white.withOpacity(0.10)
                      : const Color(0xff323232),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            selected_values_style: const TextStyle(
                color: Color(0xffADADAD), fontStyle: FontStyle.italic),
            options: masterEquipmentList,
            selectedValues: equipmentSelected,
            whenEmpty:
                AppLocalizations.of(context)!.insights_preferredEquipHint,
          ),
        )),
      ],
    );
  }

  Widget question6() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.insights_additional,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color:
                  AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          TextFormField(
            // onTap: (){
            //   isPrefrences=!isPrefrences;
            //   setState(() {});
            //
            // },
            //readOnly: true,
            style: TextStyle(
                color: AddSettingsData.themeValue == 2
                    ? const Color(0xffADADAD)
                    : Colors.white60),
            cursorColor: AddSettingsData.themeValue == 2
                ? const Color(0xffADADAD)
                : Colors.white60,
            controller: prefController,
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                  color: Color(0xffADADAD), fontStyle: FontStyle.italic),
              fillColor: AddSettingsData.themeValue == 2
                  ? const Color(0xffEBEBEB)
                  : AddSettingsData.themeValue == 1
                      ? Colors.white.withOpacity(0.10)
                      : const Color(0xff323232),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              AppLocalizations.of(context)!.train_additionalHint,
              style: TextStyle(
                fontSize: 12.sp,
                height: 2,
                fontWeight: FontWeight.bold,
                color: AddSettingsData.themeValue == 2
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget question5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.train_outdoorRegulations,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color:
                AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          onTap: () {
            isRegulation = !isRegulation;
            setState(() {});
          },
          readOnly: true,
          style: TextStyle(
              color: AddSettingsData.themeValue == 2
                  ? const Color(0xffADADAD)
                  : Colors.white60),
          cursorColor: AddSettingsData.themeValue == 2
              ? const Color(0xffADADAD)
              : Colors.white60,
          controller: regulController,
          decoration: InputDecoration(
            suffixIcon: isRegulation
                ? Icon(
                    Icons.keyboard_arrow_up_outlined,
                    color: Colors.white,
                    size: 3.h,
                  )
                : Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: Colors.white,
                    size: 3.h,
                  ),
            hintText: AppLocalizations.of(context)!.insights_regulatoryHint,
            hintStyle: const TextStyle(
                color: Color(0xffADADAD), fontStyle: FontStyle.italic),
            fillColor: AddSettingsData.themeValue == 2
                ? const Color(0xffEBEBEB)
                : AddSettingsData.themeValue == 1
                    ? Colors.white.withOpacity(0.10)
                    : const Color(0xff323232),
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        Visibility(
          visible: isRegulation,
          child: Container(
            height: 21.h,
            padding: EdgeInsets.symmetric(vertical: 0.5.h),
            color: AddSettingsData.themeValue == 2
                ? const Color(0xffEBEBEB)
                : AddSettingsData.themeValue == 1
                    ? Colors.white.withOpacity(0.10)
                    : Colors.grey.shade800,
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 0.0),
                shrinkWrap: true,
                itemCount: getRegulatoryListResponse.body?.length ?? 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      getRegulatoryListResponse.body?[index].name ?? "",
                      style: TextStyle(color: Colors.white.withOpacity(0.60)),
                    ),
                    onTap: () {
                      setState(() {
                        regulController.text =
                            getRegulatoryListResponse.body?[index].name ?? "";
                        isRegulation = false;
                      });
                    },
                  );
                }),
          ),
        ),
      ],
    );
  }

  Widget question7() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        AppLocalizations.of(context)!.train_physicalCapabilities,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
        ),
      ),
      SizedBox(height: 2.h),
      TextFormField(
        onTap: () {
          isCapability = !isCapability;
          setState(() {});
        },
        readOnly: true,
        style: TextStyle(
            color: AddSettingsData.themeValue == 2
                ? const Color(0xffADADAD)
                : Colors.white60),
        cursorColor: AddSettingsData.themeValue == 2
            ? const Color(0xffADADAD)
            : Colors.white60,
        controller: capabilityController,
        decoration: InputDecoration(
          suffixIcon: isCapability
              ? Icon(
                  Icons.keyboard_arrow_up_outlined,
                  color: Colors.white,
                  size: 3.h,
                )
              : Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color: Colors.white,
                  size: 3.h,
                ),
          hintText:
              AppLocalizations.of(context)!.train_physicalCapabilitiesHint,
          hintStyle: const TextStyle(
              color: Color(0xffADADAD), fontStyle: FontStyle.italic),
          fillColor: AddSettingsData.themeValue == 2
              ? const Color(0xffEBEBEB)
              : Colors.grey.shade800,
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      SizedBox(
        height: 2.h,
      ),
      Visibility(
        visible: isCapability,
        child: Container(
          height: 30.h,
          padding: EdgeInsets.symmetric(vertical: 0.5.h),
          color: AddSettingsData.themeValue == 2
              ? const Color(0xffEBEBEB)
              : AddSettingsData.themeValue == 1
                  ? Colors.white.withOpacity(0.10)
                  : Colors.grey.shade800,
          child: ListView.builder(
              padding: const EdgeInsets.only(top: 0.0),
              shrinkWrap: true,
              itemCount: getPhysicalCapabiltyResponse.body?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    getPhysicalCapabiltyResponse.body?[index].name ?? "",
                    style: TextStyle(color: Colors.white.withOpacity(0.60)),
                  ),
                  onTap: () {
                    setState(() {
                      capabilityController.text =
                          getPhysicalCapabiltyResponse.body?[index].name ?? "";
                      isCapability = false;
                    });
                  },
                );
              }),
        ),
      ),
    ]);
  }

  Widget submitButton() {
    return isLoading == false
        ? GestureDetector(
            onTap: () {
              userInteraction = true;
              isLoading = true;
              setProfileApi();
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 3.5.h),
              height: 7.5.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
                    AppLocalizations.of(context)!.save,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff1F1F1F),
                        decoration: TextDecoration.none),
                  )),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(color: Color(0xffFFCE3C)));
  }

  Widget nextButton() {
    return GestureDetector(
      onTap: () {
        if (activeStep == 0) {
          experienceController.text.isEmpty == true
              ? DioClient.get()
                  .toAst(AppLocalizations.of(context)!.train_chooseExp)
              : activeStep++;
        } else if (activeStep == 1) {
          locationController.text.isEmpty == true
              ? DioClient.get()
                  .toAst(AppLocalizations.of(context)!.train_chooseLocation)
              : activeStep++;
        } else if (activeStep == 2) {
          equipmentSelected.isEmpty == true
              ? DioClient.get()
                  .toAst(AppLocalizations.of(context)!.train_chooseEquip)
              : activeStep++;
        } else if (activeStep == 3) {
          interestSelected.isEmpty == true
              ? DioClient.get()
                  .toAst(AppLocalizations.of(context)!.train_chooseInterests)
              : activeStep++;
        } else if (activeStep == 4) {
          regulController.text.isEmpty == true
              ? DioClient.get()
                  .toAst(AppLocalizations.of(context)!.train_chooseExp)
              : activeStep++;
        } else if (activeStep == 5) {
          prefController.text.isEmpty == true
              ? DioClient.get()
                  .toAst(AppLocalizations.of(context)!.train_choosePreference)
              : activeStep++;
        }
        // else if(activeStep == 6){
        //   capabilityController.text.isEmpty==true?
        //   DioClient.get().toAst("Please select capabilities"):  activeStep++;
        // }
        else {
          activeStep++;
        }

        setState(() {});
      },
      child: Container(
        height: 7.5.h,
        margin: EdgeInsets.only(bottom: 3.5.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
              AppLocalizations.of(context)!.next,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff1F1F1F),
                  decoration: TextDecoration.none),
            )),
      ),
    );
  }
}
