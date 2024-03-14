// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:huntfishai/screen/Billing.dart';
import 'package:huntfishai/screen/ChatLogsScreen.dart';
import 'package:huntfishai/screen/Login/LoginScreen.dart';
import 'package:huntfishai/screen/huntfishAiSettingsData.dart';
import 'package:huntfishai/apiModel/getMasterPrompt/get_master_prompt_response.dart';
import 'package:huntfishai/apiModel/getMyDetail/GetMyDetailResponse.dart';
import 'package:huntfishai/screen/threedots.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../apiModel/createRoom/CreateRoomResponse.dart';
import '../../apiModel/chatSuggestion/chat_suggestion_response.dart';
import '../../apiModel/questionFeedback/questionFeedbackRequest.dart';
import '../../api_collection/api_url_collection.dart';
import '../../api_collection/dio_api_method.dart';
import '../../api_collection/shared_prefrences.dart';
import '../../bloc/openai/openai_bloc.dart';
import '../../bloc/openai/openai_state.dart';
import '../../components/dialog/loading_dialog.dart';
import '../../components/error/error_card.dart';
import '../../components/error/notfound_token.dart';
import '../../components/setting/setting_card.dart';
import '../../constants/constants.dart';
import '../../constants/theme/colors.dart';
import '../../constants/theme/dimen.dart';
import '../../constants/theme/theme.dart';
import '../../models/feature/feature_data.dart';
import '../../service/shred_preference/shared_preference.dart';

class ChatBotScreen extends StatefulWidget {
  final bool? isBrook;
  final String? roomId;
  final FeatureData? data;
  final Map? messageFeedback;

  const ChatBotScreen(
      {Key? key,
      required this.data,
      this.isBrook,
      this.roomId,
      this.messageFeedback})
      : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  ChatCompletionState? chatCompletionState;
  CreateRoomResponse createRoomResponse = CreateRoomResponse();
  ChatSuggestionResponse chatSuggestionResponse = ChatSuggestionResponse();
  GetMasterPromptResponse masterPromptResponse = GetMasterPromptResponse();
  final textEditingController = TextEditingController();
  final textScrollKey = GlobalKey();
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  bool get isIOS => Platform.isIOS;
  bool get isAndroid => Platform.isAndroid;

