import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thrown for login/signup failures (wrong password, duplicate email, etc).
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

/// Local, on-device account system. There's no backend yet (per the
/// project doc's "Firebase Authentication / Supabase Authentication"
/// options in section 20), so this stores accounts in shared_preferences
/// on THIS device only — signing up on one phone won't be visible on
/// another. It exists so the login flow is fully real and testable now;
/// swap this out for FirebaseAuth or Supabase Auth calls later without
/// touching the screens (they only talk to AuthProvider).
///
/// Passwords are never stored in plain text: each one is combined with a
/// random per-user salt and hashed with SHA-256 before being saved. This
/// is a reasonable baseline for a local-only prototype — a real backend
/// should use a slower, purpose-built algorithm like bcrypt or Argon2
/// instead of a single SHA-256 pass.
class AuthService {
  static const _usersKey = 'techsolve_users';
  static const _currentEmailKey = 'techsolve_current_email';
  static const _isGuestKey = 'techsolve_is_guest';

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }

  Future<List<Map<String, String>>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  Future<void> _saveUsers(List<Map<String, String>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<String?> getCurrentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentEmailKey);
  }

  Future<bool> getIsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey) ?? false;
  }

  Future<String?> getNameForEmail(String email) async {
    final users = await _loadUsers();
    final match = users.where((u) => u['email'] == email);
    return match.isEmpty ? null : match.first['name'];
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (name.trim().isEmpty || normalizedEmail.isEmpty || password.isEmpty) {
      throw AuthException('Please fill in every field.');
    }
    if (!normalizedEmail.contains('@')) {
      throw AuthException('Enter a valid email address.');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }

    final users = await _loadUsers();
    if (users.any((u) => u['email'] == normalizedEmail)) {
      throw AuthException('An account with that email already exists.');
    }

    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);
    users.add({
      'name': name.trim(),
      'email': normalizedEmail,
      'salt': salt,
      'passwordHash': passwordHash,
    });
    await _saveUsers(users);
    await _setSession(email: normalizedEmail, isGuest: false);
  }

  Future<void> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _loadUsers();
    final match = users.where((u) => u['email'] == normalizedEmail);

    if (match.isEmpty) {
      throw AuthException('No account found with that email.');
    }

    final user = match.first;
    final expectedHash = user['passwordHash'];
    final salt = user['salt'];
    if (salt == null || expectedHash == null) {
      throw AuthException('This account needs to be reset — please sign up again.');
    }
    if (_hashPassword(password, salt) != expectedHash) {
      throw AuthException('Incorrect password.');
    }

    await _setSession(email: normalizedEmail, isGuest: false);
  }

  Future<void> continueAsGuest() async {
    await _setSession(email: null, isGuest: true);
  }

  Future<void> _setSession({required String? email, required bool isGuest}) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_currentEmailKey);
    } else {
      await prefs.setString(_currentEmailKey, email);
    }
    await prefs.setBool(_isGuestKey, isGuest);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentEmailKey);
    await prefs.setBool(_isGuestKey, false);
  }
}
