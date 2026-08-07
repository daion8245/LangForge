# LangForge — Product Brief

## The idea

Most language apps train *recognition*. You tap the right tile among four, feel
competent, and then freeze the first time you have to produce a sentence
unaided. LangForge trains *production*. Every session pushes the learner to
assemble language rather than identify it.

The metaphor is a forge: raw vocabulary goes in, repeated pressure shapes it,
and what comes out is something the learner can actually use.

## Who it's for

Adult self-learners at A1–B1 who have tried a mainstream app, hit a plateau, and
noticed they still can't hold a conversation. They have 10–20 minutes a day and
low tolerance for gamification that feels like a slot machine.

## Core loop

1. **Open** → the Path shows exactly one recommended next lesson.
2. **Forge** → a 6–10 exercise session, weighted toward construction.
3. **Feedback** → immediate, per-exercise, with the *why* on mistakes.
4. **Bank** → new words land in the Vault at strength 0.
5. **Return** → the Vault surfaces what's decaying; streak and XP mark the habit.

A session should take 3–5 minutes. Nothing in the loop may block on a network.

## Exercise kinds

Ordered by how much production they demand:

| Kind | Demand | Role |
| --- | --- | --- |
| Match pairs | Lowest | Warm-up, introduces new forms |
| Multiple choice | Low | Checks meaning quickly |
| Listening | Medium | Decoding under time pressure |
| Fill blank | Medium | Grammar in context |
| **Word bank** | **Highest** | The core exercise — build the sentence |

A lesson is roughly 40% word-bank by design. The others exist to make the
word-bank exercises survivable, not to pad the count.

## Progression

- **Course → Units → Lessons.** A unit is a theme (Greetings, Café, Directions);
  a lesson is one sitting.
- A lesson unlocks when the previous one in its unit is complete. The first
  lesson of a unit unlocks when the prior unit is finished.
- **Hearts** (3 per session) cap the cost of guessing without hard-failing the
  learner. Running out ends the session; progress on completed exercises stands.
- **Mistakes requeue.** A missed exercise returns at the end of the same
  session. You do not finish a lesson having only ever got something wrong.

## The Vault

Every word the learner meets is tracked with a **strength** from 0 to 5.
Strength rises on a correct answer and decays with time since last seen. The
Vault lists words sorted by weakest-first and can launch a review session drawn
only from decaying entries.

This is deliberately a *simplified* spaced-repetition model — enough to make the
interaction design real, not a claim about the final scheduling algorithm.

## Deliberate non-goals

- No leaderboards, no leagues, no streak-loss anxiety mechanics.
- No ads, no lives-you-can-buy.
- Streaks are shown, never nagged about.

## What success looks like for the prototype

Someone can be handed a phone and, with no explanation, complete onboarding,
finish a lesson, get something wrong and understand why, see the word land in
the Vault, and review it — without hitting a dead end or a placeholder screen.