  configureTts() async {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          print("TTS Initialized");
        });
      });
    }
  }

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak(message, uniqID) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (message != null) {
      if (message!.isNotEmpty) {
        var result = await flutterTts.speak(message!);
        if (result == 1) setState(() => messagePlaying[uniqID] = true);
      }
    }
  }

  Future _stop(uniqID) async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => messagePlaying[uniqID] = false);
  }

  List<String?> chatSuggestions = [];
  String? masterPrompt;

  int roomId = 0;
  bool isLoading = false;
  bool isSubscribed = false;
  int? checkCount = 0;
  bool _visible = true;
  bool hasAsked = false;
  bool useInsights = true;
  Map messageFeedback = {'h3vx': false};
  Map messagePlaying = {'h3vx': false};

  String? get id => null;
  String? findMeText;
  bool findMeValidate = false;

  @override
  void dispose() {
    flutterTts.stop();
    isLoading = false;
    _visible = true;
    isSubscribed = false;
    checkCount = 0;
    hasAsked = false;
    _helpMeFindTextController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _visible = !_visible;
    });
  }

  postFeedback(String? uniqID, String? feedback, String? reply) async {
    try {
      final request = QuestionFeedbackRequest(
          uniqID: uniqID, feedback: feedback, response: reply);
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.questionFeedback, request);
      if (response.code == 200) {}
      textEditingController.clear();
    } catch (e) {
      Timer(const Duration(seconds: 1), () {});
    }
  }

  void submitSearchQuestionToGPT(BuildContext context, String? x, roomId) {
    hasAsked = true;
    _toggle();
    print("question room id: $roomId");
    BlocProvider.of<OpenAIBloc>(context, listen: false).openAIEvent(
        error: () => toast(context, message: "error"),
        question:
            "i am trying to find ${x.toString()}${AddSettingsData.location}",
        isBrook: "2",
        useInsights: useInsights,
        roomId: roomId.toString(),
        userQuestion: "help me find ${x.toString()}",
        scrollController: scrollController,
        event: widget.data?.type ?? "");
  }

  void submitQuestionToGPT(BuildContext context, String? x, roomId) {
    hasAsked = true;
    _toggle();
    print("question room id: $roomId");
    BlocProvider.of<OpenAIBloc>(context, listen: false).openAIEvent(
        error: () => toast(context, message: "error"),
        question: x.toString(),
        useInsights: useInsights,
        isBrook: "2",
        roomId: roomId.toString(),
        userQuestion: x.toString(),
        scrollController: scrollController,
        event: widget.data?.type ?? "");
  }

  getMasterPrompt() async {
    try {
      var response = await DioClient.get().dioGetMethod(ApiUrl.getMasterPrompt);
      masterPromptResponse = GetMasterPromptResponse.fromJson(response.data);

      if (masterPromptResponse.code == 200) {
        masterPrompt = masterPromptResponse.body?[0].prompt_name;
        _shared.setString('masterPrompt',
            masterPromptResponse.body![0].prompt_name.toString());

        setState(() {});
      }
    } catch (err) {
      Timer(const Duration(seconds: 1), () {
        isLoading = false;
        setState(() {});
      });
      print(err);
      DioClient.get().toAst('Error retreiving master prompt!');
    }
  }

  getSuggestions() async {
    try {
      isLoading = true;
      setState(() {});

      var response = await DioClient.get().dioGetMethod(ApiUrl.chatSuggestion);
      chatSuggestionResponse = ChatSuggestionResponse.fromJson(response.data);

      if (chatSuggestionResponse.code == 200) {
        chatSuggestionResponse.body
            ?.forEach((value) => chatSuggestions.add(value.suggestion));
      }
      isLoading = false;
      setState(() {});
    } catch (err) {
      Timer(const Duration(seconds: 1), () {
        isLoading = false;
        setState(() {});
      });
      DioClient.get().toAst('Error retreiving suggestions!');
    }
  }

  Future getSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all[entitlementID] != null &&
          customerInfo.entitlements.all[entitlementID]!.isActive) {
        isSubscribed = true;
      } else {
        isSubscribed = false;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  createRoom() async {
    try {
      _visible = true;
      isLoading = true;
      hasAsked = false;
      setState(() {});
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.createRoom, null);
      createRoomResponse = CreateRoomResponse.fromJson(response.data);
      if (createRoomResponse.code == 200) {
        print("roomId---->${createRoomResponse.body?.room?.id}");
        roomId = createRoomResponse.body?.room?.id ?? 0;
        checkCount = createRoomResponse.body?.checkCount;
        print(isSubscribed);
        if (checkCount == 1 && isSubscribed == false) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const BillingScreen(hitLimit: true)));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatBotScreen(
              isBrook: false,
              roomId: roomId.toString(),
              data: FeatureData(
                  image: "assets/images/q_and_a.png",
                  title: "Question and Answer",
                  imageColor: Colors.indigo,
                  bgColor: Colors.indigoAccent,
                  type: FeatureType.kCompletion),
            ),
          ));
        }
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

  Future<bool> clearMessages() {
    BlocProvider.of<OpenAIBloc>(context, listen: false).clearMessage();
    return Future.value(true);
  }

  ///setup openai sdk
  void initOpenAISDK() {
    Future.delayed(const Duration(milliseconds: 200), () {
      BlocProvider.of<OpenAIBloc>(context, listen: false).initOpenAISdk();
    });
  }

  final _shared = GetIt.instance.get<SharedPreferences>();

  @override
  void initState() {
    setToken();
    initOpenAISDK();
    clearMessages();
    getDetailApi();
    getSuggestions();
    getMasterPrompt();
    configureTts();
    getSubscriptionStatus();
    super.initState();
  }

  GetMyDetailResponse getMyDetailResponse = GetMyDetailResponse();
  final TextEditingController _helpMeFindTextController =
      TextEditingController();

  void getDetailApi() async {
    var response = await DioClient.get().dioGetMethod(ApiUrl.getMyDetail);
    getMyDetailResponse =
        GetMyDetailResponse.fromJson(jsonDecode(response.toString()));
    setState(() {});
  }

  void setToken() async {
    await _shared.setString(SharedRefKey.kAccessToken,
        "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");
  }

  void shareMessage(message) async {
    final shareResult = await Share.shareWithResult(
        "Check out this great answer from https://HuntFish.ai ! \n\n ${message.toString()} \n");

    if (shareResult.status == ShareResultStatus.success) {
      DioClient.get().toAst('Thanks For Sharing!');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: AddSettingsData.themeValue == 2
              ? Colors.white
              : AddSettingsData.themeValue == 1
                  ? const Color(0xff000221)
                  : const Color(0xff1C1C1C),

          //   backgroundColor: Color(0xff1C1C1C),
          body: isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xffFFCE3C)))
              : Stack(
                  children: [
                    Image.asset(
                      "assets/images/joeyVertical.png",
                      height: 35.h,
                      fit: BoxFit.cover,
                      width: double.maxFinite,
                    ),
                    Positioned(
                      top: 6.h,
                      left: 4.w,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 6.2.h,
                          width: 12.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.5.w),
                              color: const Color(0xffFFFFFF).withOpacity(0.10)),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 3.5.h,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6.h,
                      right: 20.w,
                      child: GestureDetector(
                        onTap: () {
                          if (!isLoading) {
                            createRoom();
                          } else {
                            DioClient.get().toAst(
                                'Please wait until the response is finished.');
                          }
                        },
                        child: Container(
                            height: 6.2.h,
                            width: 12.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.5.w),
                                color: const Color(0xffFFFFFF)),
                            child: Padding(
                              padding: EdgeInsets.all(1.h),
                              child: SvgPicture.asset(
                                "assets/images/Group-4.svg",
                              ),
                            )),
                      ),
                    ),
                    Positioned(
                      top: 6.h,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () {
                          if (!isLoading) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ChatLogsScreen(isBrook: widget.isBrook)),
                            );
                          } else {
                            DioClient.get().toAst(
                                'Please wait until the response is completed.');
                          }
                        },
                        child: Container(
                            height: 6.2.h,
                            width: 12.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.5.w),
                                color: const Color(0xffFFCE3C)),
                            child: Padding(
                              padding: EdgeInsets.all(1.h),
                              child: SvgPicture.asset(
                                "assets/images/msg.svg",
                              ),
                            )),
                      ),
                    ),
                    Positioned(
                        top: 29.h,
                        left: 4.w,
                        child: GestureDetector(
                            onDoubleTap: () {
                              var listRandom = BlocProvider.of<OpenAIBloc>(
                                      context,
                                      listen: false)
                                  .getList()
                                  .toString();
                              print(listRandom);
                              DioClient.get().toAst('hello');
                            },
                            child: Text(
                              AppLocalizations.of(context)!.chatbot_headerText,
                              style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
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
                            ))),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 65.h,
                        padding: EdgeInsets.only(bottom: 10.h),
                        decoration: BoxDecoration(
                            // color:Color(0xff1C1C1C),
                            color: AddSettingsData.themeValue == 2
                                ? Colors.white
                                : AddSettingsData.themeValue == 1
                                    ? const Color(0xff000221)
                                    : const Color(0xff1C1C1C),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0.5.h),
                                topRight: Radius.circular(0.5.h))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            hasAsked
                                ? SizedBox(height: 0.25.h)
                                : displaySuggestions(),
                            buildMsgCard(size, context)
                          ],
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: buildTextInput()),
                  ],
                )),
    );
  }

  buildMsgCard(Size size, BuildContext context) {
    return BlocBuilder<OpenAIBloc, OpenAIState>(
      bloc: BlocProvider.of<OpenAIBloc>(context, listen: false),
      builder: (context, state) {
        if (state is ChatCompletionState) {
          return Flexible(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              shrinkWrap: true,
              itemCount: BlocProvider.of<OpenAIBloc>(context, listen: false)
                  .list
                  .length,
              itemBuilder: (context, index) {
                if (state.messages?[index].isBot == true) {
                  var indexID = state.messages?[index].id;
                  messageFeedback[indexID] = messageFeedback[indexID] ??
                      state.messages?[index].feedback;
                  messagePlaying[indexID] = messagePlaying[indexID] ??
                      state.messages?[index].feedback;
                  return buildBotCard(
                    context,
                    state.messages?[index].message,
                    state.messages?[index].id,
                    state.messages?[index].feedback,
                  );
                } else {
                  return buildUserCard(
                      context, state.messages?[index].message, messageTime);
                }
              },
            ),
          );
        }
        return buildBotCard(context, null, 'h3vx', false);
      },
    );
  }

  DateTime messageTime = DateTime.now();

  BlocBuilder<OpenAIBloc, OpenAIState> buildSettingSheet(
      BuildContext context, Size size) {
    return BlocBuilder<OpenAIBloc, OpenAIState>(
      bloc: BlocProvider.of<OpenAIBloc>(context, listen: false),
      builder: (context, state) {
        if (state is OpenSettingState) {
          return state.isOpen
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: SettingCard(
                      height: size.height * .5,
                      tab: () {
                        final bloc =
                            BlocProvider.of<OpenAIBloc>(context, listen: false);
                        bloc.saveToken(
                            success: () {
                              bloc.openSettingSheet(!state.isOpen);
                              bloc.initOpenAISdk();
                            },
                            error: () => errorNotFoundToken(context));
                      }),
                )
              : const SizedBox();
        }
        return const SizedBox();
      },
    );
  }

  BlocBuilder<OpenAIBloc, OpenAIState> buildErrorSheet(
      BuildContext context, Size size) {
    return BlocBuilder<OpenAIBloc, OpenAIState>(
      bloc: BlocProvider.of<OpenAIBloc>(context, listen: false),
      builder: (context, state) {
        if (state is AuthErrorState) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: ErrorCard(
              height: size.height * .5,
              animation: 'assets/animation/error_animation.json',
              title: AppLocalizations.of(context)!.auth_error,
              error: AppLocalizations.of(context)!.auth_error_msg,
            ),
          );
        }
        if (state is RateLimitErrorState) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: ErrorCard(
              height: size.height * .5,
              animation: 'assets/animation/error_animation.json',
              title: AppLocalizations.of(context)!.ratelimit_error,
              error: AppLocalizations.of(context)!.ratelimit_error_msg,
            ),
          );
        }
        if (state is OpenAIServerErrorState) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: ErrorCard(
              height: size.height * .5,
              animation: 'assets/animation/error_animation.json',
              title: AppLocalizations.of(context)!.server_error,
              error: AppLocalizations.of(context)!.server_error_msg,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Padding buildUserCard(
      BuildContext context, String? message, DateTime messageTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
              child: Container(
            padding: EdgeInsets.all(1.h),
            decoration: BoxDecoration(
                color: AddSettingsData.themeValue == 2
                    ? const Color(0xffADADAD)
                    : Colors.white.withOpacity(0.40),
                borderRadius: BorderRadius.circular(1.h),
                border: Border.all(color: Colors.white10)),
            child: MarkdownBody(
                data: message ?? AppLocalizations.of(context)!.user_message,
                selectable: true,
                styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
                styleSheet: MarkdownStyleSheet(
                  codeblockDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: kDarkBgColor,
                  ),
                  listBullet: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  code: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.blue,
                    backgroundColor: Colors.transparent,
                  ),
                  p: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AddSettingsData.themeValue == 2
                            ? Colors.black
                            : Colors.white,
                      ),
                )),
          )),
        ],
      ),
    );
  }

  ScrollController scrollController = ScrollController();

  Padding buildBotCard(
      BuildContext context, String? message, uniqID, feedback) {
    return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding, vertical: kDefaultPadding / 3),
        child: Wrap(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                  child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding / 1.5,
                    vertical: kDefaultPadding / 1.2),
                decoration: BoxDecoration(
                    color: AddSettingsData.themeValue == 2
                        ? const Color(0xffADADAD)
                        : Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(1.2.h),
                    border: Border.all(color: Colors.white10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: MarkdownBody(
                        data: message ??
                            AppLocalizations.of(context)!.chatbot_introduction(
                                getMyDetailResponse.body?.fullName.toString() ??
                                    "there"),
                        selectable: true,
                        onTapText: () {},
                        styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
                        styleSheet: MarkdownStyleSheet(
                          codeblockDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: kDarkBgColor,
                          ),
                          listBullet: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                          code: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.blue,
                            backgroundColor: Colors.transparent,
                          ),
                          p: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AddSettingsData.themeValue == 2
                                    ? Colors.black
                                    : Colors.white,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
          Visibility(
              visible: hasAsked,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Theme(
                          data: ThemeData(useMaterial3: true),
                          child: IconButton(
                              iconSize: 14,
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.share, color: Colors.blue),
                              onPressed: () {
                                shareMessage(message);
                              })),
                      Theme(
                          data: ThemeData(useMaterial3: true),
                          child: IconButton(
                              iconSize: 25,
                              padding: EdgeInsets.zero,
                              icon: messagePlaying[uniqID]
                                  ? const Icon(Icons.stop_circle_rounded,
                                      color: Colors.blue)
                                  : const Icon(Icons.play_arrow,
                                      color: Colors.blue),
                              onPressed: () {
                                flutterTts.setStartHandler(() {
                                  setState(() {
                                    print("playing");
                                    messagePlaying[uniqID] = true;
                                  });
                                });
                                flutterTts.setCompletionHandler(() {
                                  setState(() {
                                    print("Complete");
                                    messagePlaying[uniqID] = false;
                                  });
                                });
                                flutterTts.setErrorHandler((msg) {
                                  setState(() {
                                    print("error: $msg");
                                    messagePlaying[uniqID] = false;
                                  });
                                });

                                if (messagePlaying[uniqID]) {
                                  _stop(uniqID);
                                } else {
                                  // _speak('hello there richard', uniqID);
                                  _speak(message, uniqID);
                                }
                              })),
                      SizedBox(width: 35.w),
                      Visibility(
                          visible: !messageFeedback[uniqID],
                          child: Wrap(children: [
                            Theme(
                                data: ThemeData(useMaterial3: true),
                                child: IconButton(
                                    isSelected: messageFeedback[uniqID],
                                    iconSize: 14,
                                    padding: EdgeInsets.zero,
                                    splashColor: Colors.white,
                                    icon: const Icon(Icons.thumb_up_rounded,
                                        color: Colors.white),
                                    selectedIcon: const Icon(
                                        Icons.thumb_up_rounded,
                                        color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        postFeedback(uniqID, 'positive', "");
                                        messageFeedback[uniqID] = true;
                                      });
                                      DioClient.get().toAst(
                                          AppLocalizations.of(context)!
                                              .feedback_thanks);
                                    })),
                            Theme(
                                data: ThemeData(useMaterial3: true),
                                child: IconButton(
                                    isSelected: messageFeedback[uniqID],
                                    iconSize: 14,
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.thumb_down_rounded,
                                        color: Colors.white),
                                    selectedIcon: const Icon(
                                        Icons.thumb_down_rounded,
                                        color: Colors.blue),
                                    onPressed: () {
                                      textEditingController.clear();
                                      showModalBottomSheet(
                                          context: context,
                                          elevation: 10,
                                          showDragHandle: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight:
                                                    Radius.circular(10.0)),
                                          ),
                                          backgroundColor:
                                              AddSettingsData.themeValue == 1
                                                  ? const Color(0xff000221)
                                                  : const Color(0xff1C1C1C),
                                          isScrollControlled: true,
                                          constraints: BoxConstraints.tight(
                                              Size(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .8)),
                                          builder: (context) {
                                            return Padding(
                                              padding: MediaQuery.of(context)
                                                  .viewInsets,
                                              child: Wrap(children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .chatbot_questionFeedback,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18))),
                                                  ],
                                                ),
                                                SizedBox(height: 2.h),
                                                Wrap(children: [
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 20,
                                                              bottom: 25),
                                                      child: TextFormField(
                                                        onTap: () {
                                                          Scrollable.ensureVisible(
                                                              textScrollKey
                                                                  .currentContext!);
                                                        },
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .sentences,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        maxLines: 5,
                                                        controller:
                                                            textEditingController,
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade300,
                                                        ),
                                                        decoration:
                                                            const InputDecoration(
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 2.0,
                                                                  ),
                                                                ),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            20,
                                                                        vertical:
                                                                            20),
                                                                border:
                                                                    OutlineInputBorder()),
                                                      ))
                                                ]),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (textEditingController
                                                        .text.isNotEmpty) {
                                                      setState(() {
                                                        postFeedback(
                                                            uniqID,
                                                            'negative',
                                                            textEditingController
                                                                .text);
                                                        messageFeedback[
                                                            uniqID] = true;
                                                      });
                                                      Navigator.pop(context);
                                                      DioClient.get().toAst(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .feedback_thanks);
                                                    } else {
                                                      DioClient.get().toAst(
                                                          'Please provide feedback!');
                                                    }
                                                  },
                                                  child: Container(
                                                      key: textScrollKey,
                                                      width: double.maxFinite,
                                                      height: 7.h,
                                                      margin: EdgeInsets.only(
                                                          left: 4.w,
                                                          right: 4.w,
                                                          bottom: 10.h),
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 2,
                                                            blurRadius: 4,
                                                            offset: const Offset(
                                                                4,
                                                                4), // Adjust the values for the desired shadow position
                                                          ),
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3.w),
                                                        color: const Color(
                                                            0xffFFCE3C),
                                                      ),
                                                      child: Container(
                                                          width:
                                                              double.maxFinite,
                                                          height: 7.h,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3.w),
                                                            color: const Color(
                                                                0xffFFCE3C),
                                                          ),
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .feedback_sendFeedback,
                                                            style: TextStyle(
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: const Color(
                                                                    0xff1F1F1F),
                                                                decoration:
                                                                    TextDecoration
                                                                        .none),
                                                          ))),
                                                )
                                              ]),
                                            );
                                          });
                                    }))
                          ]))
                    ]);
              }))
        ]));
  }

  buildSuggestionBoxes(BuildContext context) {
    return Visibility(
        visible: hasAsked ? false : _visible,
        child: Wrap(children: [
          Container(
              padding: const EdgeInsets.only(top: 15, bottom: 1.5, left: 20.0),
              child: Text(AppLocalizations.of(context)!.chatbot_suggestions,
                  style: TextStyle(color: Colors.grey.shade600))),
          Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Container(
                  padding: const EdgeInsets.only(left: 5.0),
                  width: 100.w,
                  height: 8.h,
                  child: ListView(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      children: [
                        Card(
                            color: Colors.transparent,
                            elevation: 0,
                            child: ActionChip(
                                labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                            backgroundColor:
                                                Colors.grey.shade100,
                                            actionsAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            content: Wrap(
                                              children: [
                                                Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .chatbot_lookingFor,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black)),
                                                TextField(
                                                  decoration: InputDecoration(
                                                    errorStyle: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 8.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    errorText: findMeValidate
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .chatbot_lookingForError
                                                        : null,
                                                  ),
                                                  controller:
                                                      _helpMeFindTextController,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      findMeText = value;
                                                    });
                                                  },
                                                )
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .cancel,
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: Colors.black),
                                                ),
                                                onPressed: () {
                                                  _helpMeFindTextController
                                                      .clear();
                                                  findMeValidate = false;
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                },
                                              ),
                                              TextButton(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .submit,
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: Colors.black),
                                                  ),
                                                  onPressed: () {
                                                    if (_helpMeFindTextController
                                                        .text.isEmpty) {
                                                      findMeValidate = true;
                                                      setState(() {});
                                                    } else {
                                                      submitSearchQuestionToGPT(
                                                          context,
                                                          _helpMeFindTextController
                                                              .text,
                                                          widget.roomId);
                                                      Navigator.pop(context);
                                                    }
                                                  }),
                                            ]);
                                      });
                                    },
                                  ).then((val) {
                                    _helpMeFindTextController.clear();
                                    findMeValidate = false;
                                    setState(() {});
                                  });
                                },
                                label: Text(
                                    AppLocalizations.of(context)!
                                        .chatbot_helpMeFind,
                                    style:
                                        const TextStyle(color: Colors.black54)),
                                backgroundColor: Colors.white,
                                elevation: 2.0,
                                padding: const EdgeInsets.all(2.5))),
                        for (var x in chatSuggestions)
                          Card(
                              color: Colors.transparent,
                              elevation: 0,
                              child: ActionChip(
                                  labelPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  onPressed: () {
                                    submitQuestionToGPT(
                                        context, x, widget.roomId);
                                  },
                                  label: Text(x.toString(),
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                  backgroundColor: Colors.white,
                                  elevation: 2.0,
                                  padding: const EdgeInsets.all(2.5)))
                      ])))
        ]));
  }

  buildTextField(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // ignore: sized_box_for_whitespace
        Container(
          width: MediaQuery.sizeOf(context).width * 0.17,
          height: 100.0,
          child: Align(
            alignment: const AlignmentDirectional(0.00, 0.00),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: const AlignmentDirectional(0.00, -1.00),
                  child: Text(AppLocalizations.of(context)!.chatbot_useInsights,
                      style: const TextStyle(fontSize: 9, color: Colors.white)),
                ),
                Theme(
                  data: ThemeData(
                    checkboxTheme: CheckboxThemeData(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    unselectedWidgetColor: Colors.grey,
                  ),
                  child: Checkbox(
                    value: useInsights,
                    onChanged: (newValue) async {
                      setState(() => useInsights = newValue!);
                    },
                    activeColor: Colors.grey,
                    checkColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
            width: MediaQuery.sizeOf(context).width * 0.81,
            padding: EdgeInsets.only(right: 1.w, left: 1.w),
            decoration: BoxDecoration(
                color: AddSettingsData.themeValue == 2
                    ? const Color(0xffADADAD)
                    : AddSettingsData.themeValue == 1
                        ? Colors.white.withOpacity(0.10)
                        : kDarkOffBgColor,
                borderRadius: BorderRadius.circular(2.h),
                border: Border.all(color: Colors.white10)),
            child: TextField(
                controller: BlocProvider.of<OpenAIBloc>(context, listen: false)
                    .getTextInput(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AddSettingsData.themeValue == 2
                        ? Colors.black
                        : Colors.white),
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        submitQuestionToGPT(
                            context,
                            BlocProvider.of<OpenAIBloc>(context, listen: false)
                                .getTextInput()
                                .text,
                            widget.roomId);
                      },
                      icon: Image.asset(
                        "assets/images/Vector-2.png",
                        color: AddSettingsData.themeValue == 2
                            ? Colors.black
                            : Colors.white.withOpacity(0.60),
                      ),
                    ),
                    filled: false,
                    hintText:
                        AppLocalizations.of(context)!.chatbot_questionHint,
                    contentPadding:
                        EdgeInsets.only(top: 2.h, right: 1.w, left: 2.w),
                    hintStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AddSettingsData.themeValue == 2
                            ? Colors.black
                            : Colors.white.withOpacity(0.60),
                        fontStyle: FontStyle.italic),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none)))
      ],
    );
  }

  Padding buildBotCardImage(BuildContext context, String? message) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ///bot icon
          Container(
              margin: const EdgeInsets.only(right: kDefaultPadding / 2),
              padding: const EdgeInsets.all(kDefaultPadding / 1.5),
              decoration: BoxDecoration(
                  color: kButtonColor.withOpacity(.32),
                  borderRadius: BorderRadius.circular(kDefaultPadding / 3),
                  boxShadow: [
                    BoxShadow(
                        color: kButtonColor.withOpacity(.1),
                        offset: const Offset(0, 3),
                        blurRadius: 6.0)
                  ]),
              child: Image.asset(
                'assets/icons/openai_icon.png',
                color: Colors.blueAccent,
                cacheWidth: 32,
                cacheHeight: 32,
                width: kDefaultPadding,
                height: kDefaultPadding,
              )),

          ///content card
          Flexible(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(kDefaultPadding),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    message ?? kExampleImageNetwork,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: kDefaultPadding / 2,
                  right: kDefaultPadding,
                  child: InkWell(
                    onTap: () async {
                      if (message != "" && message != null) {
                        final bloc =
                            BlocProvider.of<OpenAIBloc>(context, listen: false);
                        await Permission.storage.request();
                        await Permission.photos.request();

                        ///show loading dialog
                        if (context.mounted) {
                          loadingDialog(context);
                        }

                        ///start download
                        bloc.downloadImage(message, success: () {
                          toast(context, message: "save image success");
                          Navigator.pop(context);
                        }, error: (err) {
                          toast(context, message: 'save image error :$err');
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(kDefaultPadding / 2),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaY: 10.0, sigmaX: 10.0),
                        child: Container(
                          padding: const EdgeInsets.all(kDefaultPadding / 6),
                          color: Colors.transparent,
                          child: const Icon(
                            Icons.downloading,
                            color: kButtonColor,
                            size: kDefaultPadding,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget displaySuggestions() {
    if (_visible) {
      return buildSuggestions();
    } else {
      return const SizedBox(height: 15);
    }
  }

  Widget buildSuggestions() {
    return buildSuggestionBoxes(context);
  }

  Widget buildTextInput() {
    return BlocBuilder<OpenAIBloc, OpenAIState>(
      builder: (context, state) {
        if (state is ChatCompletionState) {
          return state.showStopButton
              ? const ThreeDots()
              : buildTextField(context);
        }
        return buildTextField(context);
      },
    );
  }

  AppBar buildAppBar(Size size, BuildContext context) {
    return AppBar(
      backgroundColor: kDarkBgColor,
      leading: Padding(
        padding: const EdgeInsets.all(kDefaultPadding / 1.5),
        child: Ink(
          width: size.width * .08,
          height: size.height * .044,
          decoration: BoxDecoration(
              color: kButtonColor.withOpacity(.32),
              borderRadius: BorderRadius.circular(kDefaultPadding / 2),
              boxShadow: [
                BoxShadow(
                    color: kButtonColor.withOpacity(.1),
                    offset: const Offset(0, 3),
                    blurRadius: 6.0)
              ]),
          child: InkWell(
            onTap: () {
              BlocProvider.of<OpenAIBloc>(context, listen: false)
                  .clearMessage();
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new,
                color: kButtonColor, size: kDefaultPadding * 1.2),
          ),
        ),
      ),
      title: Text(widget.data?.title ?? "",
          style: Theme.of(context).textTheme.titleMedium),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding / 1.5),
          child: Ink(
            width: size.width * .09,
            height: size.height * .044,
            decoration: BoxDecoration(
                color: kButtonColor.withOpacity(.32),
                borderRadius: BorderRadius.circular(kDefaultPadding / 2),
                boxShadow: [
                  BoxShadow(
                      color: kButtonColor.withOpacity(.1),
                      offset: const Offset(0, 3),
                      blurRadius: 6.0)
                ]),
            child: InkWell(
              onTap: () {
                final bloc =
                    BlocProvider.of<OpenAIBloc>(context, listen: false);
                bool openSheet = false;
                if (bloc.state is OpenSettingState) {
                  openSheet = (bloc.state as OpenSettingState).isOpen;
                }
                bloc.openSettingSheet(!openSheet);
              },
              child: const Icon(Icons.more_horiz_outlined,
                  color: kButtonColor, size: kDefaultPadding * 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
