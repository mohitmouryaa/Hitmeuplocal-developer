import 'package:flutter/material.dart';

enum AuthStatus {
  guest,
  authenticated,
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.guest;

  AuthStatus get status => _status;

  bool get isGuest => _status == AuthStatus.guest;

  void login() {
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  void logout() {
    _status = AuthStatus.guest;
    notifyListeners();
  }
}
