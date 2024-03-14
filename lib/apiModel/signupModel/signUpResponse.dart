class SignUpResponse {
  bool? success;
  int? code;
  String? message;
  Body? body;

  SignUpResponse({this.success, this.code, this.message, this.body});

  SignUpResponse.fromJson(Map<String, dynamic> json) {
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
  String? token;
  User? user;

  Body({this.token, this.user});

  Body.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? role;
  int? id;
  String? fullName;
  String? email;
  String? password;

  User({this.role, this.id, this.fullName, this.email, this.password});

  User.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    id = json['id'];
    fullName = json['full_name'];
    email = json['email'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['role'] = role;
    data['id'] = id;
    data['full_name'] = fullName;
    data['email'] = email;
    data['password'] = password;
    return data;
  }
}
