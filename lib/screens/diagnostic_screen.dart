import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/troubleshoot_provider.dart';
import '../routes/app_routes.dart';
import '../utils/app_theme.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  Future<void> _submit(TroubleshootProvider provider) async {
    final unanswered = provider.questions.where((q) => q.answer == null);
    if (unanswered.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer every question.')),
      );
      return;
    }

    await provider.submitAnswersAndDiagnose();
    if (!mounted) return;

    if (provider.status == SessionStatus.ready) {
      Navigator.pushNamed(context, AppRoutes.diagnosis);
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
      appBar: AppBar(title: const Text('A Few Quick Questions')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: provider.questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final q = provider.questions[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Question ${i + 1}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(q.text,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: q.options.map((opt) {
                            final selected = q.answer == opt;
                            return ChoiceChip(
                              label: Text(opt),
                              selected: selected,
                              onSelected: (_) => setState(() => q.answer = opt),
                              selectedColor: AppColors.primary.withOpacity(0.15),
                              labelStyle: TextStyle(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w400,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.grey.shade300),
                              ),
                              backgroundColor: Colors.white,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: loading ? null : () => _submit(provider),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Diagnose Problem'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
