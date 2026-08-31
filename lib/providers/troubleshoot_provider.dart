import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import '../models/problem_model.dart';
import '../models/diagnosis_model.dart';
import '../services/ai_service.dart';
import '../services/ai_service_interface.dart';
import '../services/mock_ai_service.dart';
import '../services/storage_service.dart';

enum SessionStatus { idle, loading, error, ready }

/// Holds the state for a single "Problem → Diagnose → Solve → Verify"
/// session and talks to AiService + StorageService on the UI's behalf.
class TroubleshootProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  AiServiceInterface _ai = MockAiService();

  String? apiKey;
  SessionStatus status = SessionStatus.idle;
  String? errorMessage;

  // Current session
  Problem? currentProblem;
  List<DiagnosticQuestion> questions = [];
  AnalysisResult? analysis;
  Solution? chosenSolution;
  final List<String> _failedSolutionTitles = [];

  List<Problem> history = [];

  Future<void> init() async {
    // Prefer a key already saved on-device (entered via Settings). If none
    // exists yet, fall back to ANTHROPIC_API_KEY from .env.
    apiKey = await _storage.getApiKey();
    if (apiKey == null || apiKey!.isEmpty) {
      final envKey = dotenv.maybeGet('ANTHROPIC_API_KEY');
      if (envKey != null && envKey.isNotEmpty) {
        apiKey = envKey;
      }
    }
    // No key on file? Fall back to the local mock service so the app is
    // fully usable — with realistic canned troubleshooting content — even
    // without any API key or network access.
    _ai = hasApiKey ? AiService(apiKey: apiKey!) : MockAiService();
    history = await _storage.getHistory();
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    apiKey = key;
    _ai = key.isEmpty ? MockAiService() : AiService(apiKey: key);
    await _storage.setApiKey(key);
    notifyListeners();
  }

  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;

  /// True while running on canned local data instead of a real AI call.
  bool get usingMockAi => _ai is MockAiService;

  /// Starts a new session: stores the problem, asks the AI for
  /// diagnostic questions.
  Future<void> startProblem({
    required String title,
    required String description,
    required String category,
  }) async {
    status = SessionStatus.loading;
    errorMessage = null;
    analysis = null;
    chosenSolution = null;
    _failedSolutionTitles.clear();
    notifyListeners();

    currentProblem = Problem(
      id: const Uuid().v4(),
      title: title,
      description: description,
      category: category,
    );

    try {
      questions = await _ai.generateDiagnosticQuestions(
        description: description,
        category: category,
      );
      status = SessionStatus.ready;
    } catch (e) {
      status = SessionStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Submits answered diagnostic questions and runs the full analysis.
  Future<void> submitAnswersAndDiagnose() async {
    if (currentProblem == null) return;
    status = SessionStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      analysis = await _ai.analyzeProblem(
        description: currentProblem!.description,
        category: currentProblem!.category,
        answeredQuestions: questions,
      );
      status = SessionStatus.ready;
    } catch (e) {
      status = SessionStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  void chooseSolution(Solution solution) {
    chosenSolution = solution;
    notifyListeners();
  }

  /// Called from the verification screen when the chosen solution did NOT work.
  Future<void> markFailedAndGetNextSolutions() async {
    if (currentProblem == null || chosenSolution == null) return;
    _failedSolutionTitles.add(chosenSolution!.title);
    status = SessionStatus.loading;
    errorMessage = null;
    chosenSolution = null;
    notifyListeners();

    try {
      analysis = await _ai.continueTroubleshooting(
        description: currentProblem!.description,
        category: currentProblem!.category,
        answeredQuestions: questions,
        failedSolutionTitles: _failedSolutionTitles,
      );
      status = SessionStatus.ready;
    } catch (e) {
      status = SessionStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Called from the verification screen when the solution worked.
  Future<void> markSolvedAndSave() async {
    if (currentProblem == null) return;
    currentProblem!.status = 'Solved';
    currentProblem!.solvedWithSolutionTitle = chosenSolution?.title;
    await _storage.saveProblem(currentProblem!);
    history = await _storage.getHistory();
    notifyListeners();
  }

  /// Called if the user gives up / navigates away with the problem unsolved.
  Future<void> markUnsolvedAndSave() async {
    if (currentProblem == null) return;
    currentProblem!.status = 'Unsolved';
    await _storage.saveProblem(currentProblem!);
    history = await _storage.getHistory();
    notifyListeners();
  }

  void resetSession() {
    currentProblem = null;
    questions = [];
    analysis = null;
    chosenSolution = null;
    _failedSolutionTitles.clear();
    status = SessionStatus.idle;
    errorMessage = null;
    notifyListeners();
  }
}
