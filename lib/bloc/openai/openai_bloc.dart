import 'dart:async';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:huntfishai/api_collection/api_url_collection.dart';
import 'package:huntfishai/screen/chatbot/chatbot.dart';
import 'package:huntfishai/screen/helperModel/addLocationHelperModel.dart';
import 'package:huntfishai/screen/huntfishAiSettingsData.dart';
import '../../apiModel/UserQuestion/userQuestionRequest.dart';
import '../../apiModel/UserQuestion/userQuestionResponse.dart';
import '../../api_collection/dio_api_method.dart';
import '../../models/message/message.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart';
import '../../service/shred_preference/shared_preference.dart';
import 'openai_state.dart';

@Injectable()
class OpenAIBloc extends Cubit<OpenAIState> {
  ChatBotScreen? chatBotScreen;
  OpenAIBloc() : super(OpenAIInitialState());

  ///[_shared]
  final _shared = GetIt.instance.get<SharedPreferences>();

  ///[_openAI]
  late OpenAI _openAI;

  ///[_txtInput]
  final _txtToken = TextEditingController(
      text: "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");

  ///[getTxtToken]
  TextEditingController getTxtToken() => _txtToken;

  UserQuestionResponse userQuestionResponse = UserQuestionResponse();

  List<Messages> userQuestionAnswers = [];

  // var masterPrompt = _shared.get('masterPrompt');

  void popList() {
    if (userQuestionAnswers.length > 10) {
      var lastSix =
          userQuestionAnswers.reversed.take(10).toList(growable: true);
      userQuestionAnswers = lastSix.reversed.toList(growable: true);
    }
  }

  getList() {
    return userQuestionAnswers;
  }

  void postQuestion(
      {String? message,
      String? isBrook,
      String? uniqID,
      String? question,
      String? userQuestion,
      String? roomId}) async {
    try {
      final request = UserQuestionRequest(
          answer: message,
          type: isBrook,
          latitude: AddLocationData.currentPosition?.latitude.toString(),
          longitude: AddLocationData.currentPosition?.longitude.toString(),
          location: AddLocationData.geographicName,
          userQuestion: userQuestion,
          uniqID: uniqID,
          roomId: roomId,
          question: question);
      var response =
          await DioClient.get().dioPostMethod(ApiUrl.userQuestion, request);
      userQuestionResponse = UserQuestionResponse.fromJson(response.data);
      print('This is response from user question api $userQuestionResponse');
      if (userQuestionResponse.code == 200) {
      } else {
        DioClient.get().toAst(userQuestionResponse.body.toString());
      }
    } catch (e) {
      Timer(const Duration(seconds: 1), () {});
    }
  }

  void onSetToken(
      {required Function() success, required Function() error}) async {
    if (getToken() == "") {
      error();
    } else {
      saveToken(
          success: () {
            _openAI.setToken(getToken());
            success();
          },
          error: error);
    }
  }

  @Deprecated('use textController')
  void tokenChange({required String token}) async {
    if (token == "") {
      await _shared.setString(SharedRefKey.kAccessToken, "");
    }
    await _shared.setString(SharedRefKey.kAccessToken,
        "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");
  }

  ///save token
  ///[saveToken]
  void saveToken(
      {required Function() success, required Function() error}) async {
    if (_txtToken.value.text == "") {
      error();
      await _shared.setString(SharedRefKey.kAccessToken, "");
    } else {
      await _shared.setString(SharedRefKey.kAccessToken,
          "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");
      success();
    }
  }

  String getToken() {
    _txtToken.text = _shared.getString(SharedRefKey.kAccessToken) ?? "";
    return _txtToken.value.text;
  }

