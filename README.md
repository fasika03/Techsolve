# TechSolve — MVP Scaffold

A real, working Flutter MVP of TechSolve: describe a tech problem → answer a
few diagnostic questions → get AI-ranked causes and step-by-step solutions →
verify the fix → history is saved on-device.

The AI diagnosis is **real**, powered by the Anthropic API (Claude) — not
mocked data. You provide your own API key in-app.

## What's implemented (MVP scope)

- Home screen with category shortcuts
- Problem input (text description + category)
- AI-generated diagnostic questions (`AiService.generateDiagnosticQuestions`)
- AI diagnosis: ranked possible causes + step-by-step solutions
  (`AiService.analyzeProblem`)
- Step-by-step guided walkthrough of the chosen solution
- Verification screen (Yes/No) that either saves the win or asks the AI for
  the **next best solutions**, excluding what already failed
  (`AiService.continueTroubleshooting`)
- Local history of past sessions (solved/unsolved), persisted with
  `shared_preferences`
- Settings screen to store your Anthropic API key on-device

Not yet built (see project doc's "Future Features" / "after MVP" list):
screenshot analysis, voice input, user accounts, multi-language support.

## Project structure

```
lib/
├── main.dart
├── models/            # Problem, DiagnosticQuestion, Cause, Solution, AnalysisResult
├── services/          # ai_service.dart (Anthropic API), storage_service.dart (local persistence)
├── providers/          # TroubleshootProvider — session state shared across screens
├── screens/            # one file per screen (home, problem_input, diagnostic, diagnosis, solutions, guide, verification, history, settings)
├── widgets/            # solution_card.dart
├── routes/             # app_routes.dart
└── utils/              # app_theme.dart, constants.dart
```

## Running it

1. Install Flutter (https://docs.flutter.dev/get-started/install) if you
   haven't already.
2. From this folder:
   ```
   flutter pub get
   flutter run
   ```
3. On first launch, tap the settings icon (top right of Home) and paste an
   Anthropic API key (get one at https://console.anthropic.com/). It's saved
   locally with `shared_preferences`.
4. Tap "Describe a Problem" or a category tile and try it end to end, e.g.:
   *"My laptop is very slow when I open applications."*

## Important: API key handling

Right now the app calls `api.anthropic.com` **directly from the client** for
speed of prototyping — the key lives in `shared_preferences` on-device. This
is fine for testing on your own phone/emulator, but **don't ship this to an
app store as-is**: anyone could extract the key from the app.

Before a real release, move the three `AiService` calls behind your own
backend (a Firebase Cloud Function or Supabase Edge Function that holds the
key server-side and forwards requests), so the key never reaches the client.
The `AiService` class is written so this swap is a one-file change — just
point `_endpoint` at your backend and drop the `x-api-key` header.

## Next steps toward the full MVP list

- Wire `screens/history_screen.dart` up to a detail view (tap a past problem
  to see its original diagnosis/solution)
- Add screenshot upload → the `AiService` can be extended with an image
  content block in the Anthropic API call for the "Screenshot Analysis"
  feature described in the project doc
- Swap `shared_preferences` for Firestore/Supabase once accounts exist, so
  history syncs across devices
