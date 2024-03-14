class ChatSuggestionResponse {
  bool? success;
  int? code;
  String? message;
  List<Body>? body;

  ChatSuggestionResponse({this.success, this.code, this.message, this.body});

  ChatSuggestionResponse.fromJson(Map<String, dynamic> json) {
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
  String? suggestion;

  Body({this.id, this.suggestion});

  Body.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    suggestion = json['suggestion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['suggestion'] = suggestion;
    return data;
  }
}
