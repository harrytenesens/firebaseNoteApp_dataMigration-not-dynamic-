import 'package:flutter/material.dart';

enum Appmode { authenticated, offline, unauthenticated }

class AppstateManager extends ChangeNotifier {
  Appmode _currentmode = Appmode.unauthenticated;
  Map<String, dynamic> _userdata = {};

  bool isAuthenticated() {
    return _currentmode == Appmode.authenticated;
  }

  bool isoffline() {
    return _currentmode == Appmode.offline;
  }

  bool isUnauthenticated() {
    return _currentmode == Appmode.unauthenticated;
  }

  void switchToAuthenticated(Map<String, dynamic> userData) {
    _currentmode = Appmode.authenticated;
    _userdata = userData;
    notifyListeners();
  }

  // Switch to offline mode
  void switchToOffline(String userName) {
    _currentmode = Appmode.offline;
    _userdata = {
      'first Name': userName,
      'last name': '',
      'email': '',
      'age': ''
    };
    notifyListeners();

    void switchToUnauthenticated() {
      _currentmode = Appmode.unauthenticated;
      _userdata = {};
      notifyListeners();
    }

    // Clear user data
    void clearUserData() {
      _userdata = {};
      notifyListeners();
    }
  }
}
