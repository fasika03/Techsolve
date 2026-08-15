import 'package:flutter/material.dart';
import '../models/diagnosis_model.dart';
import '../utils/app_theme.dart';

class SolutionCard extends StatelessWidget {
  final Solution solution;
  final bool recommended;
  final VoidCallback onTap;

  const SolutionCard({
    super.key,
    required this.solution,
    required this.onTap,
    this.recommended = false,
  });

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: recommended
                ? AppColors.primary.withOpacity(0.4)
                : Colors.grey.shade200,
            width: recommended ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recommended)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('RECOMMENDED FIRST',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4)),
              ),
            Text(solution.title,
                style:
                    const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(solution.description,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill('Difficulty: ${solution.difficulty}',
                    difficultyColor(solution.difficulty)),
                _pill('Risk: ${solution.risk}', riskColor(solution.risk)),
                _pill('~${solution.estimatedTime}', AppColors.primary),
              ],
            ),
            if (solution.warning != null && solution.warning!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️ ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(solution.warning!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
