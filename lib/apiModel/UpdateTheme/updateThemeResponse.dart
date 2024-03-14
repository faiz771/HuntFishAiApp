class UpdateThemeResponse {
  bool? success;
  int? code;
  String? message;
  String? body;

  UpdateThemeResponse({this.success, this.code, this.message, this.body});

  UpdateThemeResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    body = json['body'];
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
