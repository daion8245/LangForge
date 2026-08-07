# Prototype Scope

What this build does and does not do. Anything not listed as in-scope should be
assumed out.

## In scope

- **Onboarding** — pick a course, pick a daily goal, land on the Path.
- **Path** — units and lessons with real lock/unlock rules driven by progress.
- **Lesson player** — all five exercise kinds, working, with hearts, per-answer
  feedback, mistake requeue, and a completion summary.
- **Vault** — vocabulary list with strength, filtering, detail sheet, and a
  review session built from weak entries.
- **Profile** — XP, streak, accuracy, per-unit progress, achievements.
- **Themes** — light and dark, both first-class.
- **Reset** — wipe progress from Profile, to make demoing repeatable.

## Out of scope

| Not building | Prototype substitute |
| --- | --- |
| Real audio playback | Listening exercises show a speaker button that animates and reveals the text on replay |
| Speech recognition | No speaking exercises at all |
| Accounts / auth | A single implicit local learner |
| Backend / sync | In-memory fixtures in `lib/data/` |
| Persistence | State resets on app restart — this is intentional and demo-friendly |
| Real SRS scheduling | Linear strength 0–5 with time decay |
| Localisation | UI copy is English only |
| Analytics, payments, push | None |
| Multiple courses | One seeded course; others show as "coming soon" |

## Constraints the implementation must respect

1. **Zero network at runtime.** No image URLs, no fonts fetched at launch, no
   HTTP. The prototype must run fully offline on first launch.
2. **Zero third-party packages.** See the dependency policy in `AGENTS.md`.
3. **No dead ends.** Every interactive affordance either does something or is
   visibly disabled. No `TODO` screens, no snackbars saying "not implemented".
4. **Responsive down to 360×640.** Exercise content scrolls; the action bar
   stays pinned.
5. **`flutter analyze` clean.** No warnings, no ignores added to silence them.

## Demo script

The path a reviewer should be able to walk unaided:

1. Launch → onboarding → choose Korean → choose the 10-minute goal.
2. Path → tap Lesson 1 of Unit 1 → read the intro sheet → start.
3. Answer a few correctly; deliberately get one wrong → see the explanation →
   notice the heart decrement → continue.
4. Hit the requeued mistake again near the end.
5. Finish → completion screen shows XP, accuracy, streak.
6. Back on the Path → Lesson 1 is complete, Lesson 2 unlocked.
7. Vault → the new words are listed at low strength → open one → run a review.
8. Profile → stats reflect the session → toggle dark mode → reset progress.
