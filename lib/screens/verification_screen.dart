import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/troubleshoot_provider.dart';
import '../routes/app_routes.dart';
import '../utils/app_theme.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  Future<void> _onSolved(BuildContext context, TroubleshootProvider provider) async {
    await provider.markSolvedAndSave();
    if (!context.mounted) return;
    Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 Nice — problem saved as solved.')),
    );
  }

  Future<void> _onNotSolved(BuildContext context, TroubleshootProvider provider) async {
    await provider.markFailedAndGetNextSolutions();
    if (!context.mounted) return;

    if (provider.status == SessionStatus.ready) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.solutions,
        ModalRoute.withName(AppRoutes.diagnosis),
      );
    } else if (provider.status == SessionStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Something went wrong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TroubleshootProvider>();
    final loading = provider.status == SessionStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Result')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.help_outline, size: 56, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                'Did this solve your problem?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                provider.chosenSolution?.title ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 36),
              if (loading)
                const CircularProgressIndicator()
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success),
                    onPressed: () => _onSolved(context, provider),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('YES, SOLVED'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    onPressed: () => _onNotSolved(context, provider),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('NO, STILL NOT WORKING'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
