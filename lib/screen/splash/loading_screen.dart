import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:huntfishai/screen/Login/LoginScreen.dart';
import 'package:huntfishai/screen/Login/SignupScreen.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:huntfishai/constants/constants.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import '../../apiModel/getMyDetail/GetMyDetailResponse.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../Wlcome/welcomeScreen.dart';
import 'package:flutter/material.dart';
import '../helperModel/InitailLocationHelper.dart';
import '../helperModel/addLocationHelperModel.dart';
import '../huntfishAiSettingsData.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    determinePosition();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool homeScreenOpened = false;
  bool isLoading = true;
  var userIsInsideTheApp;

  Future<void> initPlatformState() async {
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration(googleApiKey);
    PurchasesConfiguration(appleApiKey);
    PurchasesConfiguration configuration;

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(googleApiKey);
      await Purchases.configure(configuration);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(appleApiKey);
      await Purchases.configure(configuration);
    }
  }

  GetMyDetailResponse getMyDetailResponse = GetMyDetailResponse();
  void getDetailApi() async {
    var response = await DioClient.get().dioGetMethod(ApiUrl.getMyDetail);
    try {
      if (response == null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
        setState(() {});
      }
      getMyDetailResponse =
          GetMyDetailResponse.fromJson(jsonDecode(response.toString()));
      if (getMyDetailResponse.code == 200) {
        double lat;
        double lng;

        try {
          lat = getMyDetailResponse.body?.latitude == null
              ? AddLocationData.currentPosition?.latitude ?? 0.0
              : double.parse(getMyDetailResponse.body!.latitude!);
        } catch (e) {
          lat = 0.0; // Default value if parsing fails
        }

        try {
          lng = getMyDetailResponse.body?.longitude == null
              ? AddLocationData.currentPosition?.longitude ?? 0.0
              : double.parse(getMyDetailResponse.body!.longitude!);
        } catch (e) {
          lng = 0.0; // Default value if parsing fails
        }
        // double lat = getMyDetailResponse.body?.latitude == null ? AddLocationData.currentPosition?.latitude?? 0.0: double.parse((getMyDetailResponse.body?.latitude?? ""));
        // double lng = getMyDetailResponse.body?.longitude == null ? AddLocationData.currentPosition?.latitude?? 0.0 : double.parse((getMyDetailResponse.body?.longitude ?? ""));
        AddLocationData.selectedPosition = LatLng(
            lat != 0.0
                ? (AddLocationData.currentPosition?.latitude ?? 0.0)
                : lat,
            lng != 0.0
                ? (AddLocationData.currentPosition?.longitude ?? 0.0)
                : lng);
        AddSettingsData.themeValue = getMyDetailResponse.body?.theme;
        AddSettingsData.experience = getMyDetailResponse.body?.experience;
        AddSettingsData.location = getMyDetailResponse.body?.location;
        AddSettingsData.checkCount = getMyDetailResponse.body?.checkCount;
        AddSettingsData.equipment = getMyDetailResponse.body?.equipment;
        AddSettingsData.interests = getMyDetailResponse.body?.intrests;
        AddSettingsData.preferences = getMyDetailResponse.body?.preferences;
        AddSettingsData.regulations =
            getMyDetailResponse.body?.regulatoryUnderstanding;
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
            "my name is ${getMyDetailResponse.body?.fullName} and ${AddSettingsData.experience ?? ""}${AddSettingsData.location ?? ""}${AddSettingsData.equipment ?? ""}${AddSettingsData.preferences ?? ""}${AddSettingsData.regulations ?? ""}";
        print("finalQuestionSplash------>${AddSettingsData.finalQuestion}");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()));
        setState(() {});
      } else {
        throw Exception("Token is expired.");
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      determinePosition();
    }
  }

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // AppSettings.openAppSettings(type: AppSettingsType.location);
      // return Future.error('Location services are disabled.');

      DioClient.get().toAst('Location services are disabled.');

      isLoading = false;
      AddLocationData.currentPosition = const LatLng(0.0, 0.0);
      AddLocationData.geographicName = "Unknown";
      var getPref = await PreferenceManager.get().getAccessToken();
      print("PREF:::$getPref");
      print("location permission ignored.");
      print("userIsInsideTheApp:::$userIsInsideTheApp");
      Timer(const Duration(milliseconds: 300), () {
        if (!homeScreenOpened) {
          // Check if home screen has not been opened already
          if (getPref != null) {
            try {
              getDetailApi();
            } catch (err) {
              print('error');
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false);
            }
          } else if (getPref == null && userIsInsideTheApp != null) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false);
          } else if (getPref == null && userIsInsideTheApp == null) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SignupScreen()),
                (route) => false);
          }
          homeScreenOpened =
              true; // Set the flag variable to indicate home screen has been opened
        }
      });
      Timer(const Duration(milliseconds: 300), () {});
      setState(() {});
    } else {
      print("Location Access");

      // Check the location permission status
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        DioClient.get().toAst('Location services are disabled.');

        isLoading = false;
        AddLocationData.currentPosition = const LatLng(0.0, 0.0);
        AddLocationData.geographicName = "Unknown";
        var getPref = await PreferenceManager.get().getAccessToken();
        print("PREF:::$getPref");
        print("location permission ignored.");
        print("userIsInsideTheApp:::$userIsInsideTheApp");
        Timer(const Duration(milliseconds: 300), () {
          if (!homeScreenOpened) {
            // Check if home screen has not been opened already
            if (getPref != null) {
              try {
                getDetailApi();
              } catch (err) {
                print('error');
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false);
              }
            } else if (getPref == null && userIsInsideTheApp != null) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false);
            } else if (getPref == null && userIsInsideTheApp == null) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                  (route) => false);
            }
            homeScreenOpened =
                true; // Set the flag variable to indicate home screen has been opened
          }
        });
        Timer(const Duration(milliseconds: 300), () {});
        setState(() {});

        // print('Location permission denied permanently.');
        // AppSettings.openAppSettings(type: AppSettingsType.location);
        // return Future.error('Location permissions are denied');
      }

      // if (permission == LocationPermission.deniedForever) {
      //   AppSettings.openAppSettings(type: AppSettingsType.location);
      //   print('Location permission denied permanently.');
      //   return Future.error(
      //       'Location permissions are permanently denied, we cannot request permissions.');
      // }

      Position position;
      try {
        // Get the current position
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        // Handle any errors that occurred while getting the position
        print("Error getting position: $e");
        return Future.error('Error getting position: $e');
      }

      // Successfully obtained the position
      getAddressFromLatLng(position);
    }
  }

  Future<void> getAddressFromLatLng(Position determinePositions) async {
    if (kDebugMode) {
      print(
          "getAddressFromLatLng--->> ${determinePositions.latitude} ${determinePositions.longitude}");
      print(
          "getstatic--->> ${InitialLoctionHelper.initialLat} ${InitialLoctionHelper.initialLng}");
    }

    List<Placemark> placemarks;
    try {
      placemarks = await placemarkFromCoordinates(
          determinePositions.latitude, determinePositions.longitude);
    } catch (e) {
      debugPrint("Error getting placemarks: $e");
      return Future.error('Error getting placemarks: $e');
    }

    if (placemarks.isEmpty) {
      return Future.error('No placemarks found for the provided coordinates.');
    }

    Placemark place = placemarks[0];
    String currentAddress = place.name.toString();

    if (kDebugMode) {
      print("our location $currentAddress");
    }

    if (currentAddress.isNotEmpty) {
      isLoading = false;
      AddLocationData.currentPosition =
          LatLng(determinePositions.latitude, determinePositions.longitude);
      AddLocationData.geographicName = place.name.toString();
      var getPref = await PreferenceManager.get().getAccessToken();
      print("PREF:::$getPref");
      print("userIsInsideTheApp:::$userIsInsideTheApp");
      Timer(const Duration(milliseconds: 300), () {
        if (!homeScreenOpened) {
          // Check if home screen has not been opened already
          if (getPref != null) {
            try {
              getDetailApi();
            } catch (err) {
              print('error');
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false);
            }
          } else if (getPref == null && userIsInsideTheApp != null) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false);
          } else if (getPref == null && userIsInsideTheApp == null) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SignupScreen()),
                (route) => false);
          }
          homeScreenOpened =
              true; // Set the flag variable to indicate home screen has been opened
        }
      });
      Timer(const Duration(milliseconds: 300), () {});
      setState(() {});
    } else {
      determinePosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        padding: EdgeInsets.all(10.h),
        decoration: const BoxDecoration(
            color: Color(0xff1C1C1C),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/splash@3x.png"))),
        child: Image.asset("assets/images/huntFishLogo.png"),
      ),
    );
  }
}
