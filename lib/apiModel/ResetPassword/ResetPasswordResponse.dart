class ResetOtpResponse {
  bool? success;
  int? code;
  String? message;

  ResetOtpResponse({this.success, this.code, this.message});

  ResetOtpResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['code'] = code;
    data['message'] = message;
    return data;
  }
}
