import 'package:agritungotest/Helper/String.dart';
import 'package:agritungotest/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingProvider {
  late SharedPreferences _sharedPreferences;

  SettingProvider(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  String get email => _sharedPreferences.getString(EMAIL) ?? '';
  String? get userId => _sharedPreferences.getString(SESSION_ID)?? '';
  String get firstName => _sharedPreferences.getString(FIRST_NAME) ?? '';
  String get lastName => _sharedPreferences.getString(LAST_NAME) ?? '';
  String get userName => _sharedPreferences.getString(USERNAME) ?? '';
  // String get sessionId => _sharedPreferences.getString(SESSION_ID) ?? '';
  String get accessToken => _sharedPreferences.getString(ACCESS_TOKEN) ?? '';
  String get refreshToken => _sharedPreferences.getString(REFRESH_TOKEN) ?? '';
  String get status => _sharedPreferences.getString(STATUS) ?? '';
  String get mobile => _sharedPreferences.getString(MOBILE) ?? '';
  String get profileUrl => _sharedPreferences.getString(IMAGE) ?? '';

  //bool get isLogIn => _sharedPreferences.getBool(isLogin) ?? false;

  setPrefrence(String key, String value) {
    _sharedPreferences.setString(key, value);
  }

  Future<String?> getPrefrence(String key) async {
    return _sharedPreferences.getString(key);
  }

  void setPrefrenceBool(String key, bool value) async {
    _sharedPreferences.setBool(key, value);
  }

  setPrefrenceList(String key, String query) async {
    List<String> valueList = await getPrefrenceList(key);
    if (!valueList.contains(query)) {
      if (valueList.length > 4) valueList.removeAt(0);
      valueList.add(query);

      _sharedPreferences.setStringList(key, valueList);
    }
  }

  Future<List<String>> getPrefrenceList(String key) async {
    return _sharedPreferences.getStringList(key) ?? [];
  }

  Future<bool> getPrefrenceBool(String key) async {
    return _sharedPreferences.getBool(key) ?? false;
  }

  Future<void> clearUserSession(BuildContext context) async {
    CUR_USERID = null;

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    context.read<UserProvider>().setPincode('');
    userProvider.setFirstName('');
    userProvider.setFirstName('');
    userProvider.setUserId('');
    userProvider.setAccessToken('');
    userProvider.setRefreshToken('');
    userProvider.setStatus('');
    userProvider.setLastName('');
    userProvider.setName('');
    userProvider.setBalance('');
    userProvider.setCartCount('');
    userProvider.setProfilePic('');
    userProvider.setMobile('');
    userProvider.setEmail('');
    await _sharedPreferences.clear();
  }

  Future<void> saveUserDetail(
      String sessionid,
      String? firstname,
      String? lastname,
      String? accesstoken,
      String? refreshtoken,
      String? mobile,
      String? status,
      String? image,
      BuildContext context) async {
    final waitList = <Future<void>>[];
    waitList.add(_sharedPreferences.setString(SESSION_ID, sessionid));
    waitList.add(_sharedPreferences.setString(FIRST_NAME, firstname?? ''));
    waitList.add(_sharedPreferences.setString(LAST_NAME, lastname??''));
    waitList.add(_sharedPreferences.setString(ACCESS_TOKEN, accesstoken??''));
    waitList.add(_sharedPreferences.setString(REFRESH_TOKEN, refreshtoken??''));
    // waitList.add(_sharedPreferences.setString(EMAIL, email ?? ''));
    waitList.add(_sharedPreferences.setString(MOBILE, mobile ?? ''));
    waitList.add(_sharedPreferences.setString(STATUS, status??''));

    // waitList.add(_sharedPreferences.setString(CITY, city ?? ''));
    // waitList.add(_sharedPreferences.setString(AREA, area ?? ''));
    // waitList.add(_sharedPreferences.setString(ADDRESS, address ?? ''));
    // waitList.add(_sharedPreferences.setString(LATITUDE, latitude ?? ''));
    // waitList.add(_sharedPreferences.setString(LONGITUDE, longitude ?? ''));
    waitList.add(_sharedPreferences.setString(IMAGE, image ?? ''));

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userProvider.setUserId(sessionid ?? '');
    userProvider.setLastName(firstname ?? '');
    userProvider.setFirstName(lastname ?? '');
    userProvider.setAccessToken(accesstoken ?? '');
    userProvider.setRefreshToken(refreshtoken ??'');
    userProvider.setBalance('');
    userProvider.setCartCount('');
    userProvider.setStatus(status ??'');
    userProvider.setMobile(mobile ?? '');
    userProvider.setProfilePic(image ?? '');
    userProvider.setEmail(email ?? '');
    await Future.wait(waitList);
  }
}
