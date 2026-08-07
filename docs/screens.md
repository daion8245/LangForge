# Screens

Screen-by-screen interaction spec. Each section lists what's on screen, what
responds to touch, and where it leads.

---

## 1. Onboarding

`features/onboarding/onboarding_screen.dart` — two pages in a `PageView`, with a
dot indicator. Non-skippable but reversible.

**Page 1 — Course.** Wordmark, "What are you forging?", then a column of course
cards: flag glyph, language name, "1,200 words · 6 units". Korean is seeded;
Japanese and Spanish render at 40% opacity with a "Coming soon" pill and do not
respond to touch. Selecting a card fills it with `emberDim` and enables Next.

**Page 2 — Goal.** "How much per day?" and four radio rows: Casual (5 min /
20 XP), Steady (10 / 40), Serious (15 / 60), Intense (20 / 80). Steady is
preselected. The Start button is always enabled.

Start → `AppState.completeOnboarding(course, goal)` → `HomeShell`, replacing the
route so Back can't return to onboarding.

---

## 2. Home shell

`features/home/home_shell.dart` — `IndexedStack` over three tabs so each keeps
its scroll position. Bottom `NavigationBar`: Path (anvil), Vault (layers),
Profile (person). Active tab is ember; inactive is `inkMuted`.

---

## 3. Path

`features/path/path_screen.dart`

Header (collapses on scroll into a compact bar): course name, streak flame with
day count, gold XP total, and a daily-goal ring showing today's XP against the
goal.

Body: units in order. Each unit renders a header row — index, title, subtitle,
"3/5 lessons" — then its lesson nodes laid out in a gentle left-right stagger
with a dashed connector between them, so the eye follows a path rather than a
list.

Node states are `locked`, `available`, `current`, `complete` per the rules in
`product-brief.md`. Exactly one node is `current` and it pulses.

- Tapping a locked node → a brief shake and a tooltip: "Finish Lesson 2 first."
- Tapping an available node → the lesson intro sheet.

**Lesson intro sheet** — a bottom sheet with lesson title, "6 exercises · ~4
min", the list of new words it introduces, and a Start button → `LessonScreen`.

---

## 4. Lesson player

`features/lesson/lesson_screen.dart`

**Top bar.** Close (×) on the left → confirmation dialog ("Quit? Progress in
this lesson is lost."). Progress bar in the middle. Heart row on the right;
losing a heart scales the lost heart down and fades it to `hairline`.

**Body.** A scrollable `ExerciseView` for the current exercise. Prompt at the
top in `title`, then the exercise-specific interaction:

- **Multiple choice** — the question in the target language, four full-width
  option rows.
- **Word bank** — the source sentence, an answer tray (dashed underline when
  empty), and the shuffled token bank below. Tapping a bank token moves it to
  the tray; tapping a tray token sends it back. Tokens animate between the two.
- **Listening** — a large speaker button that pulses when tapped. First tap is
  "normal speed"; a second control offers slow. Since there is no audio, the
  spoken text appears beneath the button after the first tap — an explicit
  prototype affordance, styled as a dashed-border note so it reads as scaffolding.
- **Match pairs** — a two-column grid of five source and five target terms in
  independent random order. Tap one from each side; a correct pair locks in mint
  and fades, a wrong pair flashes crimson and clears. The exercise completes
  when all five lock.
- **Fill blank** — the sentence with an inline blank chip; options below fill it.

**Action bar.** Per `design-system.md`. Check validates and freezes the body
(further taps ignored) while marking the chosen option mint or crimson and, when
wrong, highlighting the correct one. Continue advances.

On the last exercise, Continue → `LessonCompleteScreen` via `pushReplacement`.
On hearts hitting zero → the same screen in its failed variant.

---

## 5. Lesson complete

`features/lesson/lesson_complete_screen.dart`

Success: a filled anvil mark, "Lesson forged", then three stat tiles — XP
earned (counting up), accuracy, time — and a streak row that reads "Day 4" with
the flame animating in if the streak advanced today. Primary button Continue →
back to the shell.

Failure: crimson mark, "Out of hearts", the count of exercises cleared, and two
buttons — Try again (restarts the same lesson) and Back to path.

---

## 6. Vault

`features/vault/vault_screen.dart`

Header: total words, count "needs review", and a Review button — disabled with
explanatory text when nothing is due.

Filter chips: All / Weak / Strong / Recent.

List rows: target term (`subtitle` weight), source gloss beneath, strength meter
on the right, and a relative "3d ago". Sorted weakest-first within the filter.

Tapping a row opens a detail sheet: term, gloss, part of speech, an example
sentence, which lesson introduced it, and its strength history as five dots.

Review → a `LessonSession` built from the weakest entries, rendered by the same
`LessonScreen`, titled "Review" and awarding half XP.

---

## 7. Profile

`features/profile/profile_screen.dart`

- Header: avatar initial, learner name, course, "Level 4" derived from XP.
- Stat grid: streak, total XP, words forged, accuracy.
- A 7-day activity strip — one bar per day against the daily goal, today
  highlighted in ember.
- Per-unit progress list with thin progress bars.
- Achievements: a wrap of badges, earned ones in gold, locked ones in hairline
  with the criterion as a subtitle.
- Settings rows: theme (System / Light / Dark segmented control), daily goal
  (reopens the goal picker), and **Reset progress**, which confirms via dialog
  and returns the app to onboarding.
