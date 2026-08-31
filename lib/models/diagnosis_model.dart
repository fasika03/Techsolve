/// A possible root cause identified during diagnosis.
class Cause {
  final String cause;
  final double probability; // 0.0 - 1.0
  final String explanation;

  Cause({
    required this.cause,
    required this.probability,
    required this.explanation,
  });

  factory Cause.fromJson(Map<String, dynamic> json) => Cause(
        cause: json['cause']?.toString() ?? 'Unknown cause',
        probability: (json['probability'] is num)
            ? (json['probability'] as num).toDouble()
            : 0.5,
        explanation: json['explanation']?.toString() ?? '',
      );
}

/// A suggested fix, ranked from safest/simplest to more advanced.
class Solution {
  final String title;
  final String description;
  final String difficulty; // Easy | Medium | Hard
  final String risk; // Low | Medium | High
  final String estimatedTime;
  final List<String> steps;
  final String? warning; // shown for risky/destructive steps

  Solution({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.risk,
    required this.estimatedTime,
    required this.steps,
    this.warning,
  });

  factory Solution.fromJson(Map<String, dynamic> json) => Solution(
        title: json['title']?.toString() ?? 'Suggested fix',
        description: json['description']?.toString() ?? '',
        difficulty: json['difficulty']?.toString() ?? 'Easy',
        risk: json['risk']?.toString() ?? 'Low',
        estimatedTime: json['estimatedTime']?.toString() ?? '5–10 minutes',
        steps: (json['steps'] as List?)?.map((e) => e.toString()).toList() ?? [],
        warning: json['warning']?.toString(),
      );
}

/// Full result of an AI analysis call: causes + ranked solutions.
class AnalysisResult {
  final List<Cause> causes;
  final List<Solution> solutions;

  AnalysisResult({required this.causes, required this.solutions});

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        causes: (json['causes'] as List? ?? [])
            .map((e) => Cause.fromJson(e as Map<String, dynamic>))
            .toList(),
        solutions: (json['solutions'] as List? ?? [])
            .map((e) => Solution.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
