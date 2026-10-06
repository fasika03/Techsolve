# 🛠️ TechSolve — MVP Scaffold

A real, working Flutter MVP of TechSolve: describe a tech problem → answer a few diagnostic questions → get AI-ranked causes and step-by-step solutions → verify the fix → history is saved on-device.

The AI diagnosis is **real**, powered by the Anthropic API (Claude) — not mocked data. You can provide your own API key in-app.

## 🚀 What's implemented (MVP scope)

* 🌟 Splash screen with automatic Login/Home routing
* 🔐 Login / Sign Up
* 👤 Continue as Guest
* 🏠 Home screen with category shortcuts and personalized greeting
* ⚙️ Settings screen

  * Account information
  * Logout
  * Anthropic API key management
* 📝 Problem input with description and category
* 🤖 AI-generated diagnostic questions
* 🔍 AI diagnosis with ranked possible causes
* 💡 Step-by-step troubleshooting solutions
* 🧭 Guided solution walkthrough
* ✅ Verification of the solution
* 🔄 Next-best solutions when the previous solution fails
* 📚 Local troubleshooting history
* 💾 History saved using `shared_preferences`
* 📴 Offline Demo Mode
* 🧪 `MockAiService` for testing without API costs

## 🤖 AI Troubleshooting

TechSolve uses Claude through the Anthropic API for:

* 🧠 Generating diagnostic questions
* 🔎 Analyzing technical problems
* 📊 Ranking possible causes
* 🛠️ Generating step-by-step solutions
* 🔄 Finding alternative solutions when a fix fails

Main service methods:

```text
AiService.generateDiagnosticQuestions
AiService.analyzeProblem
AiService.continueTroubleshooting
```

## 📴 Demo Mode

You **do not need an Anthropic API key** to try TechSolve.

When no API key is configured, TechSolve automatically uses `MockAiService`.

Supported categories include:

* 💻 Computer
* 📱 Phone
* 🌐 Network
* 👨‍💻 Programming
* 🔀 Git/GitHub
* 🔧 Other

Demo Mode works:

* ⚡ Instantly
* 📴 Offline
* 💰 Without API costs
* 🧪 Without a network connection

A **Demo Mode** indicator appears on the Home screen while the mock service is active.

## 🔐 Accounts

Login and Sign Up currently work locally with:

* 👤 Name
* 📧 Email
* 🔑 Password
* ✅ Validation
* ⚠️ Error messages
* 🚪 Logout
* 🔄 Session management

Accounts are stored locally using `shared_preferences`.

There is currently **no cloud authentication**, so an account created on one device will not be available on another device.

Passwords are not stored as plain text. Each password uses a random per-user salt and SHA-256 hashing.

> ⚠️ For production, authentication should be moved to a secure backend using Firebase Authentication, Supabase Authentication, or another production-grade authentication system.

## 📁 Project Structure

```text
lib/
├── main.dart
│
├── models/
│   └── Problem, DiagnosticQuestion, Cause, Solution, AnalysisResult
│
├── services/
│   ├── ai_service.dart
│   ├── mock_ai_service.dart
│   ├── auth_service.dart
│   └── storage_service.dart
│
├── providers/
│   ├── troubleshoot_provider.dart
│   └── auth_provider.dart
│
├── screens/
│   ├── splash
│   ├── login
│   ├── home
│   ├── problem_input
│   ├── diagnostic
│   ├── diagnosis
│   ├── solutions
│   ├── guide
│   ├── verification
│   ├── history
│   └── settings
│
├── widgets/
│   └── solution_card.dart
│
├── routes/
│   └── app_routes.dart
│
└── utils/
    ├── app_theme.dart
    └── constants.dart
```

## ⚡ Getting Started

### 1️⃣ Install Flutter

Install Flutter if you haven't already:

[Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

### 2️⃣ Get the project

Clone the repository and enter the project directory:

```bash
git clone https://github.com/fasika03/Techsolve.git
cd Techsolve
```

### 3️⃣ Install dependencies

```bash
flutter pub get
```

### 4️⃣ Run the application

```bash
flutter run
```

## 🔑 Configure Anthropic API

Get an API key from the [Anthropic Console](https://console.anthropic.com/).

### Option A — `.env`

Copy the example file:

```bash
cp .env.example .env
```

Then add your key:

```env
ANTHROPIC_API_KEY=sk-ant-your-real-key-here
```

Make sure `.env` is included in `.gitignore`.

### Option B — In-App Settings

Run TechSolve and open:

**🏠 Home → ⚙️ Settings → 🔑 Anthropic API Key**

Paste your API key and save it.

The key is stored locally using `shared_preferences`.

## 🌐 Flutter Web

Run TechSolve in Chrome:

```bash
flutter run -d chrome
```

The current development implementation uses Anthropic's browser-access header:

```text
anthropic-dangerous-direct-browser-access: true
```

> ⚠️ This is intended for development/testing only.

API keys should **never be exposed in a production browser application**.

## 🔒 API Security

The current MVP calls the Anthropic API directly:

```text
Flutter App
     │
     ▼
Anthropic API
```

This is convenient for prototyping but **not suitable for production**.

### 🏗️ Production Architecture

The recommended architecture is:

```text
Flutter App
     │
     ▼
🔐 Your Backend
     │
     ▼
🤖 Anthropic API
```

Possible backend options:

* 🔥 Firebase Cloud Functions
* ⚡ Supabase Edge Functions
* 🖥️ Custom backend API

The Anthropic API key should remain **only on the server**.

## 🗺️ Troubleshooting Flow

```text
📝 Describe Problem
        ↓
❓ Diagnostic Questions
        ↓
🤖 AI Analysis
        ↓
🔍 Possible Causes
        ↓
💡 Solutions
        ↓
🧭 Guided Walkthrough
        ↓
❓ Did it work?
      ↙   ↘
    ✅     ❌
    ↓       ↓
💾 Save    🔄 Next Solution
    ↓
📚 History
```

## 🔮 Future Features

* 📸 Screenshot analysis
* 🎤 Voice input
* 🌍 Multi-language support
* ☁️ Cloud authentication
* 🔄 Cross-device history synchronization
* 🗂️ Detailed troubleshooting history
* 🔐 Secure backend API
* 📊 User troubleshooting statistics
* ⭐ Solution feedback/rating

## 📌 Development Status

**TechSolve is currently an MVP/prototype.**

The core troubleshooting workflow is functional:

**Problem → Diagnosis → Solution → Verification → History**

The project is being developed with:

* 💙 Flutter
* 🎯 Dart
* 🤖 Anthropic Claude API
* 🔀 Git & GitHub
* 💾 Shared Preferences

---

### 👨‍💻 Developer

**Fasika Mohammed**

Junior Flutter Developer | Dart | Git & GitHub

GitHub: `fasika03`

---

⭐ **If you find TechSolve useful, consider giving the repository a star!**
