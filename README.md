# TechSolve — MVP Scaffold

A real, working Flutter MVP of TechSolve: describe a tech problem → answer a
few diagnostic questions → get AI-ranked causes and step-by-step solutions →
verify the fix → history is saved on-device.

The AI diagnosis is **real**, powered by the Anthropic API (Claude) — not
mocked data. You provide your own API key in-app.

## What's implemented (MVP scope)

- Splash screen (auto-routes to Login or Home based on session)
- Login / Sign Up screen, plus a "Continue as Guest" option
- Home screen with category shortcuts and a personalized greeting
- Settings screen: account info + logout, and Anthropic API key management
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
- Demo mode: if no API key is set, the app runs entirely on canned local
  data (`MockAiService`) — no network, no cost, works offline

Not yet built (see project doc's "Future Features" / "after MVP" list):
screenshot analysis, voice input, multi-language support, real backend
accounts (see the Accounts note below).

## Accounts: local-only for now

Login/Sign Up work for real (name, email, password, validation, error
messages) but accounts are stored on-device via `shared_preferences` — there
is no backend yet, so an account created on one device won't be visible on
another. Passwords are never stored in plain text: each is combined with a
random per-user salt and hashed with SHA-256 before being saved (see
`auth_service.dart`) — a reasonable baseline for a local prototype, though a
real backend should use bcrypt or Argon2 instead. This mirrors the project
doc's plan to eventually use Firebase Authentication or Supabase
Authentication (section 20). Swapping in real auth later only means
rewriting `auth_service.dart` — the screens and `AuthProvider` talk to it
through the same interface and won't need to change.

## Project structure

```
lib/
├── main.dart
├── models/            # Problem, DiagnosticQuestion, Cause, Solution, AnalysisResult
├── services/          # ai_service.dart (Anthropic API), mock_ai_service.dart (offline demo mode),
│                       # auth_service.dart (local accounts), storage_service.dart (history persistence)
├── providers/          # TroubleshootProvider (session state), AuthProvider (login/session state)
├── screens/            # splash, login, home, problem_input, diagnostic, diagnosis, solutions, guide, verification, history, settings
├── widgets/            # solution_card.dart
├── routes/             # app_routes.dart
└── utils/              # app_theme.dart, constants.dart
```

## Running it WITHOUT an API key (demo mode)

You don't need an Anthropic API key to try the app. If no key is found (no
`.env`, nothing saved in Settings), TechSolve automatically falls back to
`MockAiService` — a local, offline stand-in that returns realistic canned
diagnostic questions, causes, and step-by-step solutions per category
(Computer, Phone, Network, Programming, Git/GitHub, Other). No network call,
no cost, works instantly.

You'll see a "Demo mode" banner on the Home screen while this is active.
The moment you add a real key (via `.env` or Settings), the app switches to
real Claude-powered analysis automatically — no code changes needed.

This is genuinely useful for two things: (1) trying the whole app for free
right now, and (2) building/testing new screens later without burning API
credits on every hot reload.

## Running it with real AI

1. Install Flutter (https://docs.flutter.dev/get-started/install) if you
   haven't already.
2. Add your Anthropic API key (get one at https://console.anthropic.com/).
   Two ways to do this — pick whichever fits:

   **Option A — `.env` file (fastest for local dev):**
   Copy `.env.example` to `.env` in the project root and paste your key in:
   ```
   cp .env.example .env
   ```
   Then edit `.env`:
   ```
   ANTHROPIC_API_KEY=sk-ant-your-real-key-here
   ```
   `.env` is already in `.gitignore` — it will never be committed or pushed
   to GitHub.

   **Option B — in-app Settings screen:**
   Skip `.env` and instead tap the gear icon on the Home screen once the app
   is running, then paste your key there. It's saved on-device via
   `shared_preferences`. A key entered in Settings always takes priority
   over `.env`.

3. From this folder:
   ```
   flutter pub get
   flutter run
   ```
4. Tap "Describe a Problem" or a category tile and try it end to end, e.g.:
   *"My laptop is very slow when I open applications."*

## Running on Flutter Web

If you run with `flutter run -d chrome` (or any web target), API calls need
an extra opt-in header because browsers block direct cross-origin calls to
`api.anthropic.com` by default (CORS). This is already handled in
`ai_service.dart` via the `anthropic-dangerous-direct-browser-access: true`
header — if you still see `ClientException: Failed to fetch`, double-check
you're on the latest version of that file and that your API key is actually
set (an empty/invalid key can also surface as a fetch failure in some
browsers).

Note the "dangerous" in that header name: it's Anthropic's way of flagging
that anyone with browser dev tools open can read the API key straight out of
the request. That's an acceptable tradeoff here since it's *your own* key in
*your own* dev build — just don't ship a build like this to end users with
your key baked in.

## Important: API key handling

Right now the app calls `api.anthropic.com` **directly from the client** for
speed of prototyping — the key comes from either `.env` (bundled into the
app at build time) or `shared_preferences` on-device. Both are fine for
testing on your own phone/emulator, but **don't ship this to an app store
as-is**: `.env` gets compiled into the release binary and can be extracted
by anyone who inspects it, same as a key saved in Settings.

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
