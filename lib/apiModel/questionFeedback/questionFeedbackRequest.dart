class QuestionFeedbackRequest {
  String? uniqID;
  String? feedback;
  String? response;

  QuestionFeedbackRequest({this.uniqID, this.feedback, this.response});

  QuestionFeedbackRequest.fromJson(Map<String, dynamic> json) {
    uniqID = json['uniqID'];
    feedback = json['feedback'];
    response = json['response'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uniqID'] = uniqID;
    data['feedback'] = feedback;
    data['response'] = response;
    return data;
  }
}
