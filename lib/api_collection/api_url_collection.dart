import 'package:flutter/foundation.dart';

class ApiUrl {
  // static String base = kDebugMode
  //     ? "http://192.168.1.140:4435/api/v1/"
  //     : "https://api.huntfish.app/api/v1/";
  static String base = "https://api.huntfish.app/api/v1/";
  static String loginApi = "auth/login";
  static String signUpApi = "auth/sign-up";
  static String getMyDetail = "auth/get-my-detail";
  static String setProfile = "auth/set-your-profile";
  static String userQuestion = "auth/user-question";
  static String questionFeedback = "auth/question-feedback";
  static String applicationFeedback = "auth/application-feedback";
  static String changePassword = "auth/change-password";
  static String allList = "auth/list-by-type";
  static String singleFile = "auth/file-upload";
  static String createRoom = "auth/create-room";
  static String chatLogs = "auth/chat-logs";
  static String chatSuggestion = "auth/chat-suggestions";
  static String getMasterPrompt = "auth/get-prompt";
  static String deleteAcc = "auth/delete-account";
  static String deleteChatLog = "auth/delete-chat-logs";
  static String resendOtp = "auth/resend-otp";
  static String confirmOtp = "auth/confirm-otp";
  static String resetPassword = "auth/reset-password";
  static String updateTheme = "auth/update-theme";
  static String buySubscription = "auth/add-subscription";
}
