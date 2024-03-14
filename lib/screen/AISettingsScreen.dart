import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:google_place/google_place.dart' as places;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:multiselect/multiselect.dart';
import 'package:huntfishai/models/feature/feature_data.dart';
import 'package:huntfishai/screen/huntfishAiSettingsData.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import '../apiModel/createRoom/CreateRoomResponse.dart';
import '../apiModel/getList/getListResponse.dart';
import '../apiModel/getMyDetail/GetMyDetailResponse.dart';
import '../apiModel/setProfile/setProfileRequest.dart';
import '../apiModel/setProfile/setProfileResponse.dart';
import '../api_collection/api_url_collection.dart';
import '../api_collection/dio_api_method.dart';
import '../api_collection/shared_prefrences.dart';
import '../constants/constants.dart';
import 'Login/LoginScreen.dart';
import 'chatbot/chatbot.dart';
import 'helperModel/addLocationHelperModel.dart';

class AISettingsScreen extends StatefulWidget {
  final bool? isBrook;
  final FeatureData? data;
  final int? roomId;
  const AISettingsScreen({Key? key, this.data, this.isBrook, this.roomId})
      : super(key: key);

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  //getProfileApi
  GetMyDetailResponse getMyDetailResponse = GetMyDetailResponse();
  void getDetailApi() async {
    var response = await DioClient.get().dioGetMethod(ApiUrl.getMyDetail);
    getMyDetailResponse =
        GetMyDetailResponse.fromJson(jsonDecode(response.toString()));

    if (getMyDetailResponse.body?.intrests != null) {
      for (var y in getMyDetailResponse.body?.intrests?.split(", ")
          as Iterable<dynamic>) {
        interestSelected.add(y);
      }
    }
    if (getMyDetailResponse.body?.equipment != null) {
      for (var y in getMyDetailResponse.body?.equipment?.split(", ")
          as Iterable<dynamic>) {
        equipmentSelected.add(y);
      }
    }
    setState(() {});
  }

  List<String> masterInterestList = [];
  List<String> interestSelected = [];

  List<String> masterEquipmentList = [];
  List<String> equipmentSelected = [];

