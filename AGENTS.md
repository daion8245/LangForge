# AGENTS.md

Guidance for AI agents and humans working in this repository.

## What this repo is

**LangForge** is a language-learning app built around *forging* sentences: the
learner constructs output rather than recognising it. This repo currently holds
the **interactive prototype** — a fully clickable Flutter app running entirely
on in-memory mock data, with no backend, no network calls, and no persistence.

The prototype exists to validate the core loop and the interaction design before
any server work starts. Treat it as a design artifact that happens to compile.

## Stack

| Concern | Choice |
| --- | --- |
| Framework | Flutter (stable channel, Material 3) |
| Language | Dart 3 — sealed classes, pattern matching, records |
| State | `ChangeNotifier` + `InheritedNotifier`, hand-rolled |
| Routing | Navigator 1.0 (`MaterialPageRoute`) |
| Data | Hard-coded mock fixtures under `lib/data/` |

### Dependency policy

**No third-party runtime packages.** `pubspec.yaml` depends on `flutter` and
`cupertino_icons` only; `flutter_lints` is the sole dev dependency. This keeps
the prototype buildable offline and stops us from baking premature
infrastructure choices (state libraries, HTTP clients, DI containers) into a
throwaway artifact.

If you believe a package is genuinely required, say so in the PR description
instead of adding it silently.

## Layout

```
lib/
  main.dart                 # entrypoint
  app.dart                  # MaterialApp + root state wiring
  core/
    theme.dart              # design tokens + light/dark ThemeData
    app_scope.dart          # InheritedNotifier access to AppState
    ui.dart                 # small shared widgets (pills, bars, buttons)
  models/                   # pure data types, no Flutter imports
    course.dart
    exercise.dart           # sealed Exercise hierarchy
    lesson.dart
    vocab_entry.dart
  data/
    mock_courses.dart       # the seeded course, units, lessons, exercises
    mock_vocab.dart         # vocabulary vault fixtures
  state/
    app_state.dart          # persistent-ish app state (progress, XP, streak)
    lesson_session.dart     # per-lesson session engine
  features/
    onboarding/
    home/                   # bottom-nav shell
    path/                   # unit/lesson map
    lesson/                 # player + one widget per exercise kind
    vault/                  # vocabulary review
    profile/                # stats
test/
docs/                       # product + design + architecture specs
```

`models/` must never import `package:flutter/*`. Everything else may.

## Commands

```bash
flutter pub get
flutter analyze          # must be clean before committing
flutter test
flutter run -d chrome    # or any attached device
```

## Conventions

- **Material 3 only.** `useMaterial3: true`; don't reintroduce M2 widgets.
- **Design tokens, not literals.** Colours and spacing come from
  `core/theme.dart` (`LFColors`, `LFSpace`, `LFRadius`). No raw `Color(0x...)`
  in feature code.
- **Modern Flutter APIs.** `Color.withValues(alpha:)` not `withOpacity`,
  `WidgetStateProperty` not `MaterialStateProperty`.
- **Exhaustive switches.** `Exercise` is `sealed` — pattern-match without a
  `default` arm so adding a kind produces a compile error at every call site.
- **State mutation is centralised.** Widgets call methods on `AppState` /
  `LessonSession`; they never mutate model objects directly.
- `const` constructors wherever possible; the linter enforces it.

### Adding an exercise kind

1. Add the subclass to `lib/models/exercise.dart`.
2. Implement `bool isCorrect(Object answer)` on it.
3. Add a renderer widget in `lib/features/lesson/widgets/`.
4. Add the arm to the switch in `ExerciseView`, and to the feedback-note
   switch in `LessonSession.submit`.
5. Seed at least one instance in `lib/data/mock_courses.dart`.

The compiler will point at step 4 if you skip it — both switches are
exhaustive over the sealed hierarchy.

## Out of scope for the prototype

Real audio, speech recognition, accounts, sync, payments, notifications,
localisation, analytics, and persistence across restarts. Deliberately so — see
`docs/prototype-scope.md`.

## Specs

Read these before making product-level changes:

- `docs/product-brief.md` — what LangForge is and who it's for
- `docs/prototype-scope.md` — in/out for this build
- `docs/architecture.md` — layers and data flow
- `docs/design-system.md` — colour, type, spacing, motion
- `docs/screens.md` — screen-by-screen interaction spec
