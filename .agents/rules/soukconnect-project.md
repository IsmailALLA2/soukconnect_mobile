# SoukConnect Mobile — Antigravity Rules

## 1. Project Identity
- **App name:** SoukConnect
- **Package:** `soukconnect_mobile`
- **Platform:** Flutter (Android + iOS)
- **Language:** Dart — always null-safe, no legacy APIs
- **State management:** Riverpod (riverpod_annotation + code-gen) + flutter_hooks
- **Navigation:** GoRouter (go_router ^13)
- **Backend:** Supabase (supabase_flutter ^2)

---

## 2. Folder Structure — NEVER deviate from this

```
lib/
├── core/
│   ├── constants/       # App-wide constants (strings, keys, etc.)
│   ├── extensions/      # Dart extension methods on context, string, widget
│   ├── l10n/            # Generated ARB localizations (fr + ar Darija)
│   ├── router/          # app_router.dart (GoRouter) + locale_provider.dart
│   ├── supabase/        # supabase_config.dart (reads from .env via flutter_dotenv)
│   ├── theme/           # app_theme.dart, theme_provider.dart
│   └── utils/           # sizer.dart (responsive), failure.dart (sealed)
├── features/
│   └── <feature>/       # e.g. auth, grossiste, detaillant
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/          # *_model.dart — extends/maps to domain entity
│       │   └── repositories/    # *_repository_impl.dart
│       ├── domain/
│       │   ├── entities/        # *_entity.dart — pure Dart, no framework deps
│       │   ├── repositories/    # abstract *_repository.dart
│       │   └── usecases/        # one file per use case: *_usecase.dart
│       └── presentation/
│           ├── pages/           # *_page.dart — one page per file
│           ├── providers/       # *_provider.dart + generated *.g.dart
│           └── widgets/         # reusable widgets + widgets.dart barrel export
├── shared/
│   ├── models/          # Cross-feature models (e.g. app_user.dart)
│   └── widgets/         # Cross-feature widgets (e.g. profile_page.dart)
└── main.dart
```

### Rules
- **DO NOT** place routing or provider logic inside `features/`.
  Routing lives in `lib/core/router/app_router.dart` only.
- **DO NOT** put theme data inside features. Theme lives in `lib/core/theme/`.
- **DO NOT** create new top-level folders under `lib/`. Use `core/`, `features/`, or `shared/`.
- Every new feature gets its own folder under `lib/features/<feature>/` with the full `data/domain/presentation` structure.
- Shared widgets used by more than one feature go in `lib/shared/widgets/`.

---

## 3. Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `auth_repository_impl.dart` |
| Classes | `PascalCase` | `AuthRepositoryImpl` |
| Providers (generated) | `camelCaseProvider` | `authNotifierProvider` |
| Use cases | `VerbNounUseCase` | `SignInUseCase`, `GetCurrentUserUseCase` |
| Pages | `NounPage` | `LoginPage`, `SplashPage` |
| Widgets (private) | `_PascalCase` | `_PulsingDots` |
| Route constants | `AppRoutes.camelCase` | `AppRoutes.grossisteStore` |

---

## 4. Clean Architecture Rules

- **Domain layer** (`entities/`, `repositories/`, `usecases/`) must have **zero framework imports** — no Flutter, no Riverpod, no Supabase.
- **Data layer** implements domain interfaces. `*_model.dart` extends `*_entity.dart` and adds `fromJson`/`toJson`.
- **Presentation layer** depends on domain only through providers. Pages never import repositories directly.
- Use cases take their repository as a constructor parameter, not via provider lookup.
- Failures are typed — use the sealed `Failure` hierarchy from `lib/core/utils/failure.dart`. Never throw raw exceptions from repositories.

---

## 5. State Management (Riverpod)

- Use `@Riverpod(keepAlive: true)` for session-scoped providers (auth, router, repositories).
- Use `StateNotifierProvider.autoDispose` for ephemeral form state (e.g. `authFormProvider`).
- Use `@riverpod` (auto-dispose by default) for stream providers and non-global providers.
- Always run code-gen after touching any `@riverpod` annotation:
  ```
  dart run build_runner build --delete-conflicting-outputs
  ```
