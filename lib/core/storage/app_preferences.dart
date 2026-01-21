import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences _prefs;

  static const String _skipRefreshConfirmationKey = 'skip_refresh_confirmation';
  static const String _displayedCurrencyIdsKey = 'displayed_currency_ids';

  AppPreferences(this._prefs);

  bool get skipRefreshConfirmation =>
      _prefs.getBool(_skipRefreshConfirmationKey) ?? false;

  Future<void> setSkipRefreshConfirmation(bool value) async {
    await _prefs.setBool(_skipRefreshConfirmationKey, value);
  }

  /// Gets the list of displayed currency IDs.
  /// Returns null if no currencies have been saved yet.
  List<String>? get displayedCurrencyIds =>
      _prefs.getStringList(_displayedCurrencyIdsKey);

  /// Saves the list of displayed currency IDs.
  Future<void> setDisplayedCurrencyIds(List<String> ids) async {
    await _prefs.setStringList(_displayedCurrencyIdsKey, ids);
  }
}
