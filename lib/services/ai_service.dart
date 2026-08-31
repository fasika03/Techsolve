import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/problem_model.dart';
import '../models/diagnosis_model.dart';
import 'ai_service_interface.dart';

/// Thrown when the AI call fails or returns something we can't parse.
class AiServiceException implements Exception {
  final String message;
  AiServiceException(this.message);
  @override
  String toString() => message;
}

/// Wraps calls to the Anthropic Messages API and turns TechSolve's
/// troubleshooting steps into structured JSON the UI can render.
///
/// NOTE ON API KEYS: this MVP calls the Anthropic API directly from the
/// client for speed of prototyping. For a real release, move these calls
/// behind your own backend (Firebase Cloud Functions / Supabase Edge
/// Functions) so the API key never ships inside the app binary.
class AiService implements AiServiceInterface {
  static const String _endpoint = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-6';
  static const String _anthropicVersion = '2023-06-01';

  final String apiKey;
  AiService({required this.apiKey});

  Future<Map<String, dynamic>> _call(String systemPrompt, String userPrompt,
      {int maxTokens = 1500}) async {
    if (apiKey.trim().isEmpty) {
      throw AiServiceException(
          'No API key set. Add your Anthropic API key in Settings.');
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': _anthropicVersion,
        // Required when calling the API directly from a browser (Flutter
        // web). Without this header the request is blocked by CORS before
        // it even reaches Anthropic, surfacing as "Failed to fetch". Not
        // needed on Android/iOS/desktop, but harmless there too.
        'anthropic-dangerous-direct-browser-access': 'true',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': maxTokens,
        'system': systemPrompt,
        'messages': [
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw AiServiceException(
          'AI request failed (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body);
    final content = data['content'] as List?;
    final text = content
            ?.firstWhere((b) => b['type'] == 'text', orElse: () => null)?['text']
        as String?;

    if (text == null) {
      throw AiServiceException('AI response had no text content.');
    }

    final cleaned = text
        .trim()
        .replaceAll(RegExp(r'^```json'), '')
        .replaceAll(RegExp(r'^```'), '')
        .replaceAll(RegExp(r'```$'), '')
        .trim();

    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      throw AiServiceException('Could not parse AI response as JSON:\n$text');
    }
  }

  /// Step 1: given a freeform problem description, ask 3–5 short
  /// diagnostic questions to narrow down the cause.
  @override
  Future<List<DiagnosticQuestion>> generateDiagnosticQuestions({
    required String description,
    required String category,
  }) async {
    const system = '''
You are TechSolve, a calm and precise technology troubleshooting assistant.
Given a user's problem, ask 3 to 5 short diagnostic questions that would help
narrow down the cause. Prefer simple Yes/No or short multiple-choice
questions a non-technical user can answer instantly. Do not diagnose yet.

Respond with ONLY valid JSON, no preamble, no markdown fences, in this shape:
{"questions": [{"text": "...", "options": ["Yes", "No"]}, ...]}
''';
    final user =
        'Category: $category\nProblem description: $description';

    final json = await _call(system, user, maxTokens: 800);
    final list = (json['questions'] as List? ?? [])
        .map((e) => DiagnosticQuestion.fromJson(e as Map<String, dynamic>))
        .toList();

    if (list.isEmpty) {
      throw AiServiceException('AI returned no diagnostic questions.');
    }
    return list;
  }

  /// Step 2: given the problem + answered diagnostic questions, produce
  /// ranked possible causes and step-by-step solutions (safest first).
  @override
  Future<AnalysisResult> analyzeProblem({
    required String description,
    required String category,
    required List<DiagnosticQuestion> answeredQuestions,
  }) async {
    const system = '''
You are TechSolve, a technology troubleshooting assistant. You have a user's
problem description and their answers to diagnostic questions. Identify the
most likely causes (ranked by probability) and 2 to 4 candidate solutions,
ordered from safest/simplest to more advanced.

For every solution give clear numbered step-by-step instructions a beginner
can follow exactly, difficulty (Easy/Medium/Hard), risk (Low/Medium/High),
and an estimated time. If a solution could cause data loss or is otherwise
risky, include a short "warning" field telling the user to back up data first.

Respond with ONLY valid JSON, no preamble, no markdown fences, in this shape:
{
  "causes": [{"cause": "...", "probability": 0.8, "explanation": "..."}],
  "solutions": [
    {
      "title": "...",
      "description": "...",
      "difficulty": "Easy",
      "risk": "Low",
      "estimatedTime": "5-10 minutes",
      "steps": ["Step 1 ...", "Step 2 ..."],
      "warning": null
    }
  ]
}
''';

    final qa = answeredQuestions
        .map((q) => '- ${q.text} => ${q.answer ?? "no answer"}')
        .join('\n');
    final user =
        'Category: $category\nProblem description: $description\n\nDiagnostic answers:\n$qa';

    final json = await _call(system, user, maxTokens: 2000);
    return AnalysisResult.fromJson(json);
  }

  /// Step 3: called when the chosen solution did NOT fix the problem.
  /// Excludes the failed solution and asks for the next best options.
  @override
  Future<AnalysisResult> continueTroubleshooting({
    required String description,
    required String category,
    required List<DiagnosticQuestion> answeredQuestions,
    required List<String> failedSolutionTitles,
  }) async {
    const system = '''
You are TechSolve, a technology troubleshooting assistant. The user already
tried one or more suggested solutions and their problem is still NOT solved.
Do not repeat any previously tried solution. Reconsider the possible causes
given that those fixes did not work, and suggest 2 to 3 new solutions,
ordered from safest/simplest to more advanced, in the same JSON shape as
before.

Respond with ONLY valid JSON, no preamble, no markdown fences, in this shape:
{
  "causes": [{"cause": "...", "probability": 0.8, "explanation": "..."}],
  "solutions": [
    {
      "title": "...",
      "description": "...",
      "difficulty": "Easy",
      "risk": "Low",
      "estimatedTime": "5-10 minutes",
      "steps": ["Step 1 ...", "Step 2 ..."],
      "warning": null
    }
  ]
}
''';

    final qa = answeredQuestions
        .map((q) => '- ${q.text} => ${q.answer ?? "no answer"}')
        .join('\n');
    final tried = failedSolutionTitles.map((t) => '- $t').join('\n');
    final user =
        'Category: $category\nProblem description: $description\n\nDiagnostic answers:\n$qa\n\nSolutions already tried that did NOT work:\n$tried';

    final json = await _call(system, user, maxTokens: 2000);
    return AnalysisResult.fromJson(json);
  }
}