  //editProfileApi
  SetYourProfileResponse setYourProfileResponse = SetYourProfileResponse();
  bool isProfileObscure = true;
  final profileFormKey = GlobalKey<FormState>();
  bool userProfileInteraction = false;
  bool isProfileLoading = false;
  changeProfileApi() async {
    print(interestSelected.toString());
    try {
      Purchases.setAttributes({
        "location": locationController.text,
        "equipment": equipmentSelected
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', ''),
        "experienceLevel": experienceController.text,
        "interests":
            interestSelected.toString().replaceAll('[', '').replaceAll(']', ''),
        "regulations": regulController.text,
      });

      final request = SetYourProfileRequest(
        full_name: getMyDetailResponse.body?.fullName,
        profileUrl: getMyDetailResponse.body?.profileUrl,
        physicalCapabilities: physicalController.text.isEmpty == true
            ? "${getMyDetailResponse.body?.physicalCapabilities}"
            : physicalController.text,
        regulatoryUnderstanding: regulController.text.isEmpty == true
            ? "${getMyDetailResponse.body?.regulatoryUnderstanding}"
            : regulController.text,
        location: locationController.text.isEmpty == true
            ? "${getMyDetailResponse.body?.location}"
            : locationController.text,
        latitude: locationController.text.isEmpty == true
            ? "${getMyDetailResponse.body?.latitude}"
            : AddLocationData.pickupLat.toString(),
        longitude: locationController.text.isEmpty == true
            ? "${getMyDetailResponse.body?.longitude}"
            : AddLocationData.pickupLng.toString(),
        preferences: prefController.text.isEmpty == true
            ? "${getMyDetailResponse.body?.preferences}"
            : prefController.text,
        experience: experienceController.text.isEmpty == true
            ? "${getMyDetailResponse.body?.experience}"
            : experienceController.text,
        equipment: equipmentSelected.isEmpty
            ? "${getMyDetailResponse.body?.equipment}"
            : equipmentSelected
                .toString()
                .replaceAll('[', '')
                .replaceAll(']', ''),
        intrests: interestSelected.isEmpty
            ? "${getMyDetailResponse.body?.intrests}"
            : interestSelected
                .toString()
                .replaceAll('[', '')
                .replaceAll(']', ''),
      );
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.setProfile, request);
      setYourProfileResponse = SetYourProfileResponse.fromJson(response.data);
      if (setYourProfileResponse.code == 200) {
        AddSettingsData.experience = experienceController.text;
        AddSettingsData.location = locationController.text;
        AddSettingsData.equipment = equipmentSelected.isEmpty
            ? "${getMyDetailResponse.body?.equipment}"
            : equipmentSelected
                .toString()
                .replaceAll('[', '')
                .replaceAll(']', '');
        AddSettingsData.interests = interestSelected.isEmpty
            ? "${getMyDetailResponse.body?.intrests}"
            : interestSelected
                .toString()
                .replaceAll('[', '')
                .replaceAll(']', '');
        AddSettingsData.preferences = prefController.text;
        AddSettingsData.regulations = regulController.text;
        // AddSettingsData.season=seasonController.text;
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
            "my name is ${getMyDetailResponse.body?.fullName} and ${AddSettingsData.experience}${AddSettingsData.location}${AddSettingsData.equipment}${AddSettingsData.interests}${AddSettingsData.preferences}${AddSettingsData.regulations}";
        setState(() {});

        widget.roomId == null
            ? DioClient.get().toAst("Settings Update Successfully")
            : "";
        widget.roomId == null
            ? Navigator.pop(context)
            : Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatBotScreen(
                  isBrook: widget.isBrook,
                  roomId: widget.roomId.toString(),
                  data: FeatureData(
                      image: "assets/images/q_and_a.png",
                      title: "Question and Answer",
                      imageColor: Colors.indigo,
                      bgColor: Colors.indigoAccent,
                      type: FeatureType.kCompletion),
                ),
              ));

