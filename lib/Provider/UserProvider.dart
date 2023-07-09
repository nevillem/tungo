import 'package:flutter/material.dart';

import 'SettingProvider.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '',_firstname='', _lastname='',
      _accesstoken='',
      _refreshtoken='',
      _status='',
      _sessionid='',
      _cartCount = '',
      _curBal = '',
      _mob = '',
      _profilePic = '',
      _email = '';
  String?  _userId = '';

  String? _curPincode = '';

  late SettingProvider settingsProvider;

  String get firstname => _firstname;
  String get lastname => _lastname;
  String get curUserName => _userName;

  String get curPincode => _curPincode ?? '';

  String get curCartCount => _cartCount;

  String get curBalance => _curBal;

  String get mob => _mob;

  String get profilePic => _profilePic;

  String? get userId => _userId;

  String get email => _email;
  String get accesstoken => _accesstoken;
  String get refreshtoken => _refreshtoken;
  String get status => _status;
  String get sessionid => _sessionid;

  void setPincode(String pin) {
    _curPincode = pin;
    notifyListeners();
  }

  void setCartCount(String count) {
    _cartCount = count;
    notifyListeners();
  }

  void setBalance(String bal) {
    _curBal = bal;
    notifyListeners();
  }

  void setName(String count) {
    _userName = count;
    notifyListeners();
  }
  void setFirstName(String count) {
    _firstname = count;
    notifyListeners();
  }
  void setLastName(String count) {
    //settingsProvider.userName=count;
    _lastname = count;
    notifyListeners();
  }
  void setSessionId(String count) {
    //settingsProvider.userName=count;
    _sessionid = count;
    notifyListeners();
  }
void setAccessToken(String count) {
    //settingsProvider.userName=count;
    _accesstoken = count;
    notifyListeners();
  }
void setRefreshToken(String count) {
    //settingsProvider.userName=count;
    _refreshtoken = count;
    notifyListeners();
  }
void setStatus(String count) {
    //settingsProvider.userName=count;
    _status = count;
    notifyListeners();
  }

  void setMobile(String count) {
    _mob = count;
    notifyListeners();
  }

  void setProfilePic(String count) {
    _profilePic = count;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setUserId(String? count) {
    _userId = count;
    notifyListeners();
  }
}

