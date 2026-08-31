import '../models/problem_model.dart';
import '../models/diagnosis_model.dart';

/// Common contract for anything that can run TechSolve's three
/// troubleshooting steps. Implemented by [AiService] (real Anthropic API
/// calls) and [MockAiService] (canned local responses, no key/network
/// needed) so the provider and screens don't care which one is active.
abstract class AiServiceInterface {
  Future<List<DiagnosticQuestion>> generateDiagnosticQuestions({
    required String description,
    required String category,
  });

  Future<AnalysisResult> analyzeProblem({
    required String description,
    required String category,
    required List<DiagnosticQuestion> answeredQuestions,
  });

  Future<AnalysisResult> continueTroubleshooting({
    required String description,
    required String category,
    required List<DiagnosticQuestion> answeredQuestions,
    required List<String> failedSolutionTitles,
  });
}
