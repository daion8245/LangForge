# LangForge

A language-learning app built around *forging* sentences: the learner
constructs output rather than recognising it.

This repository holds the **interactive prototype** — a fully clickable Flutter
app running on in-memory mock data, with no backend, no network calls and no
persistence. It exists to validate the core loop and the interaction design
before any server work starts.

## Run it

```bash
flutter pub get
flutter run -d chrome     # or any attached device
```

Requires the Flutter stable channel (built against 3.44 / Dart 3.12). There are
no third-party runtime dependencies, so it builds and runs offline.

## Check it

```bash
flutter analyze     # clean
flutter test        # 60 tests
```

## What you can do in it

Pick a course and a daily goal, work down a path of units and lessons, play all
five exercise kinds, lose hearts and get missed exercises requeued, bank words
into a Vault that tracks strength and decay, run a review session from the weak
ones, and watch XP, streak and achievements move on the Profile. Light and dark
are both first-class, and Reset progress makes the whole thing repeatable for
the next demo.

Nothing is a placeholder — every affordance either does something or is visibly
disabled.

## Where to look

| Path | What's in it |
| --- | --- |
| `lib/models/` | Pure data types, including the sealed `Exercise` hierarchy |
| `lib/state/` | `AppState` (global) and `LessonSession` (per-lesson engine) |
| `lib/features/` | One directory per screen area |
| `lib/core/` | Design tokens, shared widgets, state plumbing |
| `lib/data/` | The seeded Korean course and vocabulary |

## Docs

- [`AGENTS.md`](AGENTS.md) — conventions and constraints for anyone working here
- [`docs/product-brief.md`](docs/product-brief.md) — what LangForge is and who it's for
- [`docs/prototype-scope.md`](docs/prototype-scope.md) — what's in and out of this build
- [`docs/architecture.md`](docs/architecture.md) — layers, state, the session engine
- [`docs/design-system.md`](docs/design-system.md) — colour, type, spacing, motion
- [`docs/screens.md`](docs/screens.md) — screen-by-screen interaction spec
