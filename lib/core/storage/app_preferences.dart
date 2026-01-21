import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences _prefs;

  static const String _skipRefreshConfirmationKey = 'skip_refresh_confirmation';

  AppPreferences(this._prefs);

  bool get skipRefreshConfirmation =>
      _prefs.getBool(_skipRefreshConfirmationKey) ?? false;

  Future<void> setSkipRefreshConfirmation(bool value) async {
    await _prefs.setBool(_skipRefreshConfirmationKey, value);
  }
}
