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
```

---

## 7. Widget Composition — Extract for Clean UI

- **Pages are thin** — they compose widgets and wire providers. No inline layout logic past ~30 lines.
- Extract reusable widgets to `features/<feature>/presentation/widgets/` as public `PascalCase` classes.
- Private `_PascalCase` widgets are acceptable for one-off, tightly-coupled use within a single file, but promote to a public widget file when they exceed ~50 lines or are reused.
- A widget file contains **one logical widget** plus its direct private sub-widgets (e.g. `_StoreShimmerCard` lives with `StoreShimmerList`).
- Export all public widgets from the `widgets.dart` barrel.
- Shared widgets used by 2+ features go in `lib/shared/widgets/`.
