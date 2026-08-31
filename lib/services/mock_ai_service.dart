import '../models/problem_model.dart';
import '../models/diagnosis_model.dart';
import 'ai_service_interface.dart';

/// Local, offline stand-in for [AiService]. Returns realistic canned
/// troubleshooting content instantly — no API key, no network call, no
/// cost. Lets you build and demo the entire TechSolve flow before you have
/// (or want to spend) real API credits. Swap it out for [AiService] any
/// time by providing a valid Anthropic API key in Settings or `.env`.
class MockAiService implements AiServiceInterface {
  Future<void> _fakeDelay() =>
      Future.delayed(const Duration(milliseconds: 700));

  @override
  Future<List<DiagnosticQuestion>> generateDiagnosticQuestions({
    required String description,
    required String category,
  }) async {
    await _fakeDelay();

    switch (category) {
      case 'Computer':
        return [
          DiagnosticQuestion(text: 'Does this happen every time you use it, or only sometimes?', options: ['Every time', 'Sometimes']),
          DiagnosticQuestion(text: 'Did this start recently, or has it always been like this?', options: ['Started recently', 'Always been like this']),
          DiagnosticQuestion(text: 'Have you restarted the computer since this began?', options: ['Yes', 'No']),
          DiagnosticQuestion(text: 'How much free storage do you have?', options: ['Less than 10 GB', '10–50 GB', 'More than 50 GB']),
        ];
      case 'Phone':
        return [
          DiagnosticQuestion(text: 'Does this happen with one app or all apps?', options: ['One app', 'All apps']),
          DiagnosticQuestion(text: 'Have you restarted your phone recently?', options: ['Yes', 'No']),
          DiagnosticQuestion(text: 'Did this start after a recent update?', options: ['Yes', 'No', 'Not sure']),
          DiagnosticQuestion(text: 'How much free storage do you have?', options: ['Less than 1 GB', '1–5 GB', 'More than 5 GB']),
        ];
      case 'Network':
        return [
          DiagnosticQuestion(text: 'Can another device connect to the same network normally?', options: ['Yes', 'No']),
          DiagnosticQuestion(text: 'Have you restarted your router?', options: ['Yes', 'No']),
          DiagnosticQuestion(text: 'Is this happening on Wi-Fi, mobile data, or both?', options: ['Wi-Fi', 'Mobile data', 'Both']),
          DiagnosticQuestion(text: 'Does it fail on all websites/apps or just one?', options: ['All of them', 'Just one']),
        ];
      case 'Programming':
        return [
          DiagnosticQuestion(text: 'Did this work before, or is it a first-time setup?', options: ['Worked before', 'First-time setup']),
          DiagnosticQuestion(text: 'Did you recently change any dependencies or config?', options: ['Yes', 'No', 'Not sure']),
          DiagnosticQuestion(text: 'Does the error include a file name and line number?', options: ['Yes', 'No']),
          DiagnosticQuestion(text: 'Does it fail locally, in CI, or both?', options: ['Locally', 'CI', 'Both']),
        ];
      case 'Git/GitHub':
        return [
          DiagnosticQuestion(text: 'Are you on the branch you expect to be on?', options: ['Yes', 'Not sure']),
          DiagnosticQuestion(text: 'Have you pulled the latest changes from the remote?', options: ['Yes', 'No']),
          DiagnosticQuestion(text: 'Is this a repo you cloned, or one you\'re setting up fresh?', options: ['Cloned', 'Fresh setup']),
        ];
      default:
        return [
          DiagnosticQuestion(text: 'Does this happen every time, or only sometimes?', options: ['Every time', 'Sometimes']),
          DiagnosticQuestion(text: 'Did this start recently?', options: ['Yes', 'No']),
          DiagnosticQuestion(text: 'Have you tried restarting the device/app?', options: ['Yes', 'No']),
        ];
    }
  }

