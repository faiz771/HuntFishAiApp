class LoginResponse {
  bool? success;
  int? code;
  String? message;
  Body? body;

  LoginResponse({this.success, this.code, this.message, this.body});

  LoginResponse.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? customer_id;
  int? role;
  String? fullName;
  String? email;
  String? profileUrl;
  String? password;
  String? experience;
  String? location;
  String? latitude;
  String? longitude;
  String? equipment;
  String? preferences;
  String? intrests;
  String? regulatoryUnderstanding;
  String? physicalCapabilities;
  int? isDeleted;
  int? totalQues;
  String? otp;
  String? otpVerify;

  User(
      {this.id,
      this.customer_id,
      this.role,
      this.fullName,
      this.email,
      this.profileUrl,
      this.password,
      this.experience,
      this.location,
      this.latitude,
      this.longitude,
      this.equipment,
      this.preferences,
      this.intrests,
      this.regulatoryUnderstanding,
      this.physicalCapabilities,
      this.isDeleted,
      this.totalQues,
      this.otp,
      this.otpVerify});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customer_id = json['customer_id'];
    role = json['role'];
    fullName = json['full_name'];
    email = json['email'];
    profileUrl = json['profile_url'];
    password = json['password'];
    experience = json['experience'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    equipment = json['equipment'];
    preferences = json['preferences'];
    intrests = json['intrests'];
    regulatoryUnderstanding = json['regulatory_understanding'];
    physicalCapabilities = json['physical_capabilities'];
    isDeleted = json['is_deleted'];
    totalQues = json['total_ques'];
    otp = json['otp'];
    otpVerify = json['otp_verify'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customer_id;
    data['role'] = role;
    data['full_name'] = fullName;
    data['email'] = email;
    data['profile_url'] = profileUrl;
    data['password'] = password;
    data['experience'] = experience;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['equipment'] = equipment;
    data['preferences'] = preferences;
    data['intrests'] = intrests;
    data['regulatory_understanding'] = regulatoryUnderstanding;
    data['physical_capabilities'] = physicalCapabilities;
    data['is_deleted'] = isDeleted;
    data['total_ques'] = totalQues;
    data['otp'] = otp;
    data['otp_verify'] = otpVerify;
    return data;
  }
}
