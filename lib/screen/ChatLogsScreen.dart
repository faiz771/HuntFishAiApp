import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:huntfishai/apiModel/changePassword/changepasswordResponse.dart';
import 'package:huntfishai/apiModel/chatLogs/ChatLogsResponse.dart';
import 'package:huntfishai/api_collection/api_url_collection.dart';
import 'package:sizer/sizer.dart';
import '../api_collection/dio_api_method.dart';
import 'ChatDetailScreen.dart';
import 'huntfishAiSettingsData.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatLogsScreen extends StatefulWidget {
  final bool? isBrook;

  const ChatLogsScreen({Key? key, this.isBrook}) : super(key: key);

  @override
  State<ChatLogsScreen> createState() => _ChatLogsScreenState();
}

class _ChatLogsScreenState extends State<ChatLogsScreen> {
  @override
  void initState() {
    print("initWorking:::::");
    getChatLogs();
    super.initState();
  }

  ChatLogsResponse chatLogsResponse = ChatLogsResponse();

  bool isLoading = true;

  ChangePasswordResponse deleteChatLogsResponse = ChangePasswordResponse();

  void deleteChatLogs(String roomId) async {
    var response = await DioClient.get()
        .dioGetMethod("${ApiUrl.deleteChatLog}?roomId=$roomId");
    deleteChatLogsResponse =
        ChangePasswordResponse.fromJson(jsonDecode(response.toString()));
    if (deleteChatLogsResponse.code == 200) {
      print("deleteChatLogsResponse success");
    }
    setState(() {});
  }

  void getChatLogs() async {
    var response = await DioClient.get().dioGetMethod(ApiUrl.chatLogs);
    chatLogsResponse =
        ChatLogsResponse.fromJson(jsonDecode(response.toString()));
    chatLogsResponse.body?.removeWhere((element) =>
        (element.quesData?.isEmpty == true ||
            element.quesData?[0].type == (widget.isBrook == true ? 2 : 1)));
    isLoading = false;
    print("chatLogs->>> ${chatLogsResponse.toJson()}");
    setState(() {});
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
          backgroundColor: AddSettingsData.themeValue == 2
              ? Colors.white
              : AddSettingsData.themeValue == 1
                  ? const Color(0xff000221)
                  : Colors.black,
          centerTitle: true,
          leadingWidth: 15.w,
          elevation: 0,
          toolbarHeight: 7.h,
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
            AppLocalizations.of(context)!.history_appBarTitle,
            style: TextStyle(
              color:
                  AddSettingsData.themeValue == 2 ? Colors.black : Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xffFFCE3C)))
            : chatLogsResponse.body?.isEmpty == true
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.history_noLogs,
                      style: TextStyle(
                          color: const Color(0xff9E9E9E), fontSize: 12.sp),
                    ),
                  )
                : ListView.builder(
                    itemCount: chatLogsResponse.body?.length ?? 0,
                    padding: EdgeInsets.only(top: 2.h),
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) => Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        width: 20.w,
                        padding: EdgeInsets.only(right: 4.w),
                        margin: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 2.w),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFCE3C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.centerRight,
                        child:
                            SvgPicture.asset("assets/images/deleteLogIcon.svg"),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          deleteChatLogs(
                              chatLogsResponse.body?[index].id.toString() ??
                                  "");
                          chatLogsResponse.body?.removeAt(index);
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(1.h),
                        margin: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 2.w),
                        decoration: BoxDecoration(
                          color: AddSettingsData.themeValue == 2
                              ? const Color(0xffEBEBEB)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ChatDetailScreen(
                                            quesDataList: chatLogsResponse
                                                .body?[index]
                                                .quesData))).then((value) {
                              if (value == true) {
                                getChatLogs();
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            decoration: BoxDecoration(
                                color:
                                    const Color(0xffD6FF7E).withOpacity(0.10),
                                borderRadius: BorderRadius.circular(1.h)),
                            padding: EdgeInsets.only(
                                top: 1.5.h, bottom: 1.h, left: 4.w, right: 4.w),
                            child: SvgPicture.asset("assets/images/msg.svg",
                                color: Colors.white),
                          ),
                          title: Text(
                            chatLogsResponse
                                    .body?[index].quesData?[0].userQuestion ??
                                "",
                            style: TextStyle(
                                color: AddSettingsData.themeValue == 2
                                    ? const Color(0xff1C1C1C)
                                    : Colors.white,
                                fontSize: 12.sp),
                          ),
                        ),
                      ),
                    ),
                  ));
  }
}
