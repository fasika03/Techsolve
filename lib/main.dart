import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/troubleshoot_provider.dart';
import 'providers/auth_provider.dart';
import 'routes/app_routes.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loads ANTHROPIC_API_KEY from .env if present. If the file is missing
  // or empty, dotenv just stays empty — the app falls back to whatever key
  // the user enters in Settings, so this never crashes a fresh checkout.
  await dotenv.load(fileName: '.env').catchError((_) {});
  runApp(const TechSolveApp());
}

class TechSolveApp extends StatelessWidget {
  const TechSolveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TroubleshootProvider()..init()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