- Generated files (`*.g.dart`) are committed — do not gitignore them.

---

## 6. Responsive Sizing — Always Use Sizer Extensions

Base design: **390 × 844** (iPhone 14).

```dart
16.w    // width-proportional size
20.h    // height-proportional size
12.sp   // font size
8.r     // border radius
```

- **Never** use raw `double` pixel values for layout sizes.
- `SizerInit` wraps `MaterialApp` in `main.dart` — do not move it.

---

## 7. Theme & Colors

- Primary color: `AppColors.primary` → `#1B5E20` (deep green)
- Secondary: `AppColors.secondary` → `#FFA000` (amber)
- Font: **Cairo** (supports Arabic)
- Always reference colors via `AppColors.*` — never hardcode hex values except in `app_theme.dart`.
- Use `color.withValues(alpha: 0.5)` — **NOT** `color.withOpacity(0.5)` (deprecated in Flutter 3.38+).
- Use updated theme type names:
  - `CardThemeData` (not `CardTheme`)
  - `DialogThemeData` (not `DialogTheme`)

---

## 8. Localization

- Languages: French (`fr`, default) + Arabic Darija (`ar`)
- ARB template: `lib/core/l10n/app_fr.arb`
- Usage in widgets: `AppLocalizations.of(context).someKey`
- Run `flutter gen-l10n` after modifying ARB files.
- All user-facing strings must be localized — no hardcoded French/Arabic strings in widgets.

---

## 9. Environment Variables

- All secrets live in `.env` at the project root (gitignored).
- Loaded via `flutter_dotenv` in `main()` before anything else.
- Access via `dotenv.env['KEY']` or through `SupabaseConfig`.
- `.env.example` (no real secrets) is committed as a template.

---

## 10. Router Rules (`lib/core/router/app_router.dart`)

- All route path strings are constants in `AppRoutes` — never use raw strings.
- The redirect callback is the **only** place for auth-guard logic.
- `RouterRefreshNotifier` must listen to **both** `authStateStreamProvider` AND `authNotifierProvider` — removing either listener will break navigation.
- `splashReady` flag (1500 ms minimum) ensures the splash animation always plays on cold open.
- Shell routes (Détaillant, Grossiste) are defined inside `appRouter` — do not create separate router files per feature.

---

## 11. Dart / Flutter Code Style

- Dart SDK constraints follow the project's `pubspec.yaml` — do not add incompatible syntax.
- Prefer `const` constructors wherever possible.
- Use named parameters for all public constructors with more than 1 argument.
- `late final` for AnimationControllers and controllers initialized in `initState`.
- Always `dispose()` AnimationControllers.
- `HookConsumerWidget` for pages that need both hooks and Riverpod.
- `ConsumerWidget` for stateless widgets that only need Riverpod.
- `StatefulWidget` only when hooks are not used and local state is needed.
- Import order: dart → package → relative (separated by blank lines).

---

## 12. Supabase Schema Reference

Key tables: `public.profiles` (mirrors `auth.users` via trigger).

Profile columns: `id, full_name, phone, wilaya, role, lat, lng, created_at`.

Role values: `'grossiste' | 'detaillant' | 'admin'`.

---

## 13. What NOT to Do

- ❌ Do not place business logic in pages or widgets.
- ❌ Do not import Supabase directly in presentation layer — go through the repository.
- ❌ Do not use `BuildContext` in providers.
- ❌ Do not use `Navigator.push` — always use GoRouter `context.go()` or `context.push()`.
- ❌ Do not use `withOpacity()` — use `withValues(alpha:)`.
- ❌ Do not hardcode pixel sizes — use sizer extensions.
- ❌ Do not create files outside the established folder structure without explicit approval.
- ❌ Do not skip running `build_runner` after modifying `@riverpod` annotations.
