import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:app_settings/app_settings.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart' as places;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:huntfishai/screen/AISettingsScreen.dart';
import 'package:huntfishai/screen/Setting.dart';
import 'package:huntfishai/screen/Wlcome/welcomeScreen.dart';
import 'package:sizer/sizer.dart';
import '../../apiModel/getMyDetail/GetMyDetailResponse.dart';
import '../../apiModel/setProfile/setProfileRequest.dart';
import '../../apiModel/setProfile/setProfileResponse.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../Login/LoginScreen.dart';
import '../helperModel/InitailLocationHelper.dart';
import '../helperModel/addLocationHelperModel.dart';
import '../huntfishAiSettingsData.dart';

class GeographicalRegionScreen extends StatefulWidget {
  const GeographicalRegionScreen({Key? key}) : super(key: key);

  @override
  State<GeographicalRegionScreen> createState() =>
      _GeographicalRegionScreenState();
}

class _GeographicalRegionScreenState extends State<GeographicalRegionScreen> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  //var Defined
  Uint8List? pickupIcon;
  bool onClickList = false;
  Uint8List? currentLocIcon;
  double? latitude;
  double? longitude;
  bool isLoading = true;
  double lat = 0.0, lng = 0.0;
  FocusNode? fnLocation;
  bool isPlaceListVisible = false;
  bool isFilteredMapCreate = false;
  bool isDestinationSelected = false;
  bool isCameraMovedFromList = false;
  late places.GooglePlace googlePlace;
  Set<Marker> markers = {};
  late GoogleMapController mapController;
  final searchScreenController = TextEditingController();
  List<places.AutocompletePrediction> predictions = [];

  //getProfileApi
  GetMyDetailResponse getMyDetailResponse = GetMyDetailResponse();
  void getDetailApi() async {
    var response = await DioClient.get().dioGetMethod(ApiUrl.getMyDetail);
    getMyDetailResponse =
        GetMyDetailResponse.fromJson(jsonDecode(response.toString()));
    print("interstList${getMyDetailResponse.body?.intrests}");
    setState(() {});
  }

  //editProfileApi
  SetYourProfileResponse setYourProfileResponse = SetYourProfileResponse();
  changeProfileApi() async {
    try {
      final request = SetYourProfileRequest(
        full_name: getMyDetailResponse.body?.fullName,
        profileUrl: getMyDetailResponse.body?.profileUrl,
        physicalCapabilities:
            "${getMyDetailResponse.body?.physicalCapabilities}",
        regulatoryUnderstanding:
            "${getMyDetailResponse.body?.regulatoryUnderstanding}",
        location: searchScreenController.text,
        latitude: "${getMyDetailResponse.body?.latitude}",
        longitude: "${getMyDetailResponse.body?.longitude}",
        preferences: "${getMyDetailResponse.body?.preferences}",
        experience: "${getMyDetailResponse.body?.experience}",
        equipment: "${getMyDetailResponse.body?.equipment}",
        intrests: "${getMyDetailResponse.body?.intrests}",
      );
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.setProfile, request);
      setYourProfileResponse = SetYourProfileResponse.fromJson(response.data);
      if (setYourProfileResponse.code == 200) {
        AddSettingsData.location = searchScreenController.text.isEmpty == true
            ? "${getMyDetailResponse.body?.location}"
            : searchScreenController.text;
        setState(() {});

        DioClient.get().toAst("Location Update Successfully");

        Navigator.of(context).pop();

        setState(() {});
      } else if (setYourProfileResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        DioClient.get().toAst(setYourProfileResponse.message.toString());
        setState(() {});
      } else {
        DioClient.get().toAst(setYourProfileResponse.message.toString());
        setState(() {});
      }
    } catch (e) {
      Timer(const Duration(seconds: 1), () {
        setState(() {});
      });
      //DioClient.get().toAst(loginResponse.message.toString());
    }
  }

  //ONINIT
  @override
  void initState() {
    getDetailApi();
    print("loc::::::${getMyDetailResponse.body?.physicalCapabilities}");
    print("hjgfhgfghfgdgdfgdfgdfgd ${AddLocationData.currentPosition}");
    super.initState();

    googlePlace = places.GooglePlace("AIzaSyCrPOCUEMHoOXOacOtMkuQxSbSE1lYzpFA");
    fnLocation = FocusNode();
  }

  Future<void> getUpdatedPosition() async {
    if (isCameraMovedFromList == false) {
      List<Placemark> placeMark = await placemarkFromCoordinates(
          newMarkerPosition?.latitude ?? 0, newMarkerPosition?.longitude ?? 0);
      lat = newMarkerPosition?.latitude ?? 0;
      lng = newMarkerPosition?.longitude ?? 0;
      AddLocationData.geographicName =
          "${placeMark[0].subLocality} ${placeMark[0].locality} ${placeMark[0].administrativeArea} ${placeMark[0].country}";

      searchScreenController.text =
          "${placeMark[0].subLocality} ${placeMark[0].locality} ${placeMark[0].administrativeArea} ${placeMark[0].country}";
      print("NEW ADDRESS::::${searchScreenController.text}");
    }
    isCameraMovedFromList = false;
    setState(() {});
  }

  Position? newMarkerPosition;
  void updatePosition(CameraPosition position) {
    newMarkerPosition = Position(
        latitude: position.target.latitude,
        longitude: position.target.longitude,
        accuracy: 10,
        altitude: 1.0,
        heading: 0.0,
        speed: 10,
        speedAccuracy: 1,
        timestamp: null);
    setState(() {});
  }

  //LOCATIONPERMISSIONSANDGETLOCATION
  getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return AppSettings.openAppSettings();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return AppSettings.openAppSettings();
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;
    LatLng location = LatLng(lat, long);
    AddLocationData.currentPosition = location;
    latitude = position.latitude;
    longitude = position.longitude;
    print('Latitude: $latitude');
    print(
        ' AddLocationData.selectedPosition: ${AddLocationData.selectedPosition}');
    print('Longitude: $longitude');
    print("loctionnnn::${AddLocationData.currentPosition?.longitude}");
    print("loc::${AddLocationData.currentPosition?.longitude}");
    isLoading = false;
    setState(() {});
    List<Placemark> placeMark = await placemarkFromCoordinates(
        AddLocationData.currentPosition?.latitude ?? 0,
        AddLocationData.currentPosition?.longitude ?? 0);
    AddLocationData.geographicName =
        "${placeMark[0].name} ${placeMark[0].subLocality} ${placeMark[0].locality}";
    searchScreenController.text =
        "${placeMark[0].name} ${placeMark[0].subLocality} ${placeMark[0].locality}";
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        // on below line we have given positions of Location 5
        CameraPosition(
      target: LatLng(lat, long),
      zoom: 14,
    )));
    setState(() {});
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      log(result.predictions!.first.description.toString());
      predictions = result.predictions!;
      setState(() {});
      log('async');
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    print("onmap create -->> ${AddLocationData.currentPosition}");
    getLocation();
    setState(() {});
  }

  bool showInfoWindow = false;

  void toggleInfoWindow() {
    setState(() {
      showInfoWindow = !showInfoWindow;
    });
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
            "Geographical Region",
            style: TextStyle(
              color:
                  AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Container(
            margin: EdgeInsets.only(top: 2.h),
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6.5.w),
                      topLeft: Radius.circular(6.5.w),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
                        children: [
                          GoogleMap(
                            myLocationButtonEnabled: false,
                            myLocationEnabled: false,
                            zoomControlsEnabled: false,
                            onCameraIdle: () => getUpdatedPosition(),
                            onMapCreated: onMapCreated,
                            onCameraMove: ((position) =>
                                updatePosition(position)),
                            initialCameraPosition: CameraPosition(
                              //   target: LatLng(13.899497, 100.542644),
                              target: AddLocationData.selectedPosition ??
                                  LatLng(InitialLoctionHelper.initialLat ?? 0,
                                      InitialLoctionHelper.initialLng ?? 0),
                              zoom: 13.0,
                            ),
                            markers: markers,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 3.h),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xffFFCE3C)
                                        .withOpacity(0.22),
                                    radius: 12.w,
                                  ),
                                  CircleAvatar(
                                    backgroundColor: const Color(0xffFFCE3C)
                                        .withOpacity(0.42),
                                    radius: 9.w,
                                  ),
                                  CircleAvatar(
                                    backgroundColor: const Color(0xffFFCE3C),
                                    radius: 5.w,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 3.h),
                                    child: InkWell(
                                      onTap: toggleInfoWindow,
                                      child: Image.asset(
                                        "assets/images/location pin.png",
                                        height: 9.w,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 3.5.h, left: 1.5.w, right: 1.5.w),
                            child: textfield(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 72.h),
                            child: GestureDetector(
                              onTap: () {
                                changeProfileApi();
                              },
                              child: Container(
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
                                        borderRadius:
                                            BorderRadius.circular(3.w),
                                        color: const Color(0xffFFCE3C),
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
                          )
                        ],
                      ),
                    ),
                  )),
            )));
  }

  bool isloading = true;
  Widget textfield() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Column(
        children: [
          TextFormField(
            focusNode: fnLocation,
            style: TextStyle(
                color: const Color(0xffADADAD),
                fontSize: 14.sp,
                fontStyle: FontStyle.italic),
            decoration: InputDecoration(
              prefixIcon: Padding(
                  padding: EdgeInsets.all(2.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        color: const Color(0xffADADAD),
                        size: 3.h,
                      ),
                      SizedBox(
                        width: 4.w,
                      ),
                      Container(
                        height: 3.h,
                        width: 0.2.w,
                        color: const Color(0xffADADAD),
                      )
                    ],
                  )),
              suffixIcon: IconButton(
                  onPressed: searchScreenController.clear,
                  icon: const Icon(Icons.clear),
                  color: Colors.white),
              filled: true,
              fillColor: AddSettingsData.themeValue == 2
                  ? const Color(0xffEBEBEB)
                  : AddSettingsData.themeValue == 1
                      ? const Color(0xff191B37)
                      : const Color(0xff323232),
              hintText: AppLocalizations.of(context)!.geographical_hintText,
              hintStyle: const TextStyle(
                  color: Color(0xffADADAD), fontStyle: FontStyle.italic),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 1.9.h, horizontal: 4.w),
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
                borderSide: BorderSide(color: Colors.white, width: 0.2.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
                borderSide: BorderSide(color: Colors.white, width: 0.2.w),
              ),
            ),
            onChanged: (text) {
              log('confirm text field: $text');
              autoCompleteSearch(text);
              if (text.isEmpty) {
                isPlaceListVisible = false;
              } else {
                if (onClickList) {
                  isPlaceListVisible = false;
                  onClickList = false;
                } else {
                  isPlaceListVisible = true;
                }
              }
              setState(() {});
            },
            controller: searchScreenController,
          ),
          Visibility(
            visible: isPlaceListVisible,
            child: Container(
              color: Colors.white,
              height: 30.h,
              width: 92.w,
              child: ListView.builder(
                  padding: const EdgeInsets.only(top: 0.0),
                  shrinkWrap: true,
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        predictions[index].description.toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                      onTap: () async {
                        final placeId = predictions[index].placeId!;
                        final details = await googlePlace.details.get(placeId);
                        if (details != null && details.result != null) {
                          AddLocationData.geographicName =
                              predictions[index].description ?? "";
                          searchScreenController.text =
                              predictions[index].description ?? "";
                          lat = details.result!.geometry!.location!.lat!;
                          lng = details.result!.geometry!.location!.lng!;
                          log("lat::$lat");
                          log("lng::$lng");
                          isPlaceListVisible = false;
                          isCameraMovedFromList = true;
                          onClickList = true;
                          GoogleMapController? controller = mapController;
                          controller.animateCamera(CameraUpdate.newCameraPosition(
                              // on below line we have given positions of Location 5
                              CameraPosition(
                            target: LatLng(lat, lng),
                            zoom: 14,
                          )));
                          log(searchScreenController.text);
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {});
                        }
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
