class ChatLogsResponse {
  bool? success;
  int? code;
  String? message;
  List<Body>? body;

  ChatLogsResponse({this.success, this.code, this.message, this.body});

  ChatLogsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['body'] != null) {
      body = <Body>[];
      json['body'].forEach((v) {
        body!.add(Body.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['code'] = code;
    data['message'] = message;
    if (body != null) {
      data['body'] = body!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Body {
  int? id;
  int? userId;
  String? createdAt;
  String? updatedAt;
  List<QuesData>? quesData;

  Body({this.id, this.userId, this.createdAt, this.updatedAt, this.quesData});

  Body.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['ques_data'] != null) {
      quesData = <QuesData>[];
      json['ques_data'].forEach((v) {
        quesData!.add(QuesData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (quesData != null) {
      data['ques_data'] = quesData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class QuesData {
  int? id;
  int? type;
  int? roomId;
  String? userId;
  String? question;
  String? userQuestion;
  String? answer;
  String? location;
  String? latitude;
  String? longitude;
  String? createdAt;
  String? updatedAt;

  QuesData(
      {this.id,
      this.type,
      this.roomId,
      this.userId,
      this.question,
      this.userQuestion,
      this.answer,
      this.location,
      this.latitude,
      this.longitude,
      this.createdAt,
      this.updatedAt});

  QuesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    roomId = json['room_id'];
    userId = json['user_id'];
    question = json['question'];
    userQuestion = json['user_question'];
    answer = json['answer'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['room_id'] = roomId;
    data['user_id'] = userId;
    data['question'] = question;
    data['user_question'] = userQuestion;
    data['answer'] = answer;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
