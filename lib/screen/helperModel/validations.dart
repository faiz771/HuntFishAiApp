class Validators {
  String? validateName(String? name) {
    if ((name ?? "").trim().isEmpty) {
      return "Please enter full name";
    }
    return null;
  }

  String? validateOther(String? name) {
    if ((name ?? "").trim().isEmpty) {
      return "Field can not empty";
    }
    return null;
  }

  String? validateDob(String? name) {
    if ((name ?? "").trim().isEmpty) {
      return "Please enter your Date of Birth";
    }
    return null;
  }

  String? validateLoc(String? name) {
    if ((name ?? "").trim().isEmpty) {
      return "Location Can't be Empty";
    }
    return null;
  }

  validateEmail(String email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(email.trim())) {
      return false;
    } else {
      return true;
    }
  }

  String? validateEmailForm(String? email) {
    if ((email ?? "").trim().isEmpty) return "Please Enter email";
    return validateEmail(email ?? "") ? null : "Enter a valid email";
  }

  String? validateMobile(String? value) {
    if (value!.isEmpty) {
      return 'Please enter mobile number';
    } else if (value.length < 10) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$');
    if (value!.isEmpty) {
      return 'Please enter password';
    } else {
      if (!regex.hasMatch(value)) {
        return 'Password must be 6 characters which contains one upper case, one lower case, one digit & one special character';
      } else {
        return null;
      }
    }
  }

  validatepassword(String? password) {
    if ((password ?? "").trim().isEmpty) {
      return "Please enter password";
    }
    // else if ((password ?? "").trim().length <= 3) {
    //   return "Password character length must be atleast 4";
    // }
    else {
      return null;
    }
  }

  String? validatePhone(String? phone) {
    if ((phone ?? "").trim().isEmpty) return "Phone number can't be empty";
    if ((phone ?? "").trim().length < 10) {
      return "Phone number should be 10 digits";
    }
    return null;
  }

  String? ValidatePassword(String? password) {
    if ((password ?? "").trim().isEmpty) {
      return "Please enter password";
    } else if ((password ?? "").trim().length <= 5) {
      return "Password must be atleast 6 character long";
    } else {
      return null;
    }
  }

  String? validateConfirmPassword(String confirmPassword, String? newPassword) {
    if (confirmPassword.trim().isEmpty) {
      return "Please enter confirm password";
    } else if (confirmPassword.trim() != newPassword?.trim()) {
      return "Confirm password doesn't match the password";
    }
    return null;
  }

  String? otherField(String? pwd) {
    if (pwd!.trim().isEmpty) return "Field can't be empty";
    return null;
  }

  final int maxWords = 250;

  String? validateWordLimit(String? value) {
    if (value == null) {
      return null;
    }

    List<String> words = value.trim().split(' ');
    if (words.length > maxWords) {
      return 'Maximum $maxWords words allowed';
    }

    return null;
  }
}
