class ApplicationFeedbackRequest {
  String? starRating;
  String? feedback;

  ApplicationFeedbackRequest({this.starRating, this.feedback});

  ApplicationFeedbackRequest.fromJson(Map<String, dynamic> json) {
    starRating = json['starRating'];
    feedback = json['feedback'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['starRating'] = starRating;
    data['feedback'] = feedback;
    return data;
  }
}
