import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, loggedOut, loggedIn, guest }

/// Holds session state and talks to AuthService on the UI's behalf.
class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();

  AuthStatus status = AuthStatus.unknown;
  String? currentEmail;
  String? currentName;
  String? errorMessage;
  bool isBusy = false;

  bool get isLoggedIn =>
      status == AuthStatus.loggedIn || status == AuthStatus.guest;

  /// Called once at splash time to restore any existing session.
  Future<void> init() async {
    final email = await _auth.getCurrentEmail();
    final isGuest = await _auth.getIsGuest();

    if (email != null) {
      currentEmail = email;
      currentName = await _auth.getNameForEmail(email);
      status = AuthStatus.loggedIn;
    } else if (isGuest) {
      status = AuthStatus.guest;
    } else {
      status = AuthStatus.loggedOut;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _auth.login(email: email, password: password);
      currentEmail = email.trim().toLowerCase();
      currentName = await _auth.getNameForEmail(currentEmail!);
      status = AuthStatus.loggedIn;
      isBusy = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _auth.signUp(name: name, email: email, password: password);
      currentEmail = email.trim().toLowerCase();
      currentName = name.trim();
      status = AuthStatus.loggedIn;
      isBusy = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> continueAsGuest() async {
    await _auth.continueAsGuest();
    status = AuthStatus.guest;
    currentEmail = null;
    currentName = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    status = AuthStatus.loggedOut;
    currentEmail = null;
    currentName = null;
    notifyListeners();
  }
}
