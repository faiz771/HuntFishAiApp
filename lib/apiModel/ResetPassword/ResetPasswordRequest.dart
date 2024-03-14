class ResetOtpRequest {
  String? email;
  String? password;
  String? confirmPassword;

  ResetOtpRequest({this.email, this.password, this.confirmPassword});

  ResetOtpRequest.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    confirmPassword = json['confirm_password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['confirm_password'] = confirmPassword;
    return data;
  }
}
