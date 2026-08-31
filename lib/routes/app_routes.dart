import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/problem_input_screen.dart';
import '../screens/diagnostic_screen.dart';
import '../screens/diagnosis_screen.dart';
import '../screens/solutions_screen.dart';
import '../screens/guide_screen.dart';
import '../screens/verification_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const problemInput = '/problem-input';
  static const diagnostic = '/diagnostic';
  static const diagnosis = '/diagnosis';
  static const solutions = '/solutions';
  static const guide = '/guide';
  static const verification = '/verification';
  static const history = '/history';
  static const settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    home: (_) => const HomeScreen(),
    problemInput: (_) => const ProblemInputScreen(),
    diagnostic: (_) => const DiagnosticScreen(),
    diagnosis: (_) => const DiagnosisScreen(),
    solutions: (_) => const SolutionsScreen(),
    guide: (_) => const GuideScreen(),
    verification: (_) => const VerificationScreen(),
    history: (_) => const HistoryScreen(),
    settings: (_) => const SettingsScreen(),
  };
}