  @override
  Future<AnalysisResult> analyzeProblem({
    required String description,
    required String category,
    required List<DiagnosticQuestion> answeredQuestions,
  }) async {
    await _fakeDelay();
    return _resultFor(category, excluding: const []);
  }

  @override
  Future<AnalysisResult> continueTroubleshooting({
    required String description,
    required String category,
    required List<DiagnosticQuestion> answeredQuestions,
    required List<String> failedSolutionTitles,
  }) async {
    await _fakeDelay();
    return _resultFor(category, excluding: failedSolutionTitles);
  }

  AnalysisResult _resultFor(String category, {required List<String> excluding}) {
    final all = _bank[category] ?? _bank['Other']!;
    final remaining =
        all.solutions.where((s) => !excluding.contains(s.title)).toList();

    // If we've exhausted the canned list, loop back with a note appended
    // via a fresh generic fallback so the demo never dead-ends.
    final solutions = remaining.isNotEmpty
        ? remaining
        : [
            Solution(
              title: 'Contact a technician',
              description:
                  'The simulated demo solutions have been exhausted for this session — in the real app, Claude would keep generating new candidate fixes.',
              difficulty: 'Easy',
              risk: 'Low',
              estimatedTime: '—',
              steps: [
                'This is mock/demo data with a fixed set of canned solutions.',
                'Add a real Anthropic API key in Settings to get unlimited, tailored solutions from Claude instead.',
              ],
            ),
          ];

    return AnalysisResult(causes: all.causes, solutions: solutions);
  }

