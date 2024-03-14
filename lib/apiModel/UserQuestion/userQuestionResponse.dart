class UserQuestionResponse {
  bool? success;
  int? code;
  String? message;
  Body? body;

  UserQuestionResponse({this.success, this.code, this.message, this.body});

  UserQuestionResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    body = json['body'] != null ? Body.fromJson(json['body']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['code'] = code;
    data['message'] = message;
    if (body != null) {
      data['body'] = body!.toJson();
    }
    return data;
  }
}

class Body {
  String? type;
  int? id;
  int? userId;
  String? question;
  String? userQuestion;
  String? location;
  String? latitude;
  String? longitude;

  Body(
      {this.type,
        this.id,
        this.userId,
        this.question,
        this.userQuestion,
        this.location,
        this.latitude,
        this.longitude});

  Body.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    userId = json['user_id'];
    question = json['question'];
    userQuestion = json['user_question'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['id'] = id;
    data['user_id'] = userId;
    data['question'] = question;
    data['user_question'] = userQuestion;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
