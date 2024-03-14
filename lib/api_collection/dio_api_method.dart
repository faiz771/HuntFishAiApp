import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:huntfishai/api_collection/shared_prefrences.dart';
import 'package:sizer/sizer.dart';
import 'api_url_collection.dart';

class DioClient {
  DioClient._();
  static DioClient? _instance;

  static DioClient get() {
    _instance ??= DioClient._();
    return _instance!;
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiUrl.base,
  ));

  Future dioGetMethod(String url) async {
    print("what is url-->> $url");
    try {
      Response response = await _dio.get(url,
          options: Options(headers: {
            "Authorization":
                "Bearer ${await PreferenceManager.get().getAccessToken()}"
          }));
      if (response.statusCode == 200) {
        return response;
      } else {
        // toAst(response.statusMessage.toString());
        return response;
      }
    } on DioException catch (e) {
      print("STATUSCODE ${e.response?.statusCode}");
      // toAst(e.toString());
      if (e.type == DioExceptionType.badResponse) {
        // toAst(e.type.toString());
        return;
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        toAst('check your connection');
        return;
      }

      if (e.type == DioExceptionType.receiveTimeout) {
        toAst('unable to connect to the server');
        return;
      }

      if (e.type == DioExceptionType.unknown) {
        toAst('No Internet Connection');
        return;
      }
    }
  }

  Future dioPostMethod(String url, dynamic body) async {
    try {
      Response response = await _dio.post(url,
          data: body,
          options: Options(
            sendTimeout: const Duration(milliseconds: 5000),
            headers: {
              "Authorization":
                  "Bearer ${await PreferenceManager.get().getAccessToken()}",
              "Content-Type":
                  "application/json", // Set the content-type to JSON
            },
          ));
      if (response.statusCode == 200) {
        return response;
      } else {
        toAst(response.statusMessage.toString());
      }
    } on DioException catch (e) {
      //toAst(e.toString());
      if (e.type == DioExceptionType.badResponse) {
        toAst(e.type.toString());
        return;
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        toAst('check your connection');
        return;
      }

      if (e.type == DioExceptionType.receiveTimeout) {
        toAst('unable to connect to the server');
        return;
      }

      if (e.type == DioExceptionType.unknown) {
        toAst('No Internet Connection');
        return;
      }
    }
  }

  toAst(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: const Color(0xff236FE2),
        fontSize: 10.sp);
  }
}