        isProfileLoading = false;
        setState(() {});
      } else if (setYourProfileResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        DioClient.get().toAst(setYourProfileResponse.message.toString());
        isProfileLoading = false;
        setState(() {});
      } else {
        DioClient.get().toAst(setYourProfileResponse.message.toString());
        isProfileLoading = false;
        setState(() {});
      }
    } catch (e) {
      Timer(const Duration(seconds: 1), () {
        isProfileLoading = false;
        setState(() {});
      });
      //DioClient.get().toAst(loginResponse.message.toString());
    }
  }

  TextEditingController interstController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController equipController = TextEditingController();
  TextEditingController prefController = TextEditingController();
  TextEditingController regulController = TextEditingController();
  TextEditingController physicalController = TextEditingController();
  TextEditingController seasonController = TextEditingController();
  late FocusNode fnLocation;
  late places.GooglePlace googlePlace;
  List<places.AutocompletePrediction> predictions = [];
  bool isPlaceListVisible = false;
  bool isDestinationSelected = false;
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
    var body = getinterestListResponse.toJson();
    for (var x in body['body']) {
      masterInterestList.add(x['name']);
    }
    print("interest list response1: ${body['body']}");
    setState(() {});
  }

  //experienceApi
  GetListResponse getExperienceListResponse = GetListResponse();
  void getExperienceApi() async {
    var response =
        await DioClient.get().dioGetMethod("${ApiUrl.allList}?type=2");
    getExperienceListResponse =
        GetListResponse.fromJson(jsonDecode(response.toString()));
    print("experience level response: ${getExperienceListResponse.body}");
    setState(() {});
  }

  //equipmentApi
  GetListResponse getEquipmentListResponse = GetListResponse();
  void getEquipmentApi() async {
    var response =
        await DioClient.get().dioGetMethod("${ApiUrl.allList}?type=1");
    getEquipmentListResponse =
        GetListResponse.fromJson(jsonDecode(response.toString()));
    var body = getEquipmentListResponse.toJson();
    for (var x in body['body']) {
      masterEquipmentList.add(x['name']);
    }
    print("equiment list response: ${getEquipmentListResponse.body}");
    setState(() {});
  }

  //RegulatoryApi
  GetListResponse getRegulatoryListResponse = GetListResponse();
  void getRegulatoryApi() async {
    var response =
        await DioClient.get().dioGetMethod("${ApiUrl.allList}?type=5");
    getRegulatoryListResponse =
        GetListResponse.fromJson(jsonDecode(response.toString()));
    print("regulatory response: ${getRegulatoryListResponse.body}");
    setState(() {});
  }

  //physicalCapabiltyApi
  GetListResponse getPhysicalCapabiltyResponse = GetListResponse();
  void getphysicalCapabiltyApi() async {
    var response =
        await DioClient.get().dioGetMethod("${ApiUrl.allList}?type=4");
    getPhysicalCapabiltyResponse =
        GetListResponse.fromJson(jsonDecode(response.toString()));
    print("physical response: ${getPhysicalCapabiltyResponse.body}");
    setState(() {});
  }

  bool isExperience = false;
  bool isinterest = false;
  bool isEquipment = false;
  bool isPrefrences = false;
  bool isRegulation = false;
  bool isCapability = false;
  bool isSeason = false;
  @override
  void initState() {
    getInterestApi();
    getExperienceApi();
    getEquipmentApi();
    // getphysicalCapabiltyApi();
    getRegulatoryApi();
    getDetailApi();

    experienceController.text = (AddSettingsData.experience
                ?.replaceFirst("my experience level is ", "") ??
            getMyDetailResponse.body?.experience.toString() ??
            "")
        .trim();

    locationController.text =
        (AddSettingsData.location?.replaceFirst(", i live near ", "") ??
                getMyDetailResponse.body?.location.toString() ??
                "")
            .trim();
    equipController.text = (AddSettingsData.equipment
                ?.replaceFirst(", i prefer using", "")
                .replaceFirst(" but it is not required", "") ??
            getMyDetailResponse.body?.equipment.toString() ??
            "")
        .trim();
    prefController.text = (AddSettingsData.preferences
                ?.replaceFirst(", and you should know ", "") ??
            getMyDetailResponse.body?.preferences.toString() ??
            "")
        .trim();
    regulController.text = (AddSettingsData.regulations
                ?.replaceFirst(", my regulation understandings are ", "")
                .replaceFirst(" level.", "") ??
            getMyDetailResponse.body?.regulatoryUnderstanding.toString() ??
            "")
        .trim();
    googlePlace = places.GooglePlace("AIzaSyCrPOCUEMHoOXOacOtMkuQxSbSE1lYzpFA");
    fnLocation = FocusNode();
    setState(() {});
    super.initState();
  }

  CreateRoomResponse createRoomResponse = CreateRoomResponse();

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
            AppLocalizations.of(context)!.insights_appBarTitle,
            style: TextStyle(
              color:
                  AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: AddSettingsData.themeValue == 2
            ? Colors.white
            : AddSettingsData.themeValue == 1
                ? const Color(0xff000221)
                : Colors.black,
        body: Padding(
          padding: EdgeInsets.only(left: 3.w, right: 3.w),
          child: ListView(children: [
            SizedBox(
              height: 1.h,
            ),
            Text(
              AppLocalizations.of(context)!.insights_outdoorExp,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AddSettingsData.themeValue == 2
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            SizedBox(
              height: 7.5.h,
              child: TextFormField(
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
                  hintText:
                      AppLocalizations.of(context)!.insights_outdoorExpHint,
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
            ),
            Visibility(
              visible: isExperience,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                color: AddSettingsData.themeValue == 2
                    ? const Color(0xffEBEBEB)
                    : AddSettingsData.themeValue == 1
                        ? Colors.white.withOpacity(0.10)
                        : const Color(0xff323232),
                child: ListView.builder(
                    padding: const EdgeInsets.only(top: 0.0),
                    shrinkWrap: true,
                    itemCount: getExperienceListResponse.body?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          getExperienceListResponse.body?[index].name ?? "",
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.60)),
                        ),
                        onTap: () {
                          setState(() {
                            experienceController.text =
                                getExperienceListResponse.body?[index].name ??
                                    "";
                            isExperience = false;
                          });
                        },
                      );
                    }),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Text(
              AppLocalizations.of(context)!.insights_location,
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AddSettingsData.themeValue == 2
                      ? Colors.black
                      : Colors.white),
            ),
            SizedBox(
              height: 1.h,
            ),
            SizedBox(
              height: 7.5.h,
              child: TextFormField(
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
                  suffixIcon: IconButton(
                      onPressed: locationController.clear,
                      icon: const Icon(Icons.clear),
                      color: Colors.white),
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
            ),
            Visibility(
              visible: isPlaceListVisible,
              child: Container(
                color: AddSettingsData.themeValue == 2
                    ? const Color(0xffEBEBEB)
                    : AddSettingsData.themeValue == 1
                        ? Colors.white.withOpacity(0.10)
                        : const Color(0xff323232),
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
                          final details =
                              await googlePlace.details.get(placeId);
                          if (details != null && details.result != null) {
                            locationController.text =
                                details.result!.formattedAddress!;
                            AddLocationData.insightName =
                                details.result!.formattedAddress!;
                            AddLocationData.pickupLat =
                                details.result!.geometry!.location!.lat!;
                            AddLocationData.pickupLng =
                                details.result!.geometry!.location!.lng!;
                            isPlaceListVisible = false;
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
            SizedBox(
              height: 1.h,
            ),
            Text(
              AppLocalizations.of(context)!.insights_preferredEquip,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AddSettingsData.themeValue == 2
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
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
                  hintStyle: const TextStyle(color: Color(0xffADADAD)),
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
                selected_values_style: TextStyle(
                    fontSize: 11.sp, color: Colors.white.withOpacity(0.70)),
                options: masterEquipmentList,
                selectedValues: equipmentSelected,
                whenEmpty:
                    AppLocalizations.of(context)!.insights_preferredEquipHint,
              ),
            )),
            SizedBox(
              height: 1.h,
            ),
            Text(
              AppLocalizations.of(context)!.insights_primaryInterets,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AddSettingsData.themeValue == 2
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
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
                selected_values_style: TextStyle(
                    fontSize: 11.sp, color: Colors.white.withOpacity(0.70)),
                options: masterInterestList,
                selectedValues: interestSelected,
                whenEmpty:
                    AppLocalizations.of(context)!.insights_primaryInteretsHint,
              ),
            )),
            SizedBox(
              height: 1.h,
            ),
            Text(
              AppLocalizations.of(context)!.insights_regulatory,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AddSettingsData.themeValue == 2
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            SizedBox(
              height: 7.5.h,
              child: TextFormField(
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
                  hintText:
                      AppLocalizations.of(context)!.insights_regulatoryHint,
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
            ),
            Visibility(
              visible: isRegulation,
              child: Container(
                height: 30.h,
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                color: AddSettingsData.themeValue == 2
                    ? const Color(0xffEBEBEB)
                    : AddSettingsData.themeValue == 1
                        ? Colors.white.withOpacity(0.10)
                        : const Color(0xff323232),
                child: ListView.builder(
                    padding: const EdgeInsets.only(top: 0.0),
                    shrinkWrap: true,
                    itemCount: getRegulatoryListResponse.body?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          getRegulatoryListResponse.body?[index].name ?? "",
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.60)),
                        ),
                        onTap: () {
                          setState(() {
                            regulController.text =
                                getRegulatoryListResponse.body?[index].name ??
                                    "";
                            isRegulation = false;
                          });
                        },
                      );
                    }),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Text(
              AppLocalizations.of(context)!.insights_additional,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AddSettingsData.themeValue == 2
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            SizedBox(
                height: 7.5.h,
                child: TextFormField(
                  style: TextStyle(
                      color: AddSettingsData.themeValue == 2
                          ? const Color(0xffADADAD)
                          : Colors.white60),
                  cursorColor: Colors.white,
                  controller: prefController,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.insights_additionalHint,
                    hintStyle: const TextStyle(color: Color(0xffADADAD)),
                    fillColor: AddSettingsData.themeValue == 2
                        ? const Color(0xffEBEBEB)
                        : AddSettingsData.themeValue == 1
                            ? Colors.white.withOpacity(0.10)
                            : const Color(0xff323232),
                    filled: true,
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none),
                  ),
                )),
            SizedBox(
              height: 1.h,
            ),
            // Text('Physical Capabilities',style: TextStyle(fontSize:11.sp, fontWeight:FontWeight.bold,color:AddSettingsData.themeValue==2?Colors.black:Colors.white,),),
            // SizedBox(height: 1.h,),
            // Container(
            //     height: 7.5.h,
            //     child:    TextFormField(
            //       onTap: (){
            //         isCapability=!isCapability;
            //         setState(() {});
            //
            //       },
            //       readOnly: true,
            //       style: TextStyle(color: AddSettingsData.themeValue==2?Color(0xffADADAD):Colors.white60),
            //       cursorColor: AddSettingsData.themeValue==2?Color(0xffADADAD):Colors.white60,
            //       controller: physicalController,
            //       decoration: InputDecoration(
            //         suffixIcon: isCapability?Icon(Icons.keyboard_arrow_up_outlined,color: Colors.white, size: 3.h,):Icon(Icons.keyboard_arrow_down_outlined,color: Colors.white, size: 3.h,),
            //         hintText: getMyDetailResponse.body?.physicalCapabilities.toString()??'  ----Select Capabilities----',
            //         hintStyle: TextStyle(color: Color(0xffADADAD),fontStyle: FontStyle.italic),
            //         fillColor:  AddSettingsData.themeValue==2?Color(0xffEBEBEB):Colors.grey.shade800,
            //         filled: true,
            //         focusedBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(10.0),
            //         ),
            //         enabledBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(10.0),
            //         ),
            //       ),
            //     ),
            // ),

            //     SizedBox(height: 2.h,),
            Visibility(
              visible: isCapability,
              child: Container(
                height: 30.h,
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                color: AddSettingsData.themeValue == 2
                    ? const Color(0xffEBEBEB)
                    : Colors.grey.shade800,
                child: ListView.builder(
                    padding: const EdgeInsets.only(top: 0.0),
                    shrinkWrap: true,
                    itemCount: getPhysicalCapabiltyResponse.body?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          getPhysicalCapabiltyResponse.body?[index].name ?? "",
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.60)),
                        ),
                        onTap: () {
                          setState(() {
                            physicalController.text =
                                getPhysicalCapabiltyResponse
                                        .body?[index].name ??
                                    "";
                            isCapability = false;
                          });
                        },
                      );
                    }),
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            isProfileLoading == false
                ? GestureDetector(
                    onTap: () {
                      isProfileLoading = true;
                      changeProfileApi();
                    },
                    child: Container(
                      height: 7.5.h,
                      width: 2.w,
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
                    child: CircularProgressIndicator(color: Color(0xffFFCE3C))),
            SizedBox(height: 4.h),
          ]),
        ));
  }
}
