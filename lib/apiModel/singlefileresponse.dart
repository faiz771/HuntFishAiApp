class UploadImageResponse {
  bool? success;
  int? code;
  String? message;
  List<String>? body;

  UploadImageResponse({this.success, this.code, this.message, this.body});

  UploadImageResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    body = json['body'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['code'] = code;
    data['message'] = message;
    data['body'] = body;
    return data;
  }
}
