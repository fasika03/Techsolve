import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/troubleshoot_provider.dart';
import 'routes/app_routes.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

void main() {
  runApp(const TechSolveApp());
}

class TechSolveApp extends StatelessWidget {
  const TechSolveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TroubleshootProvider()..init(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: AppRoutes.home,
        routes: AppRoutes.routes,
      ),
    );
  }
}
