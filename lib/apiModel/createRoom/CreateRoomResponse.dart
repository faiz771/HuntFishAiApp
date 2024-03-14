class CreateRoomResponse {
  bool? success;
  int? code;
  String? message;
  Body? body;

  CreateRoomResponse({this.success, this.code, this.message, this.body});

  CreateRoomResponse.fromJson(Map<String, dynamic> json) {
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
  Room? room;
  int? checkCount;

  Body({this.room, this.checkCount});

  Body.fromJson(Map<String, dynamic> json) {
    room = json['room'] != null ? Room.fromJson(json['room']) : null;
    checkCount = 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (room != null) {
      data['room'] = room!.toJson();
    }
    data['checkCount'] = checkCount;
    return data;
  }
}

class Room {
  CreatedAt? createdAt;
  int? id;
  int? userId;

  Room({this.createdAt, this.id, this.userId});

  Room.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'] != null
        ? CreatedAt.fromJson(json['created_at'])
        : null;
    id = json['id'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (createdAt != null) {
      data['created_at'] = createdAt!.toJson();
    }
    data['id'] = id;
    data['user_id'] = userId;
    return data;
  }
}

class CreatedAt {
  String? val;

  CreatedAt({this.val});

  CreatedAt.fromJson(Map<String, dynamic> json) {
    val = json['val'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['val'] = val;
    return data;
  }
}
