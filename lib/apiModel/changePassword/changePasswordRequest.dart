class ChangePasswordRequest {
  String? oldPassword;
  String? newPassword;

  ChangePasswordRequest({this.oldPassword, this.newPassword});

  ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    oldPassword = json['oldPassword'];
    newPassword = json['newPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['oldPassword'] = oldPassword;
    data['newPassword'] = newPassword;
    return data;
  }
}