  static final Map<String, AnalysisResult> _bank = {
    'Computer': AnalysisResult(
      causes: [
        Cause(cause: 'Too many startup applications', probability: 0.75, explanation: 'Programs launching automatically at boot compete for RAM and CPU before you even open anything.'),
        Cause(cause: 'Low free storage', probability: 0.55, explanation: 'When a drive gets too full, the system has less room to manage memory and temp files efficiently.'),
        Cause(cause: 'Background processes / malware', probability: 0.3, explanation: 'Unwanted background processes can silently consume resources.'),
      ],
      solutions: [
        Solution(
          title: 'Disable unnecessary startup applications',
          description: 'Stop non-essential apps from launching automatically when the computer boots.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '5 minutes',
          steps: [
            'Open Settings.',
            'Select Apps, then Startup.',
            'Find applications you don\'t need running immediately at boot.',
            'Toggle them off.',
            'Restart the computer.',
            'Check whether performance improved.',
          ],
        ),
        Solution(
          title: 'Free up storage space',
          description: 'Clear out temporary files and unused programs to give the system more breathing room.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '10–20 minutes',
          steps: [
            'Open Settings > Storage.',
            'Review the largest categories (Temporary files, Apps, Downloads).',
            'Delete files/apps you no longer need.',
            'Empty the Recycle Bin.',
            'Restart and check performance.',
          ],
        ),
        Solution(
          title: 'Check background applications and processes',
          description: 'Identify and close processes consuming excess CPU or memory.',
          difficulty: 'Medium',
          risk: 'Low',
          estimatedTime: '5–10 minutes',
          steps: [
            'Open Task Manager (Ctrl+Shift+Esc on Windows).',
            'Sort processes by CPU or Memory usage.',
            'Identify anything unfamiliar using significant resources.',
            'Right-click and select "End task" for anything non-essential.',
            'Monitor whether performance improves.',
          ],
          warning: 'Don\'t end system or unfamiliar processes you can\'t identify — research a process name before killing it if you\'re unsure.',
        ),
      ],
    ),
    'Phone': AnalysisResult(
      causes: [
        Cause(cause: 'Background apps consuming battery/memory', probability: 0.7, explanation: 'Apps left running in the background can drain resources even when not actively used.'),
        Cause(cause: 'Outdated app or OS version', probability: 0.4, explanation: 'Bugs in older versions are often fixed in updates.'),
        Cause(cause: 'Storage nearly full', probability: 0.35, explanation: 'Low storage can slow down app performance and background syncing.'),
      ],
      solutions: [
        Solution(
          title: 'Restart your phone',
          description: 'Clears temporary memory and stops runaway background processes.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '2 minutes',
          steps: [
            'Hold the power button until the restart option appears.',
            'Tap Restart.',
            'Wait for the phone to fully boot back up.',
            'Retest the problem.',
          ],
        ),
        Solution(
          title: 'Update or reinstall the affected app',
          description: 'Fixes bugs present in the currently installed version.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '5 minutes',
          steps: [
            'Open your app store.',
            'Search for the affected app.',
            'Tap Update if available; otherwise Uninstall then reinstall it.',
            'Reopen and retest.',
          ],
        ),
        Solution(
          title: 'Clear app cache and free up storage',
          description: 'Removes corrupted temporary files and frees space for smoother operation.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '10 minutes',
          steps: [
            'Go to Settings > Apps.',
            'Select the affected app.',
            'Tap Storage, then Clear Cache.',
            'Review Settings > Storage overall and remove unused photos/apps if nearly full.',
            'Restart the phone and retest.',
          ],
        ),
      ],
    ),
    'Network': AnalysisResult(
      causes: [
        Cause(cause: 'Router/modem issue', probability: 0.6, explanation: 'A router that has been running a long time can develop connectivity issues that a restart clears.'),
        Cause(cause: 'ISP outage', probability: 0.4, explanation: 'The problem may be upstream with your internet service provider rather than your equipment.'),
        Cause(cause: 'DNS misconfiguration', probability: 0.3, explanation: 'Incorrect DNS settings can make it look like "no internet" when connectivity is actually fine.'),
      ],
      solutions: [
        Solution(
          title: 'Restart your router and modem',
          description: 'Clears temporary networking glitches, the single most effective first fix.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '5 minutes',
          steps: [
            'Unplug the router and modem from power.',
            'Wait 30 seconds.',
            'Plug the modem back in and wait for it to fully reconnect.',
            'Plug the router back in and wait for its lights to stabilize.',
            'Retest your connection.',
          ],
        ),
        Solution(
          title: 'Check for an ISP outage',
          description: 'Confirms whether the problem is on your end or your provider\'s.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '5 minutes',
          steps: [
            'Use another device (like your phone on mobile data) to search "[your ISP] outage".',
            'Check your ISP\'s app or status page if they have one.',
            'If there\'s a known outage, wait it out — no local fix will help.',
          ],
        ),
        Solution(
          title: 'Reset network settings / change DNS',
          description: 'Clears misconfigured network settings that can silently block connectivity.',
          difficulty: 'Medium',
          risk: 'Medium',
          estimatedTime: '10 minutes',
          steps: [
            'Open network settings on your device.',
            'Forget the current Wi-Fi network.',
            'Reconnect and re-enter the Wi-Fi password.',
            'If the issue persists, manually set DNS to 8.8.8.8 / 1.1.1.1.',
            'Restart the device and retest.',
          ],
          warning: 'Resetting network settings will remove saved Wi-Fi passwords for other networks too — make sure you know them before proceeding.',
        ),
      ],
    ),
    'Programming': AnalysisResult(
      causes: [
        Cause(cause: 'Dependency version mismatch', probability: 0.6, explanation: 'A recently updated package may be incompatible with the rest of the project.'),
        Cause(cause: 'Missing or stale build cache', probability: 0.4, explanation: 'Old cached build artifacts can cause errors that look unrelated to the real change.'),
        Cause(cause: 'Environment/config difference', probability: 0.35, explanation: 'The code may depend on an environment variable or config file that isn\'t set correctly.'),
      ],
      solutions: [
        Solution(
          title: 'Read the full error message and stack trace',
          description: 'Pin down exactly which file and line is failing before changing anything.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '5 minutes',
          steps: [
            'Scroll to the very first error in the output — later ones are often side effects.',
            'Note the file name and line number.',
            'Open that file and inspect the referenced line and its immediate context.',
          ],
        ),
        Solution(
          title: 'Clean the build cache and reinstall dependencies',
          description: 'Rules out a corrupted or stale local build/cache as the cause.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '5–10 minutes',
          steps: [
            'Delete the build/output folder and dependency lock artifacts (e.g. node_modules, build/, .dart_tool/).',
            'Reinstall dependencies from a clean state.',
            'Re-run the build/tests.',
          ],
        ),
        Solution(
          title: 'Check dependency versions against the project requirements',
          description: 'Finds and fixes an incompatible package version.',
          difficulty: 'Medium',
          risk: 'Low',
          estimatedTime: '10–15 minutes',
          steps: [
            'Open the project\'s dependency manifest.',
            'Compare installed versions against what the manifest specifies.',
            'Pin any mismatched dependency to the expected version.',
            'Reinstall and re-run the build.',
          ],
        ),
      ],
    ),
    'Git/GitHub': AnalysisResult(
      causes: [
        Cause(cause: 'Local branch is behind the remote', probability: 0.65, explanation: 'The remote has commits your local branch doesn\'t, so it rejects a non-fast-forward push.'),
        Cause(cause: 'Wrong branch or remote configured', probability: 0.3, explanation: 'Pushing to the wrong target will fail or produce confusing results.'),
        Cause(cause: 'Authentication issue', probability: 0.25, explanation: 'An expired token or misconfigured credentials can block push/pull operations.'),
      ],
      solutions: [
        Solution(
          title: 'Check your current status and branch',
          description: 'Confirms exactly what state your local repo is in before doing anything else.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '2 minutes',
          steps: [
            'Run: git status',
            'Confirm you\'re on the branch you expect.',
            'Run: git branch -vv to see how far ahead/behind you are from the remote.',
          ],
        ),
        Solution(
          title: 'Pull the latest changes before pushing again',
          description: 'Resolves the most common cause of a rejected push: a remote that has moved ahead.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '5 minutes',
          steps: [
            'Run: git pull origin main (replace "main" with your branch).',
            'Resolve any merge conflicts if prompted — Git will mark conflicting sections in the affected files.',
            'Commit the merge once conflicts are resolved.',
            'Run: git push origin main',
          ],
        ),
        Solution(
          title: 'Verify your remote and authentication',
          description: 'Rules out pushing to the wrong repo or an expired credential.',
          difficulty: 'Medium',
          risk: 'Low',
          estimatedTime: '5–10 minutes',
          steps: [
            'Run: git remote -v to confirm the remote URL is correct.',
            'If using HTTPS, make sure your personal access token hasn\'t expired.',
            'If using SSH, run: ssh -T git@github.com to test the connection.',
            'Retry the push once confirmed.',
          ],
        ),
      ],
    ),
    'Other': AnalysisResult(
      causes: [
        Cause(cause: 'Temporary glitch', probability: 0.5, explanation: 'Many issues resolve after a simple restart of the affected app or device.'),
        Cause(cause: 'Outdated software', probability: 0.35, explanation: 'Running an old version can reintroduce bugs already fixed upstream.'),
      ],
      solutions: [
        Solution(
          title: 'Restart the affected app or device',
          description: 'Clears temporary state that\'s often the real cause.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '2 minutes',
          steps: [
            'Fully close the affected app (not just minimize it).',
            'Reopen it and retest.',
            'If that doesn\'t help, restart the device itself.',
          ],
        ),
        Solution(
          title: 'Check for and install updates',
          description: 'Fixes bugs already resolved in a newer version.',
          difficulty: 'Easy',
          risk: 'Low',
          estimatedTime: '5–10 minutes',
          steps: [
            'Open the relevant app store or settings menu.',
            'Check for available updates.',
            'Install any pending updates.',
            'Restart and retest.',
          ],
        ),
      ],
    ),
  };
}
