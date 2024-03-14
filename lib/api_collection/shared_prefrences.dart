import 'package:shared_preferences/shared_preferences.dart';
import '../helper/shared_prefrence.dart';

class PreferenceManager {
  PreferenceManager._();
  static PreferenceManager? _instance;
  static PreferenceManager get() {
    _instance ??= PreferenceManager._();
    return _instance!;
  }

  Future preferenceSet(key, value) async {
    return (await SharedPreferences.getInstance()).setString(key, value);
  }

  Future getAccessToken() async {
    return (await SharedPreferences.getInstance())
        .getString(PreferenceConstants.accessToken);
  }

  preferenceClear() async {
    (await SharedPreferences.getInstance()).clear();
  }
}
