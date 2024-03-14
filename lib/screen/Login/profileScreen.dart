import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:app_settings/app_settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:huntfishai/apiModel/changePassword/changePasswordRequest.dart';
import 'package:huntfishai/apiModel/changePassword/changepasswordResponse.dart';
import 'package:huntfishai/apiModel/getMyDetail/GetMyDetailResponse.dart';
import 'package:huntfishai/apiModel/setProfile/setProfileRequest.dart';
import 'package:huntfishai/screen/Setting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import '../../apiModel/setProfile/setProfileResponse.dart';
import '../../apiModel/singlefileresponse.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../../helper/TextField_widget.dart';
import '../helperModel/validations.dart';
import '../huntfishAiSettingsData.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    getDetailApi();
    super.initState();
  }

  //getProfileApi
  GetMyDetailResponse getMyDetailResponse = GetMyDetailResponse();

  void getDetailApi() async {
    var response = await DioClient.get().dioGetMethod(ApiUrl.getMyDetail);
    getMyDetailResponse =
        GetMyDetailResponse.fromJson(jsonDecode(response.toString()));
    if (getMyDetailResponse.code == 200) {
      nameController.text = getMyDetailResponse.body?.fullName ?? "";
    }
    print("interestList--->${getMyDetailResponse.toJson()}");
    setState(() {});
  }

  //changePasswordApi
  ChangePasswordResponse changePasswordResponse = ChangePasswordResponse();
  bool isObscure = true;
  bool isConfirmObscure = true;

  final passwordFormKey = GlobalKey<FormState>();
  bool userInteraction = false;
  bool isPassLoading = false;
  String? imageUrl;

  changePassApi() async {
    try {
      final request = ChangePasswordRequest(
          newPassword: newPasswordController.text,
          oldPassword: oldPasswordController.text);
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.changePassword, request);
      changePasswordResponse = ChangePasswordResponse.fromJson(response.data);
      if (changePasswordResponse.code == 200) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SettingScreen(),
        ));
        isPassLoading = false;
        setState(() {});
      } else if (changePasswordResponse.code == 401) {
        PreferenceManager.get().preferenceClear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        DioClient.get().toAst(changePasswordResponse.message.toString());
        isPassLoading = false;
        setState(() {});
      } else {
        DioClient.get().toAst(changePasswordResponse.message.toString());
        isPassLoading = false;
        setState(() {});
      }
    } catch (e) {
      Timer(const Duration(seconds: 1), () {
        isPassLoading = false;
        setState(() {});
      });
      //DioClient.get().toAst(loginResponse.message.toString());
    }
  }

  UploadImageResponse uploadImageResponse = UploadImageResponse();

  Future<void> uploadProfileImage() async {
    var request = http.MultipartRequest(
        "POST", Uri.parse(ApiUrl.base + ApiUrl.singleFile));
    Map<String, String> headers = {
      "Authorization":
          "Bearer ${await PreferenceManager.get().getAccessToken()}",
      "Content-Type": "multipart/form-data"
    };

    if (image != null) {
      request.files.add(
        http.MultipartFile(
          "image",
          image!.readAsBytes().asStream(),
          image!.lengthSync(),
          filename: image!.path,
        ),
      );
    }
    request.headers.addAll(headers);
    final response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    uploadImageResponse =
        UploadImageResponse.fromJson(jsonDecode(responseString));
    if (uploadImageResponse.code == 200) {
      print(uploadImageResponse.body);
      imageUrl = uploadImageResponse.body?[0] ?? "";
      // imageUrl = uploadImageResponse.body;
      changeProfileApi();
      print("avatarimage::::$imageUrl");
    } else {
      DioClient.get().toAst('Sorry, the upload was not successful!');
    }
    setState(() {});
  }

  //editProfileApi
  SetYourProfileResponse setYourProfileResponse = SetYourProfileResponse();
  ChangePasswordResponse deleteChatLogsResponse = ChangePasswordResponse();
  bool isProfileObscure = true;
  final profileFormKey = GlobalKey<FormState>();
  bool userProfileInteraction = false;
  bool isProfileLoading = false;

  changeProfileApi() async {
    try {
      Purchases.setDisplayName(nameController.text);
      final request = SetYourProfileRequest(
        full_name: nameController.text.isNotEmpty == true
            ? nameController.text
            : getMyDetailResponse.body?.fullName,
        profileUrl: imageUrl ?? getMyDetailResponse.body?.profileUrl,
        intrests: getMyDetailResponse.body?.intrests,
        equipment: getMyDetailResponse.body?.equipment,
        experience: getMyDetailResponse.body?.experience,
        preferences: getMyDetailResponse.body?.preferences,
        longitude: getMyDetailResponse.body?.longitude,
        latitude: getMyDetailResponse.body?.latitude,
        location: getMyDetailResponse.body?.location,
        regulatoryUnderstanding:
            getMyDetailResponse.body?.regulatoryUnderstanding,
        physicalCapabilities: getMyDetailResponse.body?.physicalCapabilities,
      );
      print("req--->${request.toJson()}");
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.setProfile, request);
      print("response--->${response.toString()}");
      setYourProfileResponse = SetYourProfileResponse.fromJson(response.data);
      if (setYourProfileResponse.code == 200) {
        Navigator.pop(context);
        getDetailApi();
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

  void deleteAcc() async {
    var response = await DioClient.get().dioGetMethod(ApiUrl.deleteAcc);
    deleteChatLogsResponse =
        ChangePasswordResponse.fromJson(jsonDecode(response.toString()));
    if (deleteChatLogsResponse.code == 200) {
      print("successssss");
      await PreferenceManager.get().preferenceClear();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
            AppLocalizations.of(context)!.settings_profile,
            style: TextStyle(
              color:
                  AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 13.h,
                ),
                getMyDetailResponse.body?.profileUrl == null
                    ? CircleAvatar(
                        radius: 15.w,
                        backgroundColor: Colors.grey,
                        child: const Icon(
                          Icons.camera,
                          color: Colors.white,
                        ),
                      )
                    : CircleAvatar(
                        radius: 15.w,
                        backgroundColor: Colors.grey,
                        foregroundImage: NetworkImage(
                            "${getMyDetailResponse.body?.profileUrl}"),
                        child: const Icon(
                          Icons.camera,
                          color: Colors.white,
                        ),
                      ),
                SizedBox(
                  height: 2.h,
                ),
                getMyDetailResponse.body?.fullName == null
                    ? Text(
                        "Loading...",
                        style: TextStyle(
                          color: AddSettingsData.themeValue == 2
                              ? Colors.black
                              : Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text(
                        getMyDetailResponse.body?.fullName.toString() ??
                            "No Name",
                        style: TextStyle(
                          color: AddSettingsData.themeValue == 2
                              ? Colors.black
                              : Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                SizedBox(
                  height: 4.h,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      left: 0.1.h, top: 0.5.h, bottom: 0.5.h, right: 1.h),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AddSettingsData.themeValue == 2
                        ? const Color(0xffEBEBEB)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                      onTap: () {
                        editBottomSheet(context);
                      },
                      horizontalTitleGap: 0,
                      contentPadding: EdgeInsets.zero,
                      leading: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Image.asset(
                          "assets/images/contact.png",
                          color: Colors.white,
                          height: 2.8.h,
                        ),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.profile_editProfile,
                        style: TextStyle(
                            color: AddSettingsData.themeValue == 2
                                ? const Color(0xff1C1C1C)
                                : Colors.white,
                            fontSize: 11.sp),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 3.h,
                        color: AddSettingsData.themeValue == 2
                            ? const Color(0xff1C1C1C)
                            : Colors.white,
                      )),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      left: 0.1.h, top: 0.5.h, bottom: 0.5.h, right: 1.h),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AddSettingsData.themeValue == 2
                        ? const Color(0xffEBEBEB)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                      onTap: () {
                        changePassowrdBottomSheet(context);
                      },
                      horizontalTitleGap: 0,
                      contentPadding: EdgeInsets.zero,
                      leading: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Image.asset(
                          "assets/images/pass.png",
                          color: Colors.white,
                          height: 2.8.h,
                        ),
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.profile_changePW,
                        style: TextStyle(
                            color: AddSettingsData.themeValue == 2
                                ? const Color(0xff1C1C1C)
                                : Colors.white,
                            fontSize: 11.sp),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 3.h,
                        color: AddSettingsData.themeValue == 2
                            ? const Color(0xff1C1C1C)
                            : Colors.white,
                      )),
                ),
              ],
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            content: Text(
                                AppLocalizations.of(context)!
                                    .profile_logoutConfirm,
                                style: const TextStyle(color: Colors.black)),
                            actions: [
                              TextButton(
                                child: Text(
                                  AppLocalizations.of(context)!.no,
                                  style: TextStyle(
                                      fontSize: 14.sp, color: Colors.black),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                  child: Text(
                                    AppLocalizations.of(context)!.yes,
                                    style: TextStyle(
                                        fontSize: 14.sp, color: Colors.black),
                                  ),
                                  onPressed: () async {
                                    PreferenceManager.get().preferenceClear();
                                    await Purchases.logOut();
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen()),
                                        (route) => false);
                                  })
                            ]);
                      },
                    );
                  },
                  child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      width: double.maxFinite,
                      height: 7.h,
                      decoration: BoxDecoration(
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
                            AppLocalizations.of(context)!.profile_logout,
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xff1F1F1F),
                                decoration: TextDecoration.none),
                          ))),
                ),
                Center(
                  child: Container(
                    child: TextButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  content: Text(
                                      AppLocalizations.of(context)!
                                          .profile_deleteConfirm,
                                      style:
                                          const TextStyle(color: Colors.black)),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        "No",
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                        child: Text(
                                          "Yes",
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black),
                                        ),
                                        onPressed: () {
                                          deleteAcc();
                                        })
                                  ]);
                            },
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.profile_delete,
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.normal,
                              color: Colors.red,
                              decoration: TextDecoration.underline),
                        )),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  File? image;
  bool isCameraAccessDenied = false;
  bool isGalleryAccessDenied = false;
  final ImagePicker _picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void updateImage(File? newImage) {
    setState(() {
      image = newImage;
    });
  }

  imgFromCamera() async {
    try {
      final pickedImage = await _picker.pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        image = File(pickedImage.path);
        uploadProfileImage();
        setState(() {});
      }
    } catch (e) {
      print("exc::${e.toString()}");
      if (isCameraAccessDenied == true) {
        AppSettings.openAppSettings(type: AppSettingsType.internalStorage);
        print("isCameraAccessDenied $isCameraAccessDenied");
      }
      isCameraAccessDenied = true;
      setState(() {});
    }
  }

  imgFromGallery() async {
    if (Platform.isIOS) {
      try {
        final pickedImage =
            await _picker.pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          image = File(pickedImage.path);
          uploadProfileImage();
        }
        setState(() {});
      } catch (e) {
        print("exc::${e.toString()}");
        if (isGalleryAccessDenied == true) {
          AppSettings.openAppSettings(type: AppSettingsType.internalStorage);
          print("isGalleryAccessDenied $isGalleryAccessDenied");
        }
        isGalleryAccessDenied = true;
        setState(() {});
      }
    } else {
      // await Permission.storage.request().then((value)async{
      //   if(value.isGranted){
      final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        image = File(pickedImage.path);
        uploadProfileImage();
      }
      // }else{
      if (isGalleryAccessDenied == true) {
        AppSettings.openAppSettings(type: AppSettingsType.internalStorage);
        print("isGalleryAccessDenied $isGalleryAccessDenied");
        // }
        isGalleryAccessDenied = true;
      }
      setState(() {});
      // });
    }
  }

  void showPicker(context, Function(File?) updateImage) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                tileColor: Colors.white,
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library',
                    style: TextStyle(color: Colors.black)),
                onTap: () async {
                  try {
                    final pickedImage = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
                    );
                    if (pickedImage != null) {
                      updateImage(File(pickedImage.path));
                    }
                    Navigator.of(context).pop();
                  } catch (e) {
                    print("pick image error $e");
                    DioClient.get().toAst(AppLocalizations.of(context)!.error);
                  }
                },
              ),
              ListTile(
                tileColor: Colors.white,
                leading: const Icon(Icons.photo_camera),
                title:
                    const Text('Camera', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  try {
                    final pickedImage =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (pickedImage != null) {
                      updateImage(File(pickedImage.path));
                    }
                    Navigator.of(context).pop();
                  } catch (e) {
                    print("pick image error $e");
                    DioClient.get().toAst(AppLocalizations.of(context)!.error);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  editBottomSheet(context) {
    return showModalBottomSheet(
      backgroundColor: AddSettingsData.themeValue == 2
          ? Colors.white
          : AddSettingsData.themeValue == 1
              ? const Color(0xff000221)
              : Colors.black,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(2.h),
          topLeft: Radius.circular(2.h),
        ),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              curve: Curves.decelerate,
              padding: MediaQuery.of(context).viewInsets,
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.50,
                builder: (context, myScrollController) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Form(
                        key: profileFormKey,
                        autovalidateMode: userProfileInteraction == true
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 3.h,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 35.w,
                                ),
                                Text(
                                  AppLocalizations.of(context)!
                                      .profile_editProfile,
                                  style: TextStyle(
                                    color: AddSettingsData.themeValue == 2
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 29.w,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Image(
                                    image: const AssetImage(
                                        "assets/images/Group 1000002655.png"),
                                    height: 2.5.h,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  showPicker(context, (selectedImage) {
                                    setState(() {
                                      image = selectedImage;
                                    });
                                  });
                                },
                                child: image != null
                                    ? Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: CircleAvatar(
                                              radius: 6.4.h,
                                              backgroundColor: Colors.black,
                                              backgroundImage: Image.file(
                                                image!,
                                                fit: BoxFit.cover,
                                              ).image,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 8.5.h, left: 9.h),
                                            child: CircleAvatar(
                                              radius: 2.5.h,
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.10),
                                              child: Icon(Icons.edit,
                                                  color: Colors.white,
                                                  size: 2.5.h),
                                            ),
                                          ),
                                        ],
                                      )
                                    : getMyDetailResponse.body?.profileUrl ==
                                            null
                                        ? CircleAvatar(
                                            radius: 15.w,
                                            backgroundColor: Colors.grey,
                                            child: const Icon(Icons.camera,
                                                color: Colors.white),
                                          )
                                        : CircleAvatar(
                                            radius: 15.w,
                                            backgroundColor: Colors.grey,
                                            foregroundImage: NetworkImage(
                                                "${getMyDetailResponse.body?.profileUrl}"),
                                            child: const Icon(
                                              Icons.camera,
                                              color: Colors.white,
                                            ),
                                          ),
                              ),
                            ),
                            SizedBox(
                              height: 2.5.h,
                            ),
                            TextFieldWidget(
                              fillColor: AddSettingsData.themeValue == 2
                                  ? const Color(0xffEBEBEB)
                                  : AddSettingsData.themeValue == 1
                                      ? Colors.white.withOpacity(0.10)
                                      : const Color(0xff323232),
                              style: const TextStyle(color: Colors.white),
                              validatorText: (e) =>
                                  Validators().validateName(e ?? ""),
                              hintText: AppLocalizations.of(context)!
                                  .profile_nameHint,
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(2.h),
                                child: Image.asset(
                                  "assets/images/contact.png",
                                  height: 1.h,
                                ),
                              ),
                              suffixIcon: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 2.5.h,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.60),
                                fontStyle: FontStyle.italic,
                                fontSize: 13.sp,
                              ),
                              controller: nameController,
                            ),
                            SizedBox(
                              height: 2.5.h,
                            ),
                            isProfileLoading == false
                                ? GestureDetector(
                                    onTap: () {
                                      userProfileInteraction = true;
                                      if (profileFormKey.currentState!
                                          .validate()) {
                                        isProfileLoading = true;
                                        if (image != null) {
                                          uploadProfileImage();
                                        } else {
                                          changeProfileApi();
                                        }
                                      }
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: double.maxFinite,
                                      height: 7.h,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(3.w),
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
                                                decoration:
                                                    TextDecoration.none),
                                          )),
                                    ),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xffFFCE3C),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  changePassowrdBottomSheet(context) {
    return showModalBottomSheet(
        backgroundColor: AddSettingsData.themeValue == 2
            ? Colors.white
            : AddSettingsData.themeValue == 1
                ? const Color(0xff000221)
                : Colors.black,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(2.h), topLeft: Radius.circular(2.h))),
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              curve: Curves.decelerate,
              padding: MediaQuery.of(context).viewInsets,
              child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.56,
                  builder: (context, myScrollController) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Form(
                          key: passwordFormKey,
                          autovalidateMode: userInteraction == true
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 28.w,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .profile_changePW,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Image(
                                      image: const AssetImage(
                                          "assets/images/Group 1000002655.png"),
                                      height: 2.5.h,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              TextFieldWidget(
                                  fillColor: AddSettingsData.themeValue == 2
                                      ? const Color(0xffEBEBEB)
                                      : AddSettingsData.themeValue == 1
                                          ? Colors.white.withOpacity(0.10)
                                          : const Color(0xff323232),
                                  style: TextStyle(color: Colors.white),
                                  hintText: AppLocalizations.of(context)!
                                      .profile_changeOld,
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(1.8.h),
                                    child: Image.asset(
                                      "assets/images/pass.png",
                                      height: 1.5.h,
                                    ),
                                  ),
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.60),
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13.sp),
                                  controller: oldPasswordController),
                              SizedBox(
                                height: 2.5.h,
                              ),
                              TextFieldWidget(
                                  fillColor: AddSettingsData.themeValue == 2
                                      ? const Color(0xffEBEBEB)
                                      : AddSettingsData.themeValue == 1
                                          ? Colors.white.withOpacity(0.10)
                                          : const Color(0xff323232),
                                  style: const TextStyle(color: Colors.white),
                                  hintText: AppLocalizations.of(context)!
                                      .profile_changeNew,
                                  obscureText: isObscure,
                                  validatorText: (e) =>
                                      Validators().validatePassword(e ?? ""),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(1.8.h),
                                    child: Image.asset(
                                      "assets/images/pass.png",
                                      height: 1.5.h,
                                    ),
                                  ),
                                  suffixIcon: InkWell(
                                      onTap: () {
                                        isObscure = !isObscure;
                                        setState(() {});
                                      },
                                      child: isObscure
                                          ? Icon(
                                              Icons.visibility_off,
                                              color: Colors.white,
                                              size: 2.9.h,
                                            )
                                          : Icon(
                                              Icons.visibility,
                                              color: Colors.white,
                                              size: 2.9.h,
                                            )),
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.60),
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13.sp),
                                  controller: newPasswordController),
                              SizedBox(
                                height: 2.5.h,
                              ),
                              TextFieldWidget(
                                  fillColor: AddSettingsData.themeValue == 2
                                      ? const Color(0xffEBEBEB)
                                      : AddSettingsData.themeValue == 1
                                          ? Colors.white.withOpacity(0.10)
                                          : const Color(0xff323232),
                                  style: const TextStyle(color: Colors.white),
                                  hintText: AppLocalizations.of(context)!
                                      .profile_changeConfirm,
                                  obscureText: isConfirmObscure,
                                  validatorText: (e) => Validators()
                                      .validateConfirmPassword(
                                          confirmPasswordController.text,
                                          newPasswordController.text),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(1.8.h),
                                    child: Image.asset(
                                      "assets/images/pass.png",
                                      height: 1.5.h,
                                    ),
                                  ),
                                  suffixIcon: InkWell(
                                      onTap: () {
                                        isConfirmObscure = !isConfirmObscure;
                                        setState(() {});
                                      },
                                      child: isConfirmObscure
                                          ? Icon(
                                              Icons.visibility_off,
                                              color: Colors.white,
                                              size: 2.9.h,
                                            )
                                          : Icon(
                                              Icons.visibility,
                                              color: Colors.white,
                                              size: 2.9.h,
                                            )),
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.60),
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13.sp),
                                  controller: confirmPasswordController),
                              SizedBox(
                                height: 4.h,
                              ),
                              isPassLoading == false
                                  ? GestureDetector(
                                      onTap: () {
                                        userInteraction = true;
                                        if (passwordFormKey.currentState!
                                            .validate()) {
                                          isPassLoading = true;
                                          changePassApi();
                                        }
                                        setState(() {});
                                      },
                                      child: Container(
                                          width: double.maxFinite,
                                          height: 7.h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3.w),
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
                                                AppLocalizations.of(context)!
                                                    .save,
                                                style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        const Color(0xff1F1F1F),
                                                    decoration:
                                                        TextDecoration.none),
                                              ))),
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(
                                          color: Color(0xffFFCE3C))),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            );
          });
        });
  }
}
