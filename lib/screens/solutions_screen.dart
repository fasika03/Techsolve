import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/troubleshoot_provider.dart';
import '../routes/app_routes.dart';
import '../utils/app_theme.dart';
import '../widgets/solution_card.dart';

class SolutionsScreen extends StatelessWidget {
  const SolutionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TroubleshootProvider>();
    final solutions = provider.analysis?.solutions ?? [];
    final loading = provider.status == SessionStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Suggested Solutions')),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Ordered from safest and simplest to more advanced. Try them in order.',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ...solutions.asMap().entries.map((entry) {
                    final i = entry.key;
                    final solution = entry.value;
                    return SolutionCard(
                      solution: solution,
                      recommended: i == 0,
                      onTap: () {
                        provider.chooseSolution(solution);
                        Navigator.pushNamed(context, AppRoutes.guide);
                      },
                    );
                  }),
                  if (solutions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No solutions available yet.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
