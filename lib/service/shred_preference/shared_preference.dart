import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class SharedPreferenceService {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}

class SharedRefKey {
  static const kAccessToken = 'accessToken';
  static const kGPTVersion = 'gpt_version';
  static const kIsFistSetting = 'is_first_setting';
}
