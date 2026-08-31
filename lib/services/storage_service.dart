import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/problem_model.dart';

/// Handles everything persisted on-device: the user's API key and their
/// troubleshooting history. No backend/database in the MVP — this is all
/// local storage so the app runs standalone.
class StorageService {
  static const _apiKeyPref = 'techsolve_api_key';
  static const _historyPref = 'techsolve_history';

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, key);
  }

  Future<List<Problem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyPref) ?? [];
    return raw
        .map((s) => Problem.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
        .reversed
        .toList(); // most recent first
  }

  Future<void> saveProblem(Problem problem) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyPref) ?? [];
    raw.add(jsonEncode(problem.toJson()));
    await prefs.setStringList(_historyPref, raw);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyPref);
  }
}
