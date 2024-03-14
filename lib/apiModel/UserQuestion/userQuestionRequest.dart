class UserQuestionRequest {
  String? type;
  String? roomId;
  String? question;
  String? userQuestion;
  String? location;
  String? latitude;
  String? uniqID;
  String? longitude;
  String? answer;

  UserQuestionRequest(
      {this.type,
      this.roomId,
      this.question,
      this.userQuestion,
      this.location,
      this.latitude,
      this.uniqID,
      this.longitude,
      this.answer});

  UserQuestionRequest.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    roomId = json['room_id'];
    question = json['question'];
    userQuestion = json['user_question'];
    location = json['location'];
    latitude = json['latitude'];
    uniqID = json['uniqID'];
    longitude = json['longitude'];
    answer = json['answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['room_id'] = roomId;
    data['question'] = question;
    data['user_question'] = userQuestion;
    data['location'] = location;
    data['latitude'] = latitude;
    data['uniqID'] = uniqID;
    data['longitude'] = longitude;
    data['answer'] = answer;
    return data;
  }
}