  ///[initOpenAISdk]
  void initOpenAISdk() async {
    _openAI = OpenAI.instance.build(
        token: getToken(),
        enableLog: true,
        baseOption: HttpSetup(
            receiveTimeout: const Duration(seconds: 30),
            connectTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30)));
  }

  void openAIEvent(
      {String? event,
      ScrollController? scrollController,
      String? isBrook,
      bool useInsights = true,
      String? question,
      String? userQuestion,
      String? roomId,
      required Function() error}) {
    if (question == "") {
      error();
    } else {
      switch (event) {
        case FeatureType.kCompletion:
          sendWithPrompt(
              scrollController: scrollController,
              userQuestion: userQuestion,
              roomId: roomId,
              useInsights: useInsights,
              isBrook: isBrook,
              question: question);
          break;
        case FeatureType.kGenerateImage:
          generateImage();
          break;
        case FeatureType.kGrammar:
          textDavinci();
          break;
        case FeatureType.kQuestionInterview:
          textDavinci();
          break;
      }
    }
  }

  ///messages of chat
  List<Message> list = [];
  List<Messages> messagesWithPrompt = [];

  void sendWithPrompt(
      {ScrollController? scrollController,
      String? isBrook,
      bool useInsights = true,
      String? question,
      String? userQuestion,
      String? roomId}) async {
    ///update user chat message
    list.add(Message(isBot: false, message: userQuestion));
    emit(ChatCompletionState(
        isBot: false, messages: list, showStopButton: true));
    // setPromptFirst();
    userQuestionAnswers.add(Messages(
        role: Role.user, content: question.toString().replaceAll('null', '')));
    print("question ${question.toString().replaceAll('null', '')}");

    messagesWithPrompt = List<Messages>.from(userQuestionAnswers);
    if (useInsights == true) {
      messagesWithPrompt.insert(
          0,
          Messages(
              role: Role.system,
              content:
                  "${_shared.get('masterPrompt').toString()}\n\n ${AddSettingsData.finalQuestion}"));
    }
    for (var element in messagesWithPrompt) {
      print(element.toJson());
    }

    ///start send request
    final request = ChatCompleteText(
        model: Gpt4ChatModel(), messages: messagesWithPrompt, maxToken: 800);

    getTextInput().text = "";

    _openAI
        .onChatCompletionSSE(request: request, onCancel: onCancel)
        .transform(StreamTransformer.fromHandlers(handleError: handleError))
        .listen((it) {
      Message? message;
      for (final m in list) {
        if (m.id == '${it.id}') {
          message = m;
          list.remove(m);
          break;
        }
      }

      message ??= Message(isBot: false, message: ""); // Initialize if null

      message.message = '${message.message}${it.choices.last.message?.content}';

      print("Updated message: ${message.message}");

      list.add(Message(
          isBot: true,
          id: '${it.id}',
          message: message.message,
          feedback: false));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          final maxScrollExtent = scrollController?.position.maxScrollExtent;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController?.hasClients == true) {
              scrollController?.jumpTo(maxScrollExtent ?? 0);
            }
          });
        });
      });
      emit(ChatCompletionState(
          isBot: true, messages: list, showStopButton: true, uniqID: it.id));
    }, onDone: () {
      userQuestionAnswers.add(Messages(
          role: Role.assistant, content: list.last.message.toString()));
      postQuestion(
          message: list.last.message ?? "",
          question: question.toString().replaceAll('null', ''),
          uniqID: list.last.id,
          isBrook: isBrook,
          roomId: roomId,
          userQuestion: userQuestion);

      popList();
      emit(ChatCompletionState(
          isBot: true, messages: list, showStopButton: false));
    });
  }

  ///generate image with prompt
  void generateImage() async {
    final request = GenerateImage(_txtInput.value.text, 1,
        size: ImageSize.size1024, responseFormat: Format.url);

    ///update user chat message
    list.add(Message(isBot: false, message: getTextInput().value.text));
    emit(ChatCompletionState(
        isBot: false, messages: list, showStopButton: true));

    ///clear text
    _txtInput.text = "";

    try {
      ///start request
      final response = await _openAI.generateImage(request, onCancel: onCancel);

      ///add new message
      list.add(Message(
          isBot: true,
          message: response?.data != [] ? response?.data?.last?.url : ""));
      emit(ChatCompletionState(
          isBot: true, messages: list, showStopButton: false));
    } on OpenAIAuthError catch (_) {
      ///return state auth error
      emit(AuthErrorState());
      emit(ChatCompletionState(
          isBot: true, messages: list, showStopButton: false));
    } on OpenAIRateLimitError catch (_) {
      ///return state rate limit error
      emit(RateLimitErrorState());
      emit(ChatCompletionState(
          isBot: true, messages: list, showStopButton: false));
    } on OpenAIServerError catch (_) {
      ///return state server error
      emit(OpenAIServerErrorState());
      emit(ChatCompletionState(
          isBot: true, messages: list, showStopButton: false));
    }
  }

  void textDavinci() async {
    ///update user chat message
    list.add(Message(isBot: false, message: getTextInput().value.text));
    emit(ChatCompletionState(
        isBot: false, messages: list, showStopButton: true));

    ///setup request body
    final request = CompleteText(
        prompt: _txtInput.value.text,
        maxTokens: 800,
        model: TextDavinci3Model());

    ///clear text
    _txtInput.text = "";

    ///send request
    _openAI
        .onCompletionSSE(request: request, onCancel: onCancel)
        .transform(StreamTransformer.fromHandlers(handleError: handleError))
        .listen((it) {
      ///new message object
      Message? message;
      for (final m in list) {
        if (m.id == it.id) {
          message = m;
          list.remove(m);
          break;
        }
      }

      ///+= message
      message?.message = '${message.message ?? ""}${it.choices.last.text}';

      ///add new message
      list.add(Message(isBot: true, message: message?.message, id: it.id));
      emit(ChatCompletionState(
          isBot: true, messages: list, showStopButton: true));
    }, onDone: () {
      emit(ChatCompletionState(
          isBot: true, messages: list, showStopButton: false));
    });
  }

  void clearMessage() {
    list = [];
    userQuestionAnswers = [];
  }

  CancelData? mCancel;

  void onCancel(CancelData cancelData) {
    mCancel = cancelData;
  }

  void handleError(Object error, StackTrace t, EventSink<dynamic> eventSink) {
    emit(ChatCompletionState(
        isBot: true, messages: list, showStopButton: false));
    if (error is OpenAIAuthError) {
      emit(AuthErrorState());
    }
    if (error is OpenAIRateLimitError) {
      emit(RateLimitErrorState());
    }
    if (error is OpenAIServerError) {
      emit(OpenAIServerErrorState());
    }
  }

  void onStopGenerate() {
    emit(ChatCompletionState(
        isBot: true, messages: list, showStopButton: false));
    mCancel?.cancelToken.cancel("canceled ");
  }

  void openSettingSheet(bool isOpen) {
    isOpen = isOpen;
    emit(OpenSettingState(isOpen: isOpen));
  }

  ///isHasToken
  ///[isHasToken]
  void isHasToken({required Function() success, required Function() error}) {
    if (getToken() == "") {
      error();
    } else {
      success();
    }
  }

  /// text controller
  final _txtInput = TextEditingController();

  TextEditingController getTextInput() => _txtInput;

  void closeTextInput() {
    getTextInput().clear();
  }

  void closeOpenAIError() => emit(CloseOpenAIErrorUI());

  void isFirstSetting(
      {required Function() success, required Function() error}) {
    if (_shared.getBool(SharedRefKey.kIsFistSetting) == true) {
      success();
    } else {
      _shared.setBool(SharedRefKey.kIsFistSetting, true);
      error();
    }
  }

  ///download image from bot chat
  void downloadImage(String url,
      {required Function() success,
      required Function(String message) error}) async {
    try {
      final response = await get(Uri.parse(url));

      /// Get temporary directory
      const path = "/storage/emulated/0/Download";
      final createDirect = Directory("$path/openai");
      if (await createDirect.exists()) {
      } else {
        await createDirect.create(recursive: true);
      }

      /// Create an image name
      var filename = '$path/${DateTime.now().microsecondsSinceEpoch}.png';

      /// Save to filesystem
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);
      if (await file.exists()) {
        success();
      }
    } catch (err) {
      error('path have problem.');
    }
  }

  @override
  Future<void> close() {
    _txtInput.dispose();
    _txtInput.dispose();
    userQuestionAnswers.clear();
    userQuestionAnswers.clear();
    return super.close();
  }
}
