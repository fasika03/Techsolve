import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/problem_model.dart';
import '../models/diagnosis_model.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

enum SessionStatus { idle, loading, error, ready }

/// Holds the state for a single "Problem → Diagnose → Solve → Verify"
/// session and talks to AiService + StorageService on the UI's behalf.
class TroubleshootProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  AiService? _ai;

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
    apiKey = await _storage.getApiKey();
    if (apiKey != null && apiKey!.isNotEmpty) {
      _ai = AiService(apiKey: apiKey!);
    }
    history = await _storage.getHistory();
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    apiKey = key;
    _ai = AiService(apiKey: key);
    await _storage.setApiKey(key);
    notifyListeners();
  }

  bool get hasApiKey => apiKey != null && apiKey!.isNotEmpty;

  void _requireAi() {
    if (_ai == null) {
      throw AiServiceException('Add your Anthropic API key in Settings first.');
    }
  }

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
      _requireAi();
      questions = await _ai!.generateDiagnosticQuestions(
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
      _requireAi();
      analysis = await _ai!.analyzeProblem(
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
      _requireAi();
      analysis = await _ai!.continueTroubleshooting(
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
