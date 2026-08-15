class Problem {
  final String id;
  final String title;
  final String description;
  final String category;
  String status; // "In Progress" | "Solved" | "Unsolved"
  final DateTime createdAt;
  String? solvedWithSolutionTitle;

  Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.status = 'In Progress',
    DateTime? createdAt,
    this.solvedWithSolutionTitle,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'solvedWithSolutionTitle': solvedWithSolutionTitle,
      };

  factory Problem.fromJson(Map<String, dynamic> json) => Problem(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        category: json['category'],
        status: json['status'] ?? 'In Progress',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        solvedWithSolutionTitle: json['solvedWithSolutionTitle'],
      );
}

/// A diagnostic question TechSolve asks before diagnosing the problem.
class DiagnosticQuestion {
  final String text;
  final List<String> options;
  String? answer;

  DiagnosticQuestion({
    required this.text,
    this.options = const ['Yes', 'No'],
    this.answer,
  });

  factory DiagnosticQuestion.fromJson(Map<String, dynamic> json) =>
      DiagnosticQuestion(
        text: json['text'] ?? '',
        options: (json['options'] as List?)?.map((e) => e.toString()).toList() ??
            const ['Yes', 'No'],
      );
}
