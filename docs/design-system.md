# Design System

Tokens live in `lib/core/theme.dart`. Feature code uses the token classes —
never a raw `Color(0x…)` or a bare pixel number for spacing.

## Colour

The palette is drawn from the forge metaphor: hot metal against dark iron.

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| `LFColors.ember` | `#F0603A` | `#FF7A55` | Primary. CTAs, active nav, progress fill |
| `LFColors.emberDim` | `#FDEDE8` | `#3A241D` | Ember at rest — selected tiles, badges |
| `LFColors.mint` | `#12A87A` | `#2DD4A7` | Correct answers only |
| `LFColors.mintDim` | `#E4F6F0` | `#12312A` | Correct-state fills |
| `LFColors.crimson` | `#D93A3F` | `#F2686C` | Wrong answers, heart loss |
| `LFColors.crimsonDim` | `#FCEAEA` | `#3A1D1F` | Wrong-state fills |
| `LFColors.gold` | `#E0A008` | `#FFC53D` | XP, streak, achievements |
| `LFColors.ink` | `#16181D` | `#F4F5F7` | Primary text |
| `LFColors.inkMuted` | `#6B7280` | `#9AA1AD` | Secondary text |
| `LFColors.surface` | `#FFFFFF` | `#1C1E24` | Cards, sheets |
| `LFColors.canvas` | `#FBF8F5` | `#131418` | Scaffold background |
| `LFColors.hairline` | `#E6E2DD` | `#2C2F37` | Borders, dividers |

Semantic rule: **mint means correct, crimson means wrong, ember means
actionable.** Ember is never used to signal success — that ambiguity is what
makes feedback slow to read.

Access via `LFColors.of(context)`, which resolves against the current
brightness. Never branch on `Theme.of(context).brightness` in feature code.

## Type

System font stack (no bundled or fetched fonts — see the offline constraint).

| Role | Size / weight | Use |
| --- | --- | --- |
| `display` | 34 / w800, -0.5 tracking | Completion screen numbers |
| `title` | 22 / w700 | Screen titles, prompts |
| `subtitle` | 17 / w600 | Card headers, unit names |
| `body` | 15 / w400 | Running text |
| `label` | 13 / w600, +0.2 tracking | Buttons, chips, meta |
| `mono` | 15 / w500 | Target-language tokens in word bank |

Target-language text is always at least `subtitle` weight. The learner is
reading unfamiliar glyphs; it never gets to be small print.

## Spacing & shape

`LFSpace`: `xs 4`, `sm 8`, `md 12`, `lg 16`, `xl 24`, `xxl 32`.
Screen gutter is `lg`. Vertical rhythm between sections is `xl`.

`LFRadius`: `sm 8`, `md 12`, `lg 16`, `xl 24`, `pill 999`.
Cards and tiles use `lg`. Buttons and chips use `pill`.

## Components

### Action bar
Pinned to the bottom of the lesson player, above the safe area. Three states:

- **Idle** — full-width button, disabled until an answer exists.
- **Correct** — mint fill slides up behind the bar, title "Nice.", Continue.
- **Wrong** — crimson fill, the correct answer spelled out, then Continue.

The button row itself keeps a fixed height and stays pinned to the bottom; the
feedback banner slides in *above* it and the whole bar tints. The Continue
button therefore lands under the same thumb position every time, regardless of
how much the banner has to say.

### Tiles (word bank, options)
Pill-shaped, `hairline` border at rest, `emberDim` fill + `ember` border when
selected, mint/crimson after checking. Minimum 44pt touch target. The word bank
uses `Wrap`, so long sentences reflow rather than scroll horizontally.

### Progress bar
Rounded, `hairline` track, `ember` fill, 8pt tall, animated over 240ms. Shown in
the lesson top bar next to the heart row.

### Lesson node
56pt circle on the Path. Locked: `hairline` fill, muted lock glyph. Available:
`ember` fill, white glyph, and a soft ember glow ring. Complete: `mint` fill,
check glyph. The single recommended lesson gets a slow pulsing ring — exactly
one node on the screen ever pulses.

### Strength meter
Five 3pt bars. Filled bars use ember; empty use hairline. At strength 0 the
first bar is crimson, to make decay legible at a glance.

## Motion

| Interaction | Duration | Curve |
| --- | --- | --- |
| Tile select | 120ms | `easeOut` |
| Feedback bar in | 220ms | `easeOutCubic` |
| Progress fill | 240ms | `easeOutCubic` |
| Screen transition | 300ms | platform default |
| Node pulse | 1600ms loop | `easeInOut` |
| XP count-up | 900ms | `easeOutCubic` |

Nothing animates longer than 300ms on the critical path. The count-up on the
completion screen is the one place we spend time for effect.

## Accessibility

- Contrast ≥ 4.5:1 for text on its background in both themes.
- Correct/wrong is never conveyed by colour alone — a check or cross glyph and
  a text label always accompany it.
- All icon-only controls carry a `Semantics` label.
- Layout holds at 200% text scale; the action bar grows rather than clipping.
