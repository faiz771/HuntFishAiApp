import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../apiModel/changePassword/changepasswordResponse.dart';
import '../apiModel/chatLogs/ChatLogsResponse.dart';
import '../api_collection/api_url_collection.dart';
import '../api_collection/dio_api_method.dart';
import 'huntfishAiSettingsData.dart';

class ChatDetailScreen extends StatefulWidget {
  final List<QuesData>? quesDataList;

  const ChatDetailScreen({Key? key, this.quesDataList}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  ChangePasswordResponse deleteChatLogsResponse = ChangePasswordResponse();

  bool isLoading = false;
  final _shared = GetIt.instance.get<SharedPreferences>();

  void shareMessage(message) async {
    final shareResult = await Share.shareWithResult(
        "Check out this great answer from https://HuntFish.ai ! \n\n ${message.toString()} \n");

    if (shareResult.status == ShareResultStatus.success) {
      DioClient.get().toAst('Thanks for sharing!');
    }
  }

  void deleteChatLogs(String roomId) async {
    isLoading = true;
    setState(() {});
    var response = await DioClient.get()
        .dioGetMethod("${ApiUrl.deleteChatLog}?roomId=$roomId");
    deleteChatLogsResponse =
        ChangePasswordResponse.fromJson(jsonDecode(response.toString()));
    if (deleteChatLogsResponse.code == 200) {
      print("deleteChatLogsResponse success");
      Navigator.pop(context, true);
      isLoading = false;
    }
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
          leadingWidth: 15.w,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 7.h,
          actions: [
            GestureDetector(
              onTap: () {
                deleteChatLogs(widget.quesDataList?[0].roomId.toString() ?? "");
              },
              child: Container(
                height: 6.h,
                width: 12.5.w,
                margin: EdgeInsets.only(right: 2.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.5.w),
                    color: const Color(0xff323232)),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 3.h,
                ),
              ),
            ),
          ],
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
            : ListView.builder(
                itemCount: widget.quesDataList?.length ?? 0,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 6.h),
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) => Container(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.w),
                                  color: Colors.white.withOpacity(0.80),
                                ),
                                padding: EdgeInsets.all(1.5.h),
                                margin: EdgeInsets.only(left: 20.w),
                                child: Text(
                                  widget.quesDataList?[index].userQuestion ??
                                      "",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.w),
                                  color: Colors.white.withOpacity(0.60),
                                ),
                                padding: EdgeInsets.all(1.5.h),
                                margin: EdgeInsets.only(right: 20.w),
                                child: Text(
                                  widget.quesDataList?[index].answer ?? "",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Theme(
                                      data: ThemeData(useMaterial3: true),
                                      child: IconButton(
                                          iconSize: 14,
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.share,
                                              color: Colors.blue),
                                          onPressed: () {
                                            shareMessage(widget
                                                .quesDataList?[index].answer);
                                          }))
                                ]),
                          ],
                        ),
                      ),
                    )));
  }
}
