class SignUpRequest {
  String? fullName;
  String? email;
  String? password;
  String? confirmPassword;
  String? deviceType;

  SignUpRequest(
      {this.fullName,
      this.email,
      this.password,
      this.confirmPassword,
      this.deviceType});

  SignUpRequest.fromJson(Map<String, dynamic> json) {
    fullName = json['full_name'];
    email = json['email'];
    password = json['password'];
    confirmPassword = json['confirm_password'];
    deviceType = json['device_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['full_name'] = fullName;
    data['email'] = email;
    data['password'] = password;
    data['confirm_password'] = confirmPassword;
    data['device_type'] = deviceType;
    return data;
  }
}
