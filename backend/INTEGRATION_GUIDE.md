# Legal Helper Backend - React & Flutter Integration Guide

This guide provides step-by-step instructions for integrating both the **React Web Application** and the **Flutter Android Application** with the unified Legal Helper Supabase backend.

Both applications share the exact same user database, storage buckets, RLS policies, and Edge Function contracts.

---

## 1. React Web Application Integration

### 1.1 Installation
In your React project root:
```bash
npm install @supabase/supabase-js
```

### 1.2 Environment Variables
Create `.env` in the React project root:
```ini
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 1.3 Supabase Client Setup
Copy `client/react/src/supabaseClient.ts`, `types.ts`, and `services/apiService.ts` directly into your React project `src/` directory.

### 1.4 Code Examples

#### Authentication Flow
```typescript
import { LegalHelperApi } from "./services/apiService";

// 1. User Sign Up
await LegalHelperApi.auth.signUp(
  "user@example.com",
  "SecretPassword123!",
  "Advocate Alice",
  "en"
);

// 2. User Sign In
const { data, error } = await LegalHelperApi.auth.signIn(
  "user@example.com",
  "SecretPassword123!"
);

// 3. Get Logged-in User Profile
const profile = await LegalHelperApi.auth.getProfile();
console.log("Logged in as:", profile?.full_name);
```

#### Legal AI Advisor Chat
```typescript
import { LegalHelperApi } from "./services/apiService";

// Send message to Legal AI Advisor
const result = await LegalHelperApi.advisor.sendMessage(
  "What is the limitation period for filing a consumer complaint?",
  currentSessionId, // pass undefined to start a new consultation
  "en" // or "hi" for Hindi
);

console.log("AI Answer:", result.data.response);
console.log("Session ID:", result.data.session_id);
```

#### Uploading to Legal Vault & Simplifying
```typescript
import { LegalHelperApi } from "./services/apiService";

// 1. User selects a contract file
const fileInput = document.getElementById("file-picker") as HTMLInputElement;
const file = fileInput.files![0];

// 2. Upload file and compute SHA-256 hash in vault
const document = await LegalHelperApi.vault.uploadAndRegisterDocument(
  file,
  "Vendor Service Agreement",
  "contract"
);

// 3. Trigger Document Simplifier AI
const analysis = await LegalHelperApi.vault.simplifyDocument(document.id);
console.log("Summary:", analysis.data.summary_en);
console.log("Risk Notes:", analysis.data.risk_notes);
```

---

## 2. Flutter Android Application Integration

### 2.1 Dependency Setup
In your Flutter app's `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.0
  crypto: ^3.0.3
```

Run:
```bash
flutter pub get
```

### 2.2 Deep Link Configuration for Android
To enable email confirmation and password reset deep links on Android, open `android/app/src/main/AndroidManifest.xml` and add an `<intent-filter>` inside the `<activity>` tag:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <!-- Accepts legalhelper://auth-callback -->
    <data android:scheme="legalhelper" android:host="auth-callback" />
</intent-filter>
```

### 2.3 Application Initialization
In `lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );

  runApp(const LegalHelperApp());
}
```

### 2.4 Code Examples

#### Authentication Flow
```dart
import 'package:legal_finder_flutter_app/services/legal_helper_api.dart';

// User Sign In
try {
  final res = await LegalHelperFlutterApi.signIn(
    email: 'user@example.com',
    password: 'SecretPassword123!',
  );
  print('User signed in: ${res.user?.id}');
} catch (e) {
  print('Sign in error: $e');
}
```

#### Legal AI Advisor Chat
```dart
import 'package:legal_finder_flutter_app/services/legal_helper_api.dart';

final response = await LegalHelperFlutterApi.sendAdvisorMessage(
  message: 'How do I respond to a fake cyber cell digital arrest call?',
  sessionId: currentSessionId,
  language: 'en',
);

final aiReply = response['data']['response'];
final sessionId = response['data']['session_id'];
```

#### Scam Detector Scan
```dart
import 'package:legal_finder_flutter_app/services/legal_helper_api.dart';

final scanResult = await LegalHelperFlutterApi.scanForScam(
  content: 'Electricity bill unpaid. Power disconnected tonight. Download APK: http://192.168.1.1/pay',
  sourceChannel: 'sms',
);

print('Risk Level: ${scanResult.riskLevel}'); // HIGH / CRITICAL
print('Red Flags: ${scanResult.suspiciousIndicators}');
print('Safety Actions: ${scanResult.recommendedActions}');
```

#### Lawyer Consultation Preparation Dossier
```dart
import 'package:legal_finder_flutter_app/services/legal_helper_api.dart';

final dossier = await LegalHelperFlutterApi.generateLawyerPrepDossier(
  title: 'Dispute with Builder Over Delayed Possession',
  caseType: 'Consumer / RERA',
  factsSummary: 'Booked in 2021, paid ₹40L, possession delayed by 2 years...',
);

print('Briefing Summary: ${dossier['data']['executive_summary']}');
print('Questions to ask lawyer: ${dossier['data']['questions_for_lawyer']}');
```

