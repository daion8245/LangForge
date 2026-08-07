# Architecture

## Layers

```
features/          widgets, screens — may read state, never own it
   |
state/             ChangeNotifiers — the only place mutation happens
   |
data/              mock fixtures — construct models, no logic
   |
models/            pure Dart data types — no Flutter imports
```

Dependencies point downward only. `models/` importing `package:flutter/*` is a
review-blocking mistake; it's the seam where a real data layer will eventually
be swapped in.

## State

Two notifiers, deliberately.

### `AppState` — lives as long as the app

Owns everything that survives a lesson: the selected course, lesson completion,
XP, streak, daily goal, the Vault, and the theme mode. Created once in
`app.dart` and published through `AppScope`, an `InheritedNotifier<AppState>`.

```dart
final state = AppScope.of(context);   // rebuilds on change
```

Why `InheritedNotifier` rather than a package: it is ~20 lines, it gives
dependent widgets automatic rebuilds, and it keeps the prototype free of a
state-management choice we'd have to relitigate later.

### `LessonSession` — lives as long as one lesson

Created by `LessonScreen`, disposed with it. Owns the exercise queue, current
index, hearts, per-exercise correctness, and the requeue list. It knows nothing
about `AppState`; on completion `LessonScreen` hands the *result* up:

```dart
appState.completeLesson(lesson.id, result);
```

This split is the point: the session is a pure, testable engine, and the only
write to global state happens once, at a known moment.

## Session engine

```
buildQueue(lesson.exercises)
     |
  [current] --submit(answer)--> check --> correct? --+--> advance
     ^                                               |
     |                                               +--> heart--, requeue at end
     |                                                        |
     +--------------------------------------------------------+
```

- `submit` never advances. It records an `AnswerOutcome` and notifies; the UI
  swaps the action bar to a feedback state. `advance()` is a separate call
  driven by the Continue button. This two-step is what makes feedback readable.
- A wrong exercise is appended once (not repeatedly) to the tail of the queue.
- Hearts reaching zero sets `status = SessionStatus.failed`; the UI routes to
  the failure state of the completion screen.
- `xpEarned` counts first-attempt correct answers only, so requeues can't farm.

## Exercise polymorphism

`Exercise` is a **sealed** class. Each subclass carries its own payload and
implements `bool isCorrect(Object answer)`, so validation lives with the data
rather than in a switch.

Rendering *is* a switch — an exhaustive one:

```dart
Widget build(BuildContext context) => switch (exercise) {
  MultipleChoiceExercise e => MultipleChoiceView(exercise: e, ...),
  WordBankExercise e       => WordBankView(exercise: e, ...),
  ListeningExercise e      => ListeningView(exercise: e, ...),
  MatchPairsExercise e     => MatchPairsView(exercise: e, ...),
  FillBlankExercise e      => FillBlankView(exercise: e, ...),
};
```

No `default` arm. Adding a sixth kind breaks the build here, which is the
intent.

Each view is a controlled component: it holds only draft UI state (which tiles
are selected), and reports a completed answer upward via
`onAnswerChanged(Object? answer)`. The parent owns "is an answer ready".

## Vault strength

`VocabEntry.strength` is 0–5.

- Correct answer → `+1`, capped at 5.
- Wrong answer → `-1`, floored at 0.
- `effectiveStrength` subtracts one level per full decay window since
  `lastSeen`, so the list re-sorts over time without a scheduler.

Review sessions are built by taking the weakest N entries and generating
exercises from them at runtime — the same `Exercise` types the Path uses, so
there is exactly one player.

## Navigation

Navigator 1.0, `MaterialPageRoute`, no route table. The tree is shallow:

```
OnboardingScreen ──> HomeShell (IndexedStack: Path | Vault | Profile)
                        └─> LessonScreen ──> LessonCompleteScreen
```

`LessonCompleteScreen` pops back to the shell with
`popUntil((r) => r.isFirst)` semantics rather than stacking.

## Testing

`test/` covers the engine, not the pixels: queue construction, requeue-once
behaviour, heart depletion, XP accounting, and strength decay. Widget tests
cover that each exercise view reports a correct answer upward.
