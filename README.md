# ⚖️ Legal Helper — Full-Stack AI Legal Tech Platform

> **Official Full-Stack Repository: Flutter Android Frontend & Supabase Cloud Backend**  
> **Public GitHub Repository**: [https://github.com/bhavya14032007/Legal_finder_flutter_app.git](https://github.com/bhavya14032007/Legal_finder_flutter_app.git)

---

## 1. Chosen Vertical: AI Legal Tech & Access to Justice

Legal systems and procedures are notoriously opaque, expensive, and intimidating for individual citizens, tenants, consumers, and small business owners. **Legal Helper** democratizes access to justice by providing an accessible, AI-powered mobile assistant backed by a scalable Supabase cloud backend:
- Plain-language legal comprehension (demystifying legalese and notice deadlines).
- Rapid preliminary drafting (NDAs, lease deeds, cease & desist, and demand letters).
- Structured notice responses and evidence timelines.
- Pro-bono legal aid eligibility verification and direct public authority links.
- Pre-consultation preparation kits so citizens enter consultations with clear facts and key questions.

---

## 2. Monorepo Structure

```
Legal_finder_flutter_app/
├── README.md                          # Platform overview and architecture guide
├── .gitignore
├── frontend/                          # Flutter Android Mobile Application
│   ├── lib/                           # Feature-First Flutter frontend (Riverpod, GoRouter)
│   ├── test/                          # Unit and widget test suite (14 passing tests)
│   ├── android/                       # Android native project files
│   ├── assets/                        # Design icons and images
│   ├── pubspec.yaml                   # Flutter dependencies
│   └── README.md
└── backend/                           # Supabase Backend & AI Services
    ├── supabase/
    │   ├── migrations/                # PostgreSQL schema migrations (001-010) with RLS
    │   └── functions/                 # Deno TypeScript Edge Functions (AI Advisor, Simplifier, etc.)
    ├── client/                        # Shared API client SDKs for Flutter & React
    ├── tests/                         # SQL RLS isolation tests & Deno edge function tests
    ├── API_CONTRACTS.md               # Complete REST/RPC contract specifications
    ├── DATABASE_SCHEMA.md             # Entity relationships, tables, and security policies
    └── DEPLOYMENT_GUIDE.md            # Production deployment walkthrough
```
│       ├── disclaimer_banner.dart
│       ├── infinite_ribbon_motif.dart
│       ├── legal_button.dart
│       ├── legal_card.dart
│       ├── legal_empty_state.dart
│       ├── legal_error_view.dart
│       ├── legal_loading_indicator.dart
│       └── legal_text_field.dart
├── features/
│   ├── auth/                          # Supabase Auth: Sign In, Sign Up, Password Reset
│   ├── home/                          # Dashboard, Recent Activity, Search & AI Shortcut
│   ├── explore/                       # Categorized 10-tool directory (AI, Docs, Safety)
│   ├── legal_advisor/                 # Conversational AI advisor with citations
│   ├── legal_research/                # Case law search, precedents, ratios & statutes
│   ├── document_simplifier/           # Plain-English translation & clause breakdown
│   ├── drafting/                      # Dynamic legal instrument drafting & editor
│   ├── notice_reply/                  # Rebuttal formulation for statutory notices
│   ├── legal_vault/                   # AES-256 encrypted personal document safe
│   ├── scam_detector/                 # Fraud heuristics, scam threat score & red flags
│   ├── evidence_timeline/             # Chronological incident and document logger
│   ├── lawyer_prep/                   # Pre-consultation checklists & strategic questions
│   ├── legal_aid/                     # Article 39A free legal aid checker & directory
│   ├── saved/                         # Unified repository for all user outputs
│   └── profile/                       # Account, English/Hindi localization & Theme
└── shared/
    ├── providers/                     # Riverpod state providers (Locale, Theme, Storage)
    └── widgets/                       # ScaffoldWithNavBar persistent shell
```

---

## 3. How the Solution Works

### A. Navigation & Shell
- **Persistent Bottom Navigation**: Exactly four bottom destinations: **Home**, **Explore**, **Saved**, and **Me**.
- **Floating AI Advisor Action Button (`AiFab`)**: Docks elegantly across main tabs, automatically hides when the virtual keyboard is open, and never obstructs form fields or primary CTAs.
- **Root Navigator Navigation**: Specialized feature tools push on top of the root navigator with custom back buttons and smooth transitions.

### B. 8-Point Grid System & Design Tokens
Consistent geometric harmony is enforced throughout the application via `AppSpacing`:
- `xxs = 4.0` (0.5x)
- `xs = 8.0` (1.0x - Base Unit)
- `sm = 12.0` (1.5x)
- `md = 16.0` (2.0x)
- `lg = 24.0` (3.0x)
- `xl = 32.0` (4.0x)
- `xxl = 40.0` (5.0x)
- `xxxl = 48.0` (6.0x - Minimum accessible touch target)

### C. Theme & CSS Variables Equivalence
The mobile app mirrors the web counterpart's CSS custom properties:
| CSS Custom Property | Dart Color Token | Midnight Dark Value | Light Value |
|---------------------|------------------|---------------------|-------------|
| `--bg-midnight` | `AppColors.darkBackground` | `#0B0F17` | `#F8FAFC` |
| `--surface-card` | `AppColors.darkCard` | `#161F2E` | `#FFFFFF` |
| `--surface-elevated` | `AppColors.darkCardElevated` | `#1E293B` | `#F1F5F9` |
| `--surface-border` | `AppColors.darkBorder` | `#26334D` | `#E2E8F0` |
| `--accent-violet` | `AppColors.accentViolet` | `#6366F1` | `#6366F1` |
| `--accent-indigo` | `AppColors.accentIndigo` | `#4F46E5` | `#4F46E5` |
| `--accent-cyan` | `AppColors.accentCyan` | `#06B6D4` | `#06B6D4` |

### D. Accessibility & Reduced Motion
- All interactive controls enforce a minimum touch target size of 48×48 dp (`AppSpacing.xxxl`).
- Dynamic animation controllers (including `InfiniteRibbonMotif`) check `context.reducesMotion` (`MediaQuery.maybeOf(context)?.disableAnimations ?? false`) and immediately stop loop animations when reduced motion is preferred by the user.
- Every custom button and input field contains accessibility `Semantics`.

### E. Internationalization & Dual Language Support
- Support for **English** and **हिन्दी (Hindi)** interface modes.
- Instant language toggle under **Me > Preferences** persisted across sessions in `SharedPreferences`.

---

## 4. Feature Coverage Matrix

| Feature Screen | Status | Functionality Details |
|----------------|--------|-----------------------|
| **Authentication** | ✅ Operational | Sign In, Sign Up, Password Recovery, Guest fallback, PKCE flow. |
| **Home Dashboard** | ✅ Operational | User profile banner, global statutory ask field, quick tools, recent library items, disclaimer banner. |
| **Explore Directory**| ✅ Operational | Categorized into AI ASSISTANCE, DOCUMENTS, and SAFETY & HELP. |
| **Legal Advisor** | ✅ Operational | Interactive chat, statutory legal citations, prompt chips, save session, new session. |
| **Legal Research** | ✅ Operational | Case law search, ratio decidendi display, precedent acts breakdown, query history. |
| **Document Simplifier** | ✅ Operational | File picker (PDF, DOCX, TXT), Plain English / Clause breakdown / Risk modes, Read-aloud simulation, copy, save. |
| **Drafting Assistant** | ✅ Operational | Configurable NDAs, Leases, Demand Letters, Freelance contracts, Cease & Desist, live editable output editor. |
| **Notice Reply** | ✅ Operational | Notice upload, recipient & claim details, statutory defense formulation, editable preview. |
| **Legal Vault** | ✅ Operational | Encrypted document repository, categories (Contracts, Identity, Court, Property), upload & delete. |
| **Scam Detector** | ✅ Operational | Threat score (0-100), risk indicators, red flags analysis, recommended cyber defense actions. |
| **Evidence & Timeline** | ✅ Operational | Chronological visual timeline, proof attachment indicators, add & edit entry sheet. |
| **Lawyer Preparation** | ✅ Operational | Case summary, relief sought, pre-consult checklist, categorized questions by fee/strategy/odds, dossier export. |
| **Legal Aid** | ✅ Operational | Article 39A eligibility assessment, verified NALSA/DLSA helplines and Tele-Law portal direct access. |
| **Saved Library** | ✅ Operational | Unified storage for drafts, documents, research and chats with type filter chips and search. |
| **Profile & Settings** | ✅ Operational | English/Hindi toggle, Midnight/Light/System theme, notifications, privacy modal, GitHub link, sign out. |

---

## 5. Security & Responsible Implementation

1. **Client-Side Key Isolation**: Only the publishable client key is configured in `SupabaseConfig.anonKey`. External AI secret keys and Supabase `service_role` keys are strictly forbidden on the mobile client.
2. **Offline-Resilient Architecture**: When live Supabase backend credentials are not passed, the application gracefully operates in local fallback mode with pre-seeded data, ensuring zero crashes.
3. **Mandatory Disclaimer Banners**: Every legal screen prominently displays clear legal disclaimers reminding users that AI outputs are for informational assistance and do not constitute formal attorney-client representation.

---

## 6. Assumptions Made

1. **Backend Integration**: Supabase is used as the primary cloud database and authentication provider. When compile-time environment variables (`SUPABASE_URL` and `SUPABASE_ANON_KEY`) are omitted, the app defaults to resilient local in-memory repositories with realistic legal case data.
2. **Device File Access**: File picker leverages platform-native Android intent pickers for PDF, DOCX, and image uploads without requiring broad storage manager privileges on Android 13+.
3. **AI Inference**: The mobile client interacts with statutory reasoning endpoints or edge functions via the repository interfaces, isolating business logic from external API providers.

---

## 7. Setup & Build Instructions

### Prerequisites
- Flutter SDK 3.24+ (Dart 3.5+)
- Android Studio / Android SDK with Platform 34
- Java Development Kit (JDK 17)

### Local Development Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/bhavya14032007/Legal_finder_flutter_app.git
   cd Legal_finder_flutter_app/frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run static analysis:
   ```bash
   flutter analyze
   ```

4. Execute automated tests (25 passing unit, widget & integration tests):
   ```bash
   flutter test
   ```

### Running with Supabase Configuration
Run the app targeting Android with your Supabase credentials:
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-publishable-key
```

### Building Android Release APK / App Bundle
```bash
# Build Universal APK
flutter build apk --release

# Build Google Play App Bundle
flutter build appbundle --release
```

---

## 8. Backend Dependencies

- **Database**: PostgreSQL with Supabase Row Level Security (RLS) enabled on `saved_items`, `documents`, and `chat_sessions`.
- **Auth**: Supabase GoTrue Auth with Email/Password & PKCE.
---

## 9. Recent UI Redesigns & Theme Mode Architecture

### A. Notice Reply Helper UI Redesign
- **Visual Reference Compliance**: Replaced the legacy input form with the modern high-conversion UI matching the production specification.
- **Header**: Features circular back button `<` with subtle border, bold title & subtitle, and an `Instant Legal Assistant` green status badge pill.
- **Security Card**: High-contrast "Safe & Confidential" card with lock icon explaining algorithmic claim isolation and response deadline calculation.
- **Document Upload Card**: Implemented custom dashed border container (`_DashedBorderPainter`), circular purple upload CTA, file extraction indicator, and support for PDFs, images, DOCX, and plain text.
- **Notice Summary & Goals**: Integrated section with "Voice Dictate" trigger, multiline context field, and 3 statutory goal chips: *Check Limitation Period*, *Request Settlement*, and *Deny Allegations*.
- **Parties & Claims**: Responsive dual inputs for sender organization and formatted amount claimed (`$ 4,500.00`).
- **Primary Rebuttal CTA**: Purple-to-blue gradient button with reply icon and statutory export disclaimer.

### B. Drafting Assistant UI Redesign
- **Conversational Document Generation**: Transformed static form inputs into an AI-guided conversational experience matching the reference design.
- **Header & Progress**: Centered title with real-time green `● AI Assistant Online` pulse indicator, circular info action `ⓘ`, dynamic multi-step indicator (`✓ Step 3 of 4: Details & Terms`), remaining time estimate (`~1 min remaining`), and centered `TODAY • INSTANT LEGAL DRAFTING` pill.
- **Message Bubbles**: Left-aligned AI messages with purple sparkle avatars (`Icons.auto_awesome_rounded`) and dark neutral bubbles; right-aligned user messages in purple/indigo gradient pills.
- **Interactive Agreement Chips**: Instant selector pills for Rental Agreement (🏠), Non-Disclosure Agreement (🔒), Freelance Contract (💼), and Payment Demand (📄).
- **Inline Drafting Progress**: Interactive progress card displaying document icon, percentage badge (`60%`), document type and jurisdiction, and a "Preview" button.
- **Modal Preview & Editor**: Fullscreen bottom sheet allowing users to view, live-edit monospace text, copy to clipboard, and persist the draft to the Supabase library.
- **Bottom Fixed Composer**: Contextual `Quick add:` suggestions (`+ 11-Month Term`, `+ 1-Month Deposit`, `+ 15-Day Notice`), attachment action, dictation trigger, and purple gradient send button.

### C. Dark / Light Theme Mode Bug Fix
- **Root Cause**: The root `ScaffoldWithNavBar` container and `HomeScreen` had hardcoded hex colors (`0xFF0A0D18`, `0xFF090D18`), overriding light mode themes. Furthermore, `theme_provider.dart` lacked explicit resolution for `ThemeMode.system`.
- **Solution**:
  - Bound all scaffold, navbar, cards, typography, and borders to dynamic theme tokens (`context.legalTheme`, `context.colors`, or `isDark` checks).
  - Extended `ThemeProvider` to properly support `Midnight`, `Light`, and `System` modes with persistent storage across sessions.
  - Implemented the segmented theme switch on the Profile screen (`Midnight`, `Light`, `System`) with purple glowing active pill indicator matching reference design 3.

---

## 10. Assumptions & Design Logic
- **Offline & Fallback Safety**: AI generation endpoints gracefully fall back to local rule-based statutory templates if offline or if backend endpoints are unavailable, ensuring continuous user workflows.
- **Statutory Indian Law Alignment**: Drafts and rebuttals automatically reference applicable Indian statutes (e.g. Section 138 NI Act, Limitation Act 1963, Transfer of Property Act 1882) while remaining customizable.
- **Supabase Integrity**: All Supabase URLs, anon keys, schema migrations, and RLS policies are strictly preserved.

