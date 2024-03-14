class ApplicationFeedbackResponse {
  bool? success;
  int? code;
  String? message;

  ApplicationFeedbackResponse({this.success, this.code, this.message});

  ApplicationFeedbackResponse.fromJson(Map<String, dynamic> json) {
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
