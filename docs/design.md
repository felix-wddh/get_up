# GetUp — iOS Design System & Product Specification (v2)

> **One sentence:** GetUp is an iPhone alarm app that turns off only when you physically walk your phone to an NFC tag in another room. This document is the single source of truth for its visual language, components, motion, copy, and iOS implementation.
>
> **What changed in v2:** The visual language has been rebuilt to feel **contemporary, native to modern iOS, and elegantly light**. White-and-blue logic is preserved, but page surfaces are now a softly tinted blue-gray, cards are larger-radius with soft halo shadows, primary CTAs are fully-rounded pills, and the signature element is a large circular progress ring. A restrained "liquid glass" treatment appears on floating chrome (status bar overlays, the active alarm halo) — never as a heavy effect.

---

## 0. Table of Contents

1. [Design Principles](#1-design-principles)
2. [Visual Language](#2-visual-language)
3. [Typography](#3-typography)
4. [Color System](#4-color-system)
5. [Spacing System](#5-spacing-system)
6. [Components](#6-components)
7. [Screen Designs](#7-screen-designs)
8. [iPhone UX & Navigation](#8-iphone-ux--navigation)
9. [Motion & Transitions](#9-motion--transitions)
10. [NFC Experience](#10-nfc-experience)
11. [Tone of Voice](#11-tone-of-voice)
12. [Iconography](#12-iconography)
13. [Accessibility](#13-accessibility)
14. [iOS Implementation Notes](#14-ios-implementation-notes)
15. [Design Tokens](#15-design-tokens)

---

## 1. Design Principles

GetUp is a tool you use at the worst moment of the day — half-awake, eyes squinting, brain offline. The product must feel like a quiet, confident iOS utility, not a toy and not a productivity dashboard.

| # | Principle | What it means | What it rules out |
|---|---|---|---|
| 1 | **Simplicity is key** | One job per screen, one primary action. Whitespace is a feature. | Density, dual CTAs, dashboards. |
| 2 | **Physical action drives behavior** | The product extends into the real world through the NFC tag. The UI rewards motion, not taps. | Pure-digital dismiss shortcuts. |
| 3 | **Calm urgency** | At 6:30 AM the app insists — but never yells. Motion is firm, copy steady, color controlled. | Red flashing screens, all-caps copy, aggressive haptics. |
| 4 | **Frictionless mornings** | The morning path is muscle-memory: ringtone → walk → scan → done. No decisions required after the alarm fires. | Multi-step dismiss flows, mandatory choices. |
| 5 | **Native iPhone feel** | Looks and behaves like Apple shipped it. Predictable patterns, system primitives, full Dynamic Type. | Custom alert dialogs, marketing splash screens, off-platform fonts. |
| 6 | **Consistency across the entire app** | One spacing system, one button system, one corner radius logic, one motion library. | Local exceptions, special-cased screens. |

**Golden rule** — *Every pixel justifies its presence. If a screen can be quieter, it should be.*

---

## 2. Visual Language

GetUp's look is defined by five layered ideas.

### 2.1 Layered light

- The **page background** is a soft, cool blue-gray (`color/canvas` = `#EEF2F8`), not pure white. It reads as ambient light — the room around the content.
- **Cards** are pure white, floating above the canvas with generous corner radii (24–28 px) and soft, diffused shadows. They feel weightless rather than heavy.
- **Hero surfaces** (active alarm, scan screen, success screen) are filled with `color/primarySoft` (`#F4F8FF`) — a barely-there blue. Same shape language, slightly cooler tone, signals "this is a key moment."

### 2.2 Surface treatment

| Surface | Background | Radius | Border | Shadow |
|---|---|---|---|---|
| Page canvas | `#EEF2F8` | — | — | — |
| Default card | `#FFFFFF` | 24 px | none | `shadow/card` |
| Hero card | `#F4F8FF` | 28 px | none | `shadow/card` |
| Floating chrome (status overlays, tab bar) | `rgba(255,255,255,0.72)` + 24 px backdrop blur | 0 / variable | 1 px `rgba(255,255,255,0.6)` top | `shadow/glass` |
| Bottom sheet | `#FFFFFF` | 28 px top | none | `shadow/sheet` |

### 2.3 Liquid glass — used in three places, never more

Apple's translucent material is a signature of modern iOS. We adopt it **only where it earns its keep**:

1. **The active alarm halo** — a soft, translucent blue ring behind the scan target. It pulses, but stays subtle.
2. **The floating tab bar** — when content scrolls beneath it, the bar uses backdrop blur so the content shows through faintly.
3. **The status overlay** during the NFC scan flash — a brief translucent veil, 220 ms.

Everywhere else, surfaces are solid. **No frosted modals, no glassmorphic cards, no glass buttons.** The product is light, not slick.

### 2.4 Depth & shadow

Shadows are large, soft, and slightly cool-toned to match the canvas. Never harsh, never directional.

| Token | Value | Use |
|---|---|---|
| `shadow/card` | `0 4px 24px rgba(31,77,138,0.06), 0 1px 2px rgba(31,77,138,0.04)` | Default card and hero card |
| `shadow/raised` | `0 12px 36px rgba(31,77,138,0.10), 0 2px 6px rgba(31,77,138,0.06)` | The primary CTA button (gives it lift on the page) |
| `shadow/sheet` | `0 -8px 32px rgba(31,77,138,0.08)` | Bottom sheet top edge |
| `shadow/glass` | `0 8px 24px rgba(31,77,138,0.08)` | Floating chrome (tab bar, sticky header) |
| `shadow/halo` | `0 0 64px rgba(0,112,232,0.18)` | Behind the active scan target |
| `shadow/none` | none | List rows, dense interior elements |

### 2.5 Corner radius system

| Token | Value | Use |
|---|---|---|
| `radius/xs` | 6 px | Tags, badges |
| `radius/sm` | 12 px | Pills inside cards, input fields |
| `radius/md` | 16 px | Icon containers, day chips |
| `radius/lg` | 20 px | Secondary buttons, search field |
| `radius/xl` | 24 px | Default cards |
| `radius/2xl` | 28 px | Hero cards, modal sheet top |
| `radius/full` | 999 px | Primary buttons, status dots, day-of-week selectors |

**The rule:** the larger the surface, the larger the radius. Pill buttons read as actions; rounded cards read as zones; subtle radii read as components.

### 2.6 Borders

Borders are used sparingly — only on the **secondary button** and on **input fields**. Default border is 1 px `color/border` (`#E6EAF0`). Cards rely on shadow + background contrast for separation; they have no border.

---

## 3. Typography

GetUp uses **Inter** (the typeface from dataleap.ai) as its single type family across the entire app. Inter is a clean, contemporary, highly-legible sans-serif designed for screens — it has the open apertures and tight metrics modern product UI needs, plus full weight coverage (100–900) and tabular figures for time displays. Use Inter Display (the optical cut tuned for ≥ 20 pt) for any text at headline scale or larger; Inter for everything below.

> **Font source note.** Pulling the exact webfont from dataleap.ai directly wasn't possible (their CSS is served cross-origin and the page blocks iframe embedding), so this spec commits to Inter — Framer's default and the closest matching open-source typeface to dataleap.ai's visual character. If the actual face is named (e.g. Geist, PP Neue Montreal, Söhne), swap the family in §15.2; nothing else changes.

### 3.0 Loading Inter

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Inter+Tight:wght@600;700&display=swap" rel="stylesheet">
```

On iOS, ship Inter as a bundled font (TTF or variable WOFF2 in the app bundle) and register via `UIFontDescriptor` so it works offline and respects Dynamic Type. Use **SF Pro** as the system fallback if Inter fails to load.

### 3.1 Type scale

| Token | Style | Size / Line height | Weight | Tracking | Usage |
|---|---|---|---|---|---|
| `type/largeTitle` | Large Title | 34 / 41 | Bold (700) | +0.37 | Onboarding hero, "Good morning" |
| `type/screenTitle` | Screen Title | 28 / 34 | Bold (700) | +0.36 | Page titles ("Your alarms") |
| `type/sectionHeader` | Section Header | 20 / 25 | Semibold (600) | +0.38 | Section titles inside lists |
| `type/headline` | Headline | 17 / 22 | Semibold (600) | -0.43 | Card titles, list row primary |
| `type/body` | Body | 17 / 22 | Regular (400) | -0.43 | Default paragraph, list row body |
| `type/secondaryBody` | Secondary Body | 15 / 20 | Regular (400) | -0.24 | Secondary text, metadata, helpers |
| `type/caption` | Caption | 13 / 18 | Regular (400) | -0.08 | Labels, timestamps, footnotes |
| `type/microCaption` | Micro Caption | 11 / 13 | Medium (500) | +0.06 | Badge labels, micro-tags |
| `type/button` | Button | 17 / 22 | Semibold (600) | -0.43 | All button labels |
| `type/ringValue` | Progress Ring Value | 56 / 60 | Bold (700), tabular nums | -0.8 | Big number inside a progress ring |
| `type/countdown` | Alarm Countdown | 96 / 96 | Semibold (600), Inter Tight, tabular nums | -1.2 | Active alarm time display |

### 3.2 Usage rules

- **One title per screen.** Never stack `largeTitle` with `screenTitle`.
- **Use `screenTitle` left-aligned for tab roots** (e.g. "Your alarms"). For modal/pushed screens, center a `headline`-sized title in the nav bar.
- **Body text color is `text.primary`** unless deliberately demoted.
- **Line length** stays 40–70 characters for `body`.
- **Numbers** in time, counters, and ring values use tabular figures (`font-feature-settings: "tnum"`).
- **Never use bold inside body copy for emphasis.** Use weight only to denote role.

### 3.3 Dynamic Type

Every text token maps to an iOS text style (`UIFont.TextStyle.title1`, `.body`, etc.) and respects user preference from XS to AX5. The alarm countdown is the only exception: it scales with the viewport, not Dynamic Type, because distance legibility wins.

Because Inter is a custom (non-system) font, register each Inter weight with a corresponding `UIFontMetrics` instance so Dynamic Type scaling still applies — `UIFontMetrics(forTextStyle: .body).scaledFont(for: interRegular17)` and so on. Do *not* hard-code point sizes.

---

## 4. Color System

White is the floor, blue is action, black is meaning. Every other color is a functional exception used at small scale.

### 4.1 Primary palette

| Token | Hex | Role |
|---|---|---|
| `color/primary` | `#0070E8` | All primary actions, active toggles, focused inputs, key icons, progress ring stroke |
| `color/primaryPressed` | `#005FC4` | Pressed state for primary action |
| `color/primaryLight` | `#EAF4FF` | Tinted icon containers, selected row highlight, ring track |
| `color/primarySoft` | `#F4F8FF` | Hero card backgrounds, scan screen background |

### 4.2 Neutrals

| Token | Hex | Role |
|---|---|---|
| `color/white` | `#FFFFFF` | Card surface, modal surface, button label (primary) |
| `color/canvas` | `#EEF2F8` | App page background — the cool tinted ambient surface |
| `color/offWhite` | `#FAFBFC` | Alternative background for screens that need to read pure |
| `color/surface` | `#F5F7FA` | Inactive chips, input fields, time picker |
| `color/border` | `#E6EAF0` | Secondary button stroke, input border |
| `color/divider` | `#EEF1F5` | List separators (used only when necessary; gap-based separation is preferred) |
| `color/textPrimary` | `#111111` | Headlines, body, primary content |
| `color/textSecondary` | `#5B6573` | Subheads, secondary list text |
| `color/textTertiary` | `#8A94A3` | Captions, metadata, helper text |
| `color/textDisabled` | `#B8C0CC` | Disabled label, placeholder |

### 4.3 Functional

Used only when meaning is truly green / orange / red. Never decoration.

| Token | Hex | Background | Role |
|---|---|---|---|
| `color/success` | `#18A957` | `#E8F7EF` | Streak confirmed, scan accepted, success accent |
| `color/warning` | `#FF9F0A` | `#FFF4E0` | "Tag is too close to bed" advisory, weak NFC signal |
| `color/error` | `#E5484D` | `#FFEEEF` | Failed scan banner, destructive confirm, validation |

### 4.4 Accent badges (used only in list rows for category icons)

These are the only place GetUp uses warm color. They appear *inside* a 40 × 40 circle as an icon badge, never as a fill larger than that.

| Token | Hex | Used for |
|---|---|---|
| `accent/orange` | `#FF8A3D` | Streak / morning category |
| `accent/violet` | `#8B5CF6` | Wind-down / evening category |
| `accent/teal` | `#14B8A6` | Routine / hydration category |
| `accent/rose` | `#F43F5E` | Personal records |

### 4.5 Usage rules

- **No more than two non-neutral colors per screen.** Blue + one functional/accent color.
- **Backgrounds for status colors are paired tints** — never use the saturated hex as a fill larger than 40 × 40.
- **Never combine blue and green as adjacent CTAs** — they read as competing intents.
- **Saturated accent colors only appear inside circles.** Outside of those badges, accents are not allowed.

---

## 5. Spacing System

A single 4-pt scale governs all spacing.

| Token | Value | Primary use |
|---|---|---|
| `space/2xs` | **4 px** | Icon ↔ adjacent label, hairline separations |
| `space/xs` | **8 px** | Tag inner padding, dense vertical gap |
| `space/sm` | **12 px** | Button inner padding, small card interior |
| `space/md` | **16 px** | Screen edge gutter, list row vertical padding |
| `space/lg` | **20 px** | Card internal padding, comfortable group gap |
| `space/xl` | **24 px** | Section gap, card external margin |
| `space/2xl` | **32 px** | Hero block spacing, top of screen padding |
| `space/3xl` | **40 px** | Onboarding screen verticals, modal top padding |
| `space/4xl` | **56 px** | Major moment dividers |

### 5.1 Layout rules for iPhone

- **Edge gutter:** `space/lg` (20 px) on phones ≥ 390 pt; `space/md` (16 px) on smaller devices.
- **Card external margin:** `space/lg` from the edge gutter; cards never touch screen edges.
- **Card-to-card gap:** `space/md` (16 px).
- **Section gap (header → cards):** `space/xl` (24 px).
- **Vertical rhythm:** 8-pt multiples. 4 px is reserved for icon-to-text relationships only.
- **Safe areas:** never crowd within 8 px of the home indicator or the dynamic island.
- **One-thumb reach:** primary actions sit within the bottom 280 pt.

---

## 6. Components

Every component below is defined by its anatomy, default state, interactive states, and the tokens it consumes. Components are listed roughly in order of importance.

### 6.1 Primary Button (pill)

The signature action element. Fully-rounded pill, vivid blue, with `shadow/raised` for lift.

| Property | Value |
|---|---|
| Shape | Pill — `radius/full` (height ÷ 2) |
| Height | 56 px |
| Min width | 160 px, or full-width with `space/lg` insets |
| Padding | 16 vertical, 28 horizontal |
| Background | `color/primary` |
| Label | `type/button`, `color/white` |
| Shadow | `shadow/raised` (lifts off the canvas) |
| Pressed | Background → `color/primaryPressed`, scale 0.98, shadow drops to `shadow/card`, 120 ms ease-out |
| Disabled | Background `color/surface`, label `color/textDisabled`, no shadow |
| Loading | 20 × 20 indeterminate spinner replaces label, no scale press |
| Haptic | `.impact(.medium)` on tap, `.notification(.success)` on completion |

Optional **leading icon** (20 × 20, white) sits 8 px before the label. Used sparingly — typically only on the alarm-ringing primary action.

### 6.2 Secondary Button

White pill with a thin border. Used as an alternative, never alone.

| Property | Value |
|---|---|
| Shape | Pill — `radius/full` |
| Height | 56 px |
| Background | `color/white` |
| Border | 1 px solid `color/border` |
| Label | `type/button`, `color/textPrimary` |
| Pressed | Background → `color/surface`, scale 0.98 |
| Disabled | Border `color/divider`, label `color/textDisabled` |
| Shadow | none |

### 6.3 Ghost / Text Button

Inline action, low weight.

| Property | Value |
|---|---|
| Height | 44 px tap target, label centered |
| Background | None |
| Label | `type/button`, `color/primary` |
| Pressed | Label `color/primaryPressed`, no scale |
| Disabled | Label `color/textDisabled` |

### 6.4 Destructive Button

White pill with red label. Reserved for irreversible actions.

| Property | Value |
|---|---|
| Shape | Pill — `radius/full` |
| Background | `color/white` |
| Border | 1 px solid `color/border` |
| Label | `type/button`, `color/error` |
| Pressed | Background `color/error` tint background (`#FFEEEF`), label remains `color/error` |
| Inverted form | Used inside an action sheet confirming an already-committed delete: solid `color/error` background, white label, pill shape. |

### 6.5 Icon Button

A square 44 × 44 tap target with a 24 × 24 icon centered.

| Property | Value |
|---|---|
| Shape | `radius/md` (16 px) |
| Background | `color/white` (default) or `color/primaryLight` (active) |
| Shadow | `shadow/card` when sitting on the canvas (e.g. the floating back button) |
| Icon | 24 × 24, stroke 2 px, `color/textPrimary` (default) or `color/primary` (active) |
| Pressed | Background `color/surface`, scale 0.96 |

Used for nav (back, settings), filter toggles, and the floating-chrome utility buttons.

### 6.6 Pills & Chips

| Variant | Background | Label | Border | Use |
|---|---|---|---|---|
| Day chip (unselected) | `color/surface` | `type/secondaryBody`, `textPrimary` | none | Day-of-week picker |
| Day chip (selected) | `color/primary` | `type/secondaryBody`, `color/white` | none | Selected day |
| Filter chip | `color/white` | `type/caption`, `textPrimary` | 1 px `color/border` | Inline filters |
| Tag pill | `color/primaryLight` | `type/microCaption`, `color/primary` | none | Metadata tags |
| Status pill | functional background | functional foreground | none | Active state indicator |

Day chips are 40 × 40, fully rounded (`radius/full`). Filter and tag pills are 28 px tall, `radius/full`, 12 px horizontal padding.

### 6.7 Cards

The default container of the system.

| Property | Value |
|---|---|
| Background | `color/white` |
| Radius | `radius/xl` (24 px) for standard; `radius/2xl` (28 px) for hero |
| Padding | `space/lg` (20 px) standard; `space/xl` (24 px) hero |
| Shadow | `shadow/card` |
| Border | none |
| Pressed (if tappable) | Background → `#F8FAFD`, scale 0.99, 120 ms ease-out |

Cards never sit edge-to-edge; they always have at least `space/lg` margin from the screen gutter.

### 6.8 Input Field

| Property | Value |
|---|---|
| Height | 52 px |
| Background | `color/surface` |
| Radius | `radius/md` (16 px) |
| Padding | 14 vertical, 16 horizontal |
| Label | `type/body`, `color/textPrimary` |
| Placeholder | `type/body`, `color/textTertiary` |
| Focused | Background `color/white`, 2 px ring `color/primary` at 100% (inset), no border |
| Error | 2 px ring `color/error`, inline message in `type/caption`, `color/error` below |

### 6.9 Toggle

iOS-native UISwitch dimensions.

| State | Spec |
|---|---|
| On | Track `color/primary`, thumb `color/white` |
| Off | Track `color/surface`, thumb `color/white`, 1 px `color/border` |
| Disabled on | Track at 40% opacity |
| Animation | 220 ms `easing/standard` |

### 6.10 Time Picker

Three-wheel picker (hours / minutes / period) for alarm setup.

| Property | Value |
|---|---|
| Wheel width | 96 px each, gap 8 px |
| Surface behind selected row | `color/primarySoft`, `radius/lg` (20 px), full picker width |
| Selected value | `type/screenTitle` (28 / 34), tabular nums |
| Adjacent values | `type/sectionHeader`, `color/textTertiary`, scale 0.9, opacity 0.5 |
| Spin haptic | `.selection` per tick |

### 6.11 Alarm Card

| Element | Spec |
|---|---|
| Container | Card, `radius/xl`, `shadow/card`, padding 20 vertical / 20 horizontal |
| Layout | Row: time (left) — label (center) — toggle (right) |
| Time | `type/screenTitle` (28 px bold), tabular nums |
| Label | `type/secondaryBody`, `color/textSecondary` (e.g. "Weekdays · Bathroom tag") |
| Toggle | Right-aligned, vertically centered |
| Pressed | Background → `#F8FAFD`, scale 0.99 |
| Drag-to-reorder | Surfaced via long-press; row floats with `shadow/raised` while dragged |

### 6.12 NFC Setup Card

A hero card walking the user through pairing the tag.

```
┌────────────────────────────────────────────┐
│                                            │
│  ┌──┐                                      │
│  │◎ │  ← 48×48 tinted icon container       │
│  └──┘                                      │
│                                            │
│  Place your tag far from bed               │  ← sectionHeader
│                                            │
│  The bathroom or kitchen works best.       │  ← body, textSecondary
│  You'll need to walk to it each morning.   │
│                                            │
│  [          Set up tag          ]          │  ← primary pill, full width
│                                            │
└────────────────────────────────────────────┘
```

- Surface: `color/primarySoft`
- Radius: `radius/2xl`
- Padding: `space/xl` (24 px)
- Spacing inside: 16 / 12 / 8 / 20 (icon → title → body → CTA)

### 6.13 Progress Ring (signature component)

The hero of the home screen and the heart of the active-alarm screen.

| Property | Value |
|---|---|
| Outer diameter | 240 px (home), 280 px (alarm) |
| Stroke width | 14 px |
| Track color | `color/primaryLight` |
| Progress color | `color/primary` |
| Cap | round |
| Start angle | -90° (12 o'clock) |
| End cap dot | A 14 px filled `color/primary` dot at the end of the arc, with `shadow/halo` |
| Tick dots | Optional 4 px `color/primary` dots floating at 25 / 50 / 75% positions |
| Center label | `type/ringValue` (56 / 60 bold) above `type/secondaryBody` `color/textSecondary` |
| Background | Sits on a hero card (`color/primarySoft`) so the soft halo reads |

The end-cap dot is what makes the ring feel modern — it gives the progress a tactile, light-source quality, matching the reference visual direction.

### 6.14 Bottom Navigation (floating tab bar)

| Property | Value |
|---|---|
| Position | Floating, 16 px from bottom safe area |
| Width | Hugs content with 24 px horizontal padding |
| Height | 64 px |
| Shape | Pill — `radius/full` |
| Background | `rgba(255,255,255,0.84)` + 24 px backdrop blur |
| Border | 1 px `rgba(255,255,255,0.6)` (inner top) — gives the glass edge |
| Shadow | `shadow/glass` |
| Tabs | Three: Alarms, Progress, Settings |
| Tab anatomy | 24 × 24 icon stacked above `type/microCaption`; vertical padding 10 px |
| Active | Icon + label `color/primary`; subtle 32-px wide `color/primaryLight` capsule behind it |
| Inactive | Icon + label `color/textTertiary` |
| Tap haptic | `.selection` |

This is the **one place** where liquid glass appears in the main app surface. The floating pill reads as a contemporary iOS element without feeling like a gimmick.

### 6.15 Modal Sheet

| Property | Value |
|---|---|
| Background | `color/white` |
| Top radius | `radius/2xl` (28 px) |
| Grabber | 36 × 5 px, `color/border`, 2.5 px radius, 8 px from top |
| Title padding | 24 px top, 16 px bottom |
| Default detent | `medium` (50%) — `large` only when content demands |
| Backdrop | `rgba(17,17,17,0.32)` |
| Shadow | `shadow/sheet` |

### 6.16 Toast / Banner

Slides down from the top safe area, auto-dismisses after 4 s.

| Property | Value |
|---|---|
| Width | full width minus `space/lg` gutters |
| Padding | 14 vertical, 16 horizontal |
| Radius | `radius/lg` (20 px) |
| Background | `color/white` |
| Shadow | `shadow/raised` |
| Layout | leading 20 × 20 status icon — `type/body` headline — trailing close X (icon button 32 × 32) |
| Variants | Success (icon `color/success`), Error (icon `color/error`), Info (icon `color/primary`) |
| Haptic | matches variant |

### 6.17 Empty State

```
        ◎              ← 64 × 64 tinted icon container, primaryLight bg, primary line icon

   No alarms yet            ← sectionHeader, textPrimary
   
   Tap + to create your     ← body, textSecondary
   first morning alarm.

   [    Create alarm    ]   ← primary pill
```

Centered vertically within the available scrollable region; `space/2xl` between elements.

### 6.18 Error State

**Inline error** (under a field): 8 px below the field; `type/caption`; `color/error`; leading 14 px alert icon.

**Banner error** (top of screen): same anatomy as Toast (6.16) with the Error variant; auto-dismisses after 4 s; tappable to retry; haptic `.notification(.error)`.

**Full-screen error** (rare): card-style layout centered on screen — 64 × 64 alert icon container with `color/errorBg` background and `color/error` icon, `screenTitle` heading, `body` `textSecondary` description, primary "Try again" pill.

---

## 7. Screen Designs

Each screen below has a one-line purpose, the dominant components, and a layout sketch.

### 7.1 Welcome / Onboarding

**Purpose**: Explain the premise in one sentence; defer permissions.

```
   ── page bg: color/canvas ──
   
   ↑ 56 px
   
   ◎ ◎ ◎                                   ← three 8-px primaryLight dots
   
   ↑ 32 px
   
   Get out of bed.                         ← largeTitle (34/41 bold)
   Actually.                               ← largeTitle
   
   ↑ 16 px
   
   GetUp only turns off when you walk      ← body, textSecondary
   your phone to a tag in another room.    ← max 60ch
   
   (flex spacer; an animated illustration  
    placeholder fills this region — see §10.1)
   
   [       Get started       ]             ← primary pill, full-width
   
   ↑ 12 px
   
   I already have an account               ← ghost button
   
   ↓ 24 px (bottom safe)
```

Three slides total. Dot indicator (8 px filled, 6 px empty, 8 px gap) sits 16 px above the primary CTA.

### 7.2 NFC Tag Setup

**Purpose**: Pair the physical tag and confirm location.

- Floating back button (icon button, white, `shadow/card`) at top-left.
- Step header: `type/microCaption` "Step 1 of 2", then `type/screenTitle` "Place the tag".
- **NFC Setup Card** (§6.12) explaining placement, 24 px below the header.
- Animated placement illustration: 240 × 240, sits inside the hero card, dashed border, monospace label "phone + tag illustration".
- Primary pill "Hold phone near tag" at screen bottom.
- Ghost button "I'll do this later" below.

After successful pairing → Step 2: "Name this location" — a single input field with day-chip-style suggestions (Bathroom / Kitchen / Hallway / Custom).

### 7.3 Alarm Creation

**Purpose**: Pick a time, days, and routine.

- Modal sheet, `large` detent.
- Top: grabber, then "Cancel" (ghost, left) / "New alarm" (centered headline) / "Save" (ghost, right, `color/primary`).
- **Time picker** centered, 24 px top margin inside sheet.
- Day picker: seven 40 × 40 day chips, S M T W T F S, gap 6 px, centered.
- **Tag row** card (tappable): leading 48 × 48 tinted icon container (NFC glyph), `headline` "Bathroom tag", `secondaryBody` `textSecondary` "Paired May 12", trailing chevron.
- **Routine row** card (tappable): tinted icon container (water-drop), `headline` "Morning routine", `secondaryBody` `textSecondary` "3 steps", trailing chevron.
- **Sound row** card (tappable): tinted icon container (waveform), `headline` "Sound", `secondaryBody` `textSecondary` "Sunrise · gradual".

### 7.4 Alarm Overview (Home)

**Purpose**: At-a-glance status. The most-used screen.

```
   ── page bg: color/canvas ──
   
   ↑ 56 px
   
   Good morning, Mads                      ← screenTitle (28 bold)
   Tuesday, May 26                         ← secondaryBody, textSecondary
   
   ↑ space/xl
   
   ┌─ Hero card (primarySoft, radius/2xl) ────────────┐
   │                                                  │
   │              ╭───── 240 px ─────╮                │
   │              │                  │                │
   │              │       47         │  ← ringValue   │
   │              │    on time       │  ← secondary   │
   │              │                  │                │
   │              ╰──────────────────╯                │
   │              ↑ progress ring §6.13               │
   │                                                  │
   │   12-day streak · Best yet                       │  ← headline center
   │                                                  │
   └──────────────────────────────────────────────────┘
   
   ↑ space/xl
   
   Your alarms                              ← sectionHeader, left-aligned
   
   ↑ space/md
   
   Alarm Card  06:30 · Weekdays · Bathroom        [⬤]
   Alarm Card  09:15 · Weekends · Kitchen         [○]
   
   ↑ space/md
   
   [  + Add alarm  ]                        ← secondary pill, full-width
   
   ↓ floating tab bar (bottom)
```

### 7.5 Active Alarm Ringing

**Purpose**: Wake the user. Move them physically. This is the most important screen in the app.

- Full-screen takeover (over lock screen via critical alert).
- Background: `color/canvas`, with a slow ambient pulse (see §9.4).
- **Top safe area:** `screenTitle` "Go scan your tag", centered. Below: `secondaryBody` `textSecondary` "Bathroom · about 12 steps away."
- **Center:** the 280 px progress ring. Inside it:
  - `type/countdown` showing **current time** (e.g. "06:30") — large, calm.
  - Below the time: `type/secondaryBody` `textTertiary` "Alarm" (small, almost a watermark).
- **Halo:** `shadow/halo` behind the ring; the ring's stroke gently rotates (0.5° per frame, continuous, see §9.4).
- **Bottom safe area:** no buttons by default. If "Snooze" is enabled in Settings, a single ghost text-button "Snooze 5 min" appears above the safe area.
- No dismiss button. No giant red wake button.

### 7.6 NFC Scan Screen (live scanning state)

Same layout as §7.5 with two changes:

1. The ring stroke pulses faster (1.2 s loop) and the end-cap dot grows to 18 px with `shadow/halo` intensified.
2. The center text changes to `screenTitle` "Hold steady…" with `type/secondaryBody` "Reading tag" beneath.

This state is brief (typically < 1 second).

### 7.7 Scan Success Screen

**Purpose**: Confirm the read.

Triggered the instant a valid tag is read.

- Full-screen flash: background `color/canvas` → `color/primarySoft` over 220 ms.
- The progress ring is replaced by an **animated check** — 96 × 96 stroked check, `color/primary`, drawn in over 300 ms, centered inside a `color/primaryLight` 160 × 160 circle.
- 6 light particles burst outward (see §9.5).
- `type/largeTitle` "You're up." appears beneath, fading in over 220 ms.
- Haptic: `.notification(.success)`.
- Auto-advances to the **Morning Success** screen (§7.8) after 800 ms.

### 7.8 Morning Success / Streak Screen

**Purpose**: Reward consistency, motivate the next morning.

```
   ── page bg: color/canvas ──
   
   Day 13.                                  ← largeTitle, textPrimary
   Best streak yet.                         ← body, textSecondary
   
   ↑ space/2xl
   
   ┌─ Hero card (primarySoft) ─────────────────────┐
   │                                               │
   │  ◯ ● ● ● ● ● ● ● ● ● ● ● ● ● ●     14 dots   │
   │  (today highlighted; past 14 days)            │
   │                                               │
   │  You've gotten up on time 13 mornings         │
   │  in a row.                                    │
   │                                               │
   └───────────────────────────────────────────────┘
   
   ↑ space/xl
   
   This morning                             ← sectionHeader
   
   Card row · 06:30 woke up
   Card row · 06:32 scanned bathroom tag
   Card row · 38s time to scan  (your fastest)
   
   ↓ flex
   
   [        Close        ]                  ← secondary pill
```

### 7.9 Progress / Habit Overview

**Purpose**: Long-view of consistency.

- `screenTitle` "Progress" (left-aligned).
- Stat row (3 columns of cards, gap 12 px):
  - Card 1: `ringValue` "47", `caption` `textSecondary` "Mornings on time"
  - Card 2: `ringValue` "21", `caption` "Longest streak"
  - Card 3: `ringValue` "06:34", `caption` "Avg wake time"
- **Hero card** "Last 12 weeks" containing a heatmap grid: 7 × 12 cells, each 18 × 18, gap 4 px. Filled `color/primary`, missed `color/border`, future `color/surface`.
- **Section "Insights"** — cards with subtle leading 48 × 48 tinted icon containers (orange, violet, teal accents from §4.4):
  - "Your streak peaks on weekdays."
  - "Scans are fastest in the bathroom."
  - "You're 14 minutes earlier than last month."

### 7.10 Settings

**Purpose**: Configure permissions, behavior, and personal preferences.

Grouped list, iOS-native style but using GetUp cards instead of native UITableView grouped style. Each group is a card; rows inside it are separated by `color/divider` hairlines.

Groups, in order:
- **Account** — Name, Email, Sign out
- **Alarms** — Default sound, Snooze (Off / 5 min once), Vibration pattern
- **NFC** — Paired tags (list), Add new tag
- **Notifications** — Bedtime reminders, Streak nudges
- **Appearance** — Theme (Auto / Light / Dark)
- **Accessibility** — Reduce motion, Larger text, Haptics
- **Support** — Help, Contact, Terms, Privacy
- **Danger zone** — "Reset all data" (destructive pill, full width inside its own card)

### 7.11 Help / Troubleshooting

**Purpose**: Self-serve answers, calmly written.

- Search field at top (52 px height, `color/surface` background, `radius/md` 16 px, leading 20 × 20 search icon).
- **Featured cards** — three side-by-side hero cards (`primarySoft`, `radius/2xl`):
  - "NFC not scanning?"
  - "Battery and background"
  - "Why critical alerts?"
- Below: alphabetical FAQ list (cards with leading tinted icon container, headline title, secondary helper text, trailing chevron).
- Last item: "Still stuck → Contact support" (ghost button).

---

## 8. iPhone UX & Navigation

### 8.1 First-time user flow

```
Splash (200 ms)
  → Onboarding 1: Premise (§7.1, slide 1)
  → Onboarding 2: How it works (§7.1, slide 2)
  → Onboarding 3: What you'll need (§7.1, slide 3)
  → Permission ask: Notifications (system sheet, explained inline first)
  → Permission ask: Critical alerts (system sheet, explained inline first)
  → NFC tag setup (§7.2, skippable)
  → First alarm creation (§7.3)
  → Home (§7.4)
```

### 8.2 Returning user flow

```
Splash → Home (Alarms tab)
```

No login wall. Account sync is optional, surfaced under Settings.

### 8.3 Alarm ringing flow

```
[Alarm fires (critical alert)]
  → Active Alarm screen (§7.5)
  → User physically walks to tag
  → NFC reader picks up tag
  → Scan screen (§7.6) — transient
  → Scan Success (§7.7) — 800 ms
  → Morning Success (§7.8)
  → On tap "Close" or 4 s of idle → Home
```

### 8.4 Failed NFC flow

```
Active Alarm
  → User taps phone to tag
  → Tag UID mismatch OR weak read
  → Inline shake (see §9.6) + banner: "That's not your tag. Try again."
  → Alarm continues to ring
  → After 3 consecutive failures within 60 s → modal sheet with tips:
     - "Hold phone flat against the tag"
     - "Touch the top edge of your phone"
     - "Remove your case if it's thick"
     - "Use backup unlock" link (only if enabled in Settings)
```

### 8.5 Edit alarm flow

```
Home → tap Alarm Card
  → Alarm detail (same layout as Creation, prefilled)
  → Save → toast "Alarm updated"
  → Or "Delete alarm" (destructive pill, confirm action sheet)
```

### 8.6 Settings flow

```
Tab bar → Settings → grouped cards (§7.10)
  → Tap a row → push detail screen (each row that has detail uses a new push)
  → Toggles change in place (no detail screen)
```

All navigation uses standard iOS push (right-to-left slide). Modal flows (Alarm Creation, NFC pairing) use bottom-sheet presentation.

---

## 9. Motion & Transitions

Motion in GetUp is short, decisive, and ignorable. Every animation has a job — confirm a state change, never entertain.

### 9.1 Easing curves

| Token | Cubic-bezier | Use |
|---|---|---|
| `easing/standard` | `(0.2, 0, 0, 1)` | Default for entrances and most transitions |
| `easing/decelerate` | `(0, 0, 0, 1)` | Sheet entry, card reveal |
| `easing/accelerate` | `(0.3, 0, 1, 1)` | Sheet exit, dismiss |
| `easing/emphasized` | `(0.2, 0, 0, 1)` over 500 ms | Hero moments (success screen) |
| `easing/spring` | spring(stiffness 380, damping 30) | Button press, toggle thumb, pill state changes |

### 9.2 Durations

| Token | Value | Use |
|---|---|---|
| `motion/fast` | 150 ms | Toggles, button press scale, icon button feedback |
| `motion/base` | 220 ms | Page transitions, modal fade, card reveals |
| `motion/slow` | 300 ms | NFC confirmation flash, checkmark draw, hero-card entrance |
| `motion/hero` | 500 ms | Success screen entry, streak reveal |
| `motion/ambient` | 1.6 s — 2.4 s | Background pulses, ring rotation |

### 9.3 Page transitions

- **Push**: new screen slides from right, 220 ms `easing/standard`; current screen drifts left 16 px and dims to a 60% white overlay.
- **Modal sheet**: bottom-up slide, 300 ms `easing/decelerate`; backdrop fades in over 220 ms.
- **Tab switch**: cross-fade only, 150 ms — no slide. (The floating tab bar stays put.)

### 9.4 Active alarm motion

- **Ambient page pulse**: `color/canvas` ↔ a slightly cooler `#E8EEF6`, 2.4 s loop, `easing/standard`. Very subtle — visible mainly out of the corner of the eye.
- **Ring stroke rotation**: 360° over 8 s, linear, looping. Continuous but slow — gives the screen quiet life.
- **End-cap dot halo pulse**: shadow blur 48 → 72 → 48 px, 1.6 s loop, ease-in-out.
- **Countdown digits**: do not animate; they reflect device time.

### 9.5 NFC scan motion

1. **Reading state** (phone near tag): ring stroke speeds to 4 s rotation, end-cap dot grows to 18 px, halo intensifies.
2. **Read success**: background flash to `color/primarySoft` over 220 ms → check draws in over 300 ms (`stroke-dasharray` animation), `easing/emphasized` → 6 particles burst outward 32 px over 400 ms ease-out, fading to 0.
3. **Haptics**: `.impact(.light)` on first detection, `.notification(.success)` on confirmed read.

### 9.6 Error shake

- Used for failed NFC, invalid input.
- Horizontal translate: 0, -8, 8, -6, 6, -3, 3, 0 px.
- Duration 320 ms total.
- Accompanied by `.notification(.error)` haptic.
- **Reduce motion**: replaced by a 200 ms background flash to `#FFEEEF`.

### 9.7 Card entrance

- Cards in a list fade in (opacity 0 → 1) and translate Y +8 px → 0.
- Stagger 40 ms per card, max 5 animated; rest appear instantly.
- 220 ms each, `easing/decelerate`.
- Disabled when "Reduce motion" is on.

### 9.8 Button press

- Scale 1 → 0.98, 120 ms ease-out on touch down.
- On release: spring back to 1 over 180 ms with `easing/spring`.
- Primary button shadow drops from `shadow/raised` to `shadow/card` while pressed, lifts back on release.

### 9.9 Bottom sheet motion

- Enter: 300 ms `easing/decelerate`; backdrop opacity 0 → 0.32 over 220 ms.
- Exit: 220 ms `easing/accelerate`; backdrop fades over 180 ms.
- Drag: 1:1 follow, with rubber-banding at the top (resists past `large` detent).
- Detent settle: spring(stiffness 280, damping 26).

### 9.10 Floating tab bar

- On scroll down: stays put.
- Active tab change: the `primaryLight` capsule slides under the new tab over 220 ms `easing/standard`; icon color cross-fades over 150 ms.

---

## 10. NFC Experience

NFC is the heart of the product. Treat it with care: explain *why* before you ask *how*.

### 10.1 Guiding the user to place the tag

During setup, the app presents three suggested locations as day-chip-style suggestions with one-line rationales:

- **Bathroom** — Most consistent. You'll go there anyway.
- **Kitchen** — Good for people who eat breakfast.
- **Hallway** — Furthest from bed, hardest to cheat.

The user can also pick **Custom** and name the spot.

### 10.2 Why the tag must be away from bed

Explained once during onboarding, never repeated nag-style:

> The tag works because it makes you walk. Place it somewhere you have to stand up, take steps, and open your eyes. About 10 feet from your bed is the sweet spot — far enough to wake you, close enough to be realistic.

### 10.3 The scan screen

See §7.5 and §7.6. Key UX details:

- The reader is **always listening** while the active alarm screen is up — no "tap to scan" button.
- The progress ring's halo and rotation indicate the reader is on.
- iOS does not allow background NFC reading on the lock screen for arbitrary apps. Implementation: the alarm presents a critical alert that, when interacted with, opens the app into the scanning state. The user only needs to tap the notification once (or use the dynamic island) to bring the reader online — see §14.5.

### 10.4 Failed scan

| Failure type | UI response | Copy |
|---|---|---|
| Unrecognized tag | Banner + shake | "That's not your tag. Try again." |
| Weak read (started, lost) | Banner only | "Almost — hold steady for a second." |
| Read timeout (3 s no signal after attempt) | Banner | "Bring your phone closer to the tag." |
| 3 fails in 60 s | Modal sheet with tips | "Trouble scanning?" |

Failures never end the alarm. The alarm continues until a real scan happens (or Backup Unlock — §10.6).

### 10.5 NFC unavailable

If the device lacks NFC support or it is disabled by MDM:

- During onboarding: a modal — "GetUp needs NFC. Your iPhone doesn't support it." — with a link to the help article.
- The user can continue in **Trial mode** using the Backup Unlock challenge (§10.6), with a clear note that it's not the full experience.

### 10.6 Preventing cheating without hostility

- **No screenshot dismiss.** Dismissing requires the NFC read or Backup Unlock.
- **Backup Unlock** (Settings → Alarms): a single configurable physical-motion alternative (e.g. 30 squats counted via Core Motion). Off by default. Available only after opt-in, with a clear note: "Use this only when your tag is broken or missing."
- **Phone movement check** (optional): if the user is suspiciously still when the alarm dismisses, the app shows a non-blocking "Are you up?" prompt 30 s later. No punishment, just a nudge.
- **No public shaming.** No "you cheated 3 times this week." Streaks count successful walks only; missed days are shown neutrally.

---

## 11. Tone of Voice

The voice is **a steady friend, not a coach**. Confident, warm, brief.

### 11.1 Voice principles

- **Clear** — never clever.
- **Calm** — never urgent typographically.
- **Slightly motivating** — never cheerleading.
- **Not aggressive** — no "WAKE UP!" or all-caps.
- **Not childish** — no emoji in primary product copy.
- **No guilt** — never reference what the user failed to do.

### 11.2 Voice in practice

| Don't | Do |
|---|---|
| "Time to crush the day! 💪" | "Good morning." |
| "You failed yesterday." | "Yesterday slipped. Today's a fresh day." |
| "WAKE UP NOW!" | "Go scan your tag." |
| "Tap to dismiss" | "Scan the tag to turn this off." |

### 11.3 Sample copy

**Onboarding hero**
> Get out of bed. Actually.
> GetUp only turns off when you walk your phone to a tag in another room.

**Alarm creation**
> When should we get you up?
> Pick a time. We'll handle the rest.

**Active alarm**
> Go scan your tag.
> Bathroom · about 12 steps away.

**Scan success**
> You're up.

**Streak success**
> Day 13.
> Best streak yet.

**Permissions ask**
> GetUp needs to wake you reliably.
> Allow critical alerts so the alarm rings even on silent.

**Error**
> That's not your tag. Try again.
> *(or)*
> Bring your phone closer to the tag.

**Settings — Snooze description**
> One five-minute snooze, then the alarm comes back.

---

## 12. Iconography

### 12.1 Style

| Property | Value |
|---|---|
| Default size | 24 × 24 px |
| Other sizes | 16, 20, 24, 32, 48 |
| Stroke | 2 px |
| Caps & joins | Rounded |
| Fill | None — line only, except for status glyphs (filled check, filled alert) at small sizes |
| Default color | `color/textPrimary` for neutral; `color/primary` for active/key |
| Pixel grid | All paths align to 1 px grid at 24 base |

### 12.2 Tinted icon container (signature pattern)

Throughout the app, icons appear inside a soft tinted container — this is the reference image's defining visual idiom.

| Property | Value |
|---|---|
| Size | 48 × 48 (default), 40 × 40 (compact), 64 × 64 (empty state hero) |
| Background | `color/primaryLight` (default) — or an accent tint per §4.4 |
| Radius | `radius/md` (16 px) for default, `radius/full` for accent badges in list rows |
| Icon | 24 × 24 inside, `color/primary` (default) or matching accent foreground |

### 12.3 Core icon set (v1)

`bell` `alarm` `clock` `nfc` `tag` `radio-signal` `home` `chart` `gear` `chevron-right` `chevron-down` `arrow-left` `plus` `check` `x` `info` `alert-triangle` `question` `sun` `moon` `eye` `eye-off` `vibration` `volume-up` `volume-mute` `pencil` `trash` `share` `water-drop` `wind` `bed` `bath` `kitchen`

### 12.4 Composition rules

- Icons never sit alone as actions in the bottom nav — always paired with a label.
- Within a button, an optional leading icon precedes the label with 8 px gap.
- Status icons (alert, info, check) use the functional color for the stroke.
- Saturated accent colors only appear *inside* tinted containers (badge style), never as a standalone fill.

---

## 13. Accessibility

GetUp is most-used by people who are barely awake. Accessibility *is* usability.

### 13.1 Contrast

All text meets WCAG AA (4.5:1 for body, 3:1 for ≥18 pt or bold ≥14 pt).
- `color/primary` `#0070E8` on white = 4.55 : 1. ✅
- `color/textSecondary` `#5B6573` on white = 7.21 : 1. ✅
- `color/textSecondary` on `color/canvas` (`#EEF2F8`) = 6.78 : 1. ✅
- `color/textTertiary` `#8A94A3` on white = 4.04 : 1. ✅ (used for non-critical helper text only)
- `color/textDisabled` is intentionally below AA; never used for actionable text.

### 13.2 Dynamic Type

Every text style maps to an iOS text style. Layouts grow vertically through AX5; cards expand, no truncation of primary content. The countdown digits and ring values are the only sizes that do not scale with Dynamic Type — they scale with viewport instead.

### 13.3 VoiceOver

Every interactive element has a label, value (where dynamic), and hint when non-obvious.

| Element | Label | Hint |
|---|---|---|
| Alarm Card | "Alarm, 06:30, weekdays, bathroom tag, enabled" | "Double tap to edit" |
| Toggle | "Alarm enabled" / "disabled" | "Double tap to toggle" |
| Progress ring | "47 mornings on time, 12-day streak" | omit |
| NFC scan area | "Scanning for tag" | "Hold the top of your phone near the tag" |
| Primary button | label as displayed | omit unless ambiguous |
| Tab | "Alarms tab, selected" | omit |

The active alarm screen sets `accessibilityViewIsModal = true` and announces "Alarm ringing. Go scan your tag." on appear.

### 13.4 Haptics

| Trigger | Haptic |
|---|---|
| Tab switch | `.selection` |
| Toggle change | `.selection` |
| Primary button | `.impact(.medium)` |
| NFC first detection | `.impact(.light)` |
| NFC confirmed | `.notification(.success)` |
| Error / failed scan | `.notification(.error)` |
| Alarm fire (in-app) | continuous heart-like pattern, 0.4 s on / 0.6 s off |

### 13.5 Reduced motion

When `UIAccessibility.isReduceMotionEnabled`:
- Disable card stagger entrance and progress-ring rotation.
- Replace ring pulse with a static state — the end-cap dot does not pulse.
- Replace error shake with a background flash to `#FFEEEF`.
- Page transitions become cross-fade only.
- Ambient page pulse is disabled.

### 13.6 Touch targets

Minimum 44 × 44 pt for every interactive element. Where a visual is smaller (e.g. a 40 px day chip), the tap region is expanded invisibly.

### 13.7 Color-blind safety

- Status is never communicated by color alone. Success = check + green. Error = alert + red. Warning = warning + orange.
- Streak dots include a today-marker stroke ring, not just a different fill.
- Active tab uses both color and a `primaryLight` capsule behind the icon — never color alone.

### 13.8 Morning usability

- Default text scales generously (Body at 17 pt, never below).
- Time picker numbers are large enough to read from arm's length.
- The active-alarm screen contains exactly one tappable element (the snooze ghost button, if enabled), and even that is optional.
- Critical alert text is set in `screenTitle` so it's legible at 18 inches with one eye open.

---

## 14. iOS Implementation Notes

### 14.1 SwiftUI components

- Adopt SwiftUI for all new surfaces; UIKit only for the alarm presentation layer (`UNNotificationContentExtension`, critical alert handling).
- Design tokens live in a `DesignSystem` namespace (`DesignSystem.Color.primary`, `DesignSystem.Font.body`, etc.) backed by an asset catalog with light/dark variants.
- Components in §6 map 1:1 to SwiftUI views: `PrimaryPillButton`, `AlarmCard`, `NFCSetupCard`, `ProgressRing`, etc.

### 14.1.1 Inter font bundling

- Ship Inter (Regular / Medium / Semibold / Bold) and Inter Tight (Semibold / Bold) as `.ttf` or variable `.woff2` files inside the app bundle.
- Register fonts in `Info.plist` via `UIAppFonts` and expose them through a `DesignSystem.Font` namespace returning `UIFontMetrics`-scaled fonts so Dynamic Type still applies.
- Provide an SF Pro fallback for every token: `Font.custom("Inter", size: 17, relativeTo: .body).fallback(.system(.body))`.
- Verify rendering at every text style XS → AX5 before release; Inter at extreme Dynamic Type sizes can drift if line heights aren't pinned.

### 14.2 Safe areas

All screens respect `safeAreaInsets`. The active alarm screen extends to the full screen (ignores safe area for background fill) but keeps content within the safe insets. The floating tab bar sits 16 px above the bottom safe area.

### 14.3 Tab bars

The floating tab bar is a custom SwiftUI component, not `TabView` with default chrome. Use `ZStack` with the tab bar overlaid and `safeAreaInset(edge: .bottom)` providing 80 px of clearance to the scroll content. The blur uses `Material.ultraThinMaterial` on iOS 17+; on iOS 15–16, fall back to a solid `color/white` at 95% opacity.

### 14.4 Haptics

Use `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`, `UISelectionFeedbackGenerator`. Prepare the generator a frame before the event (e.g. when the alarm screen mounts, prepare the success generator).

### 14.5 NFC permissions

- Use `CoreNFC` `NFCNDEFReaderSession` for reads.
- Trigger the session when the active alarm screen appears.
- iOS requires a UI-initiated scan; the critical alert tap satisfies this.
- `Info.plist` key `NFCReaderUsageDescription`: "GetUp uses NFC to read your tag and turn off the alarm."

### 14.6 Alarm permissions

- Use `UNUserNotificationCenter` with `.criticalAlert`, `.alert`, `.sound`, `.providesAppNotificationSettings`.
- Critical-alert entitlement requires an Apple entitlement — onboarding explains *why* before showing the system prompt.
- If critical alert is denied, the app degrades gracefully: standard notification + a clear screen explaining the alarm may not ring in silent mode.

### 14.7 Alarm behavior on iPhone

- Each alarm corresponds to one or more scheduled `UNNotificationRequest`s with a custom category (`ALARM_RING`).
- The category has one action: **Open** — tapping it brings the user into the active alarm screen and starts NFC.
- Sound is a 30-second loop (`alarm.caf`) chained across 20 notifications 30 s apart for up to 10 minutes of ring time.
- When the app is locked: alarm appears as a critical notification. The user taps it (or uses dynamic island) to enter scanning mode.
- When backgrounded: same path.
- When in foreground: the active alarm screen presents immediately.

### 14.8 Dark mode

Dark mode is roadmapped, not v1. Tokens are semantic so the future palette will map cleanly. Until then, the app forces light mode (`overrideUserInterfaceStyle = .light`). Settings notes: "Dark mode coming soon."

Planned dark palette (preview):
- `canvas` → `#0C0E12`
- Card surface → `#16191F`
- Hero card → `#10141B`
- Border → `#252932`
- Primary blue remains `#0070E8` (sufficient contrast on dark surfaces).

---

## 15. Design Tokens

The complete token table. Every value in this document is a token; nothing in the codebase should be a magic number.

### 15.1 Color tokens

| Token | Hex / value |
|---|---|
| `color/primary` | `#0070E8` |
| `color/primaryPressed` | `#005FC4` |
| `color/primaryLight` | `#EAF4FF` |
| `color/primarySoft` | `#F4F8FF` |
| `color/white` | `#FFFFFF` |
| `color/canvas` | `#EEF2F8` |
| `color/offWhite` | `#FAFBFC` |
| `color/surface` | `#F5F7FA` |
| `color/border` | `#E6EAF0` |
| `color/divider` | `#EEF1F5` |
| `color/textPrimary` | `#111111` |
| `color/textSecondary` | `#5B6573` |
| `color/textTertiary` | `#8A94A3` |
| `color/textDisabled` | `#B8C0CC` |
| `color/success` | `#18A957` |
| `color/successBg` | `#E8F7EF` |
| `color/warning` | `#FF9F0A` |
| `color/warningBg` | `#FFF4E0` |
| `color/error` | `#E5484D` |
| `color/errorBg` | `#FFEEEF` |
| `color/backdrop` | `rgba(17,17,17,0.32)` |
| `accent/orange` | `#FF8A3D` |
| `accent/violet` | `#8B5CF6` |
| `accent/teal` | `#14B8A6` |
| `accent/rose` | `#F43F5E` |

### 15.2 Typography tokens

See §3 — each row in the type scale is a token, named `type/<role>`. Each token carries `size`, `lineHeight`, `weight`, `tracking`, and an `iosTextStyle` mapping.

### 15.3 Radius tokens

| Token | Value | Use |
|---|---|---|
| `radius/xs` | 6 px | Tags, badges |
| `radius/sm` | 12 px | Pills inside cards |
| `radius/md` | 16 px | Icon containers, day chips |
| `radius/lg` | 20 px | Search field, secondary surfaces |
| `radius/xl` | 24 px | Default cards |
| `radius/2xl` | 28 px | Hero cards, modal sheet top |
| `radius/full` | 999 px | Primary buttons, status dots, day-of-week selectors |

### 15.4 Shadow tokens

| Token | Value |
|---|---|
| `shadow/none` | none |
| `shadow/card` | `0 4px 24px rgba(31,77,138,0.06), 0 1px 2px rgba(31,77,138,0.04)` |
| `shadow/raised` | `0 12px 36px rgba(31,77,138,0.10), 0 2px 6px rgba(31,77,138,0.06)` |
| `shadow/sheet` | `0 -8px 32px rgba(31,77,138,0.08)` |
| `shadow/glass` | `0 8px 24px rgba(31,77,138,0.08)` |
| `shadow/halo` | `0 0 64px rgba(0,112,232,0.18)` |

### 15.5 Border tokens

| Token | Value | Use |
|---|---|---|
| `border/default` | 1 px solid `color/border` | Secondary button, input field |
| `border/glass` | 1 px solid `rgba(255,255,255,0.6)` | Floating tab bar inner highlight |
| `border/focus` | 2 px inset `color/primary` | Focused input |
| `border/error` | 2 px inset `color/error` | Invalid input |

### 15.6 Spacing tokens

See §5. `space/2xs` (4) → `space/4xl` (56).

### 15.7 Motion tokens

| Token | Value |
|---|---|
| `motion/duration/fast` | 150 ms |
| `motion/duration/base` | 220 ms |
| `motion/duration/slow` | 300 ms |
| `motion/duration/hero` | 500 ms |
| `motion/duration/ambient` | 1600 ms (configurable; ring pulse uses 1600, page pulse 2400, ring rotation 8000) |
| `motion/easing/standard` | `cubic-bezier(0.2, 0, 0, 1)` |
| `motion/easing/decelerate` | `cubic-bezier(0, 0, 0, 1)` |
| `motion/easing/accelerate` | `cubic-bezier(0.3, 0, 1, 1)` |
| `motion/easing/emphasized` | `cubic-bezier(0.2, 0, 0, 1)` over 500 ms |
| `motion/easing/spring` | spring(stiffness 380, damping 30) |

### 15.8 Z-index / elevation

| Token | Value | Use |
|---|---|---|
| `z/base` | 0 | Content |
| `z/sticky` | 100 | Section sticky headers |
| `z/floatingNav` | 200 | Floating tab bar |
| `z/sheet` | 300 | Modal sheets |
| `z/banner` | 400 | Top toasts and banners |
| `z/alarm` | 900 | Active alarm full-screen takeover |
| `z/toast` | 1000 | Top-level toasts (above everything) |

### 15.9 Token file shape (reference)

```json
{
  "fontFamily": {
    "body": "\"Inter\", -apple-system, \"SF Pro\", system-ui, sans-serif",
    "display": "\"Inter Tight\", \"Inter\", -apple-system, \"SF Pro\", system-ui, sans-serif"
  },
  "color": {
    "primary": "#0070E8",
    "primaryPressed": "#005FC4",
    "primaryLight": "#EAF4FF",
    "primarySoft": "#F4F8FF",
    "canvas": "#EEF2F8",
    "white": "#FFFFFF",
    "surface": "#F5F7FA",
    "border": "#E6EAF0",
    "textPrimary": "#111111",
    "textSecondary": "#5B6573",
    "textTertiary": "#8A94A3",
    "success": "#18A957",
    "warning": "#FF9F0A",
    "error": "#E5484D"
  },
  "type": {
    "largeTitle": { "size": 34, "lineHeight": 41, "weight": 700, "tracking": 0.37, "iosTextStyle": "largeTitle" },
    "screenTitle": { "size": 28, "lineHeight": 34, "weight": 700, "tracking": 0.36, "iosTextStyle": "title1" },
    "sectionHeader": { "size": 20, "lineHeight": 25, "weight": 600, "tracking": 0.38, "iosTextStyle": "title3" },
    "headline": { "size": 17, "lineHeight": 22, "weight": 600, "tracking": -0.43, "iosTextStyle": "headline" },
    "body": { "size": 17, "lineHeight": 22, "weight": 400, "tracking": -0.43, "iosTextStyle": "body" },
    "secondaryBody": { "size": 15, "lineHeight": 20, "weight": 400, "tracking": -0.24, "iosTextStyle": "subheadline" },
    "caption": { "size": 13, "lineHeight": 18, "weight": 400, "tracking": -0.08, "iosTextStyle": "footnote" },
    "button": { "size": 17, "lineHeight": 22, "weight": 600, "tracking": -0.43 },
    "ringValue": { "size": 56, "lineHeight": 60, "weight": 700, "tracking": -0.8, "tabular": true },
    "countdown": { "size": 96, "lineHeight": 96, "weight": 600, "tracking": -1.2, "tabular": true, "family": "Inter Tight" }
  },
  "space": { "2xs": 4, "xs": 8, "sm": 12, "md": 16, "lg": 20, "xl": 24, "2xl": 32, "3xl": 40, "4xl": 56 },
  "radius": { "xs": 6, "sm": 12, "md": 16, "lg": 20, "xl": 24, "2xl": 28, "full": 999 },
  "shadow": {
    "card": "0 4px 24px rgba(31,77,138,0.06), 0 1px 2px rgba(31,77,138,0.04)",
    "raised": "0 12px 36px rgba(31,77,138,0.10), 0 2px 6px rgba(31,77,138,0.06)",
    "sheet": "0 -8px 32px rgba(31,77,138,0.08)",
    "glass": "0 8px 24px rgba(31,77,138,0.08)",
    "halo": "0 0 64px rgba(0,112,232,0.18)"
  },
  "motion": {
    "duration": { "fast": 150, "base": 220, "slow": 300, "hero": 500, "ambientPagePulse": 2400, "ambientRingPulse": 1600, "ambientRingRotation": 8000 },
    "easing": {
      "standard": [0.2, 0, 0, 1],
      "decelerate": [0, 0, 0, 1],
      "accelerate": [0.3, 0, 1, 1],
      "emphasized": [0.2, 0, 0, 1],
      "spring": { "stiffness": 380, "damping": 30 }
    }
  },
  "z": { "base": 0, "sticky": 100, "floatingNav": 200, "sheet": 300, "banner": 400, "alarm": 900, "toast": 1000 }
}
```

---

## Appendix A — Component → screen matrix

| Component | Used on |
|---|---|
| Primary pill button | Every screen with a main action |
| Secondary pill button | Onboarding, alarm overview ("Add alarm"), settings rows |
| Ghost button | Onboarding skip, modal cancel, help links |
| Icon button | Floating back, settings entry, filter |
| Destructive pill button | Alarm edit (delete), settings danger zone |
| Card | All list rows, hero sections |
| Hero card | Home (progress), alarm-ringing background, NFC setup |
| Progress ring | Home, Active alarm, NFC scan |
| Tinted icon container | List rows, empty states, NFC setup card |
| Day chip | Alarm creation |
| Alarm Card | Home |
| Floating tab bar | All top-level screens (hidden during active alarm and modal flows) |
| Toggle | Alarm card, Settings |
| Time picker | Alarm creation, Alarm edit |
| Modal sheet | Alarm creation, NFC troubleshooting, change tag, sound picker |
| Toast / banner | Save confirmations, NFC failures |
| Empty state | Alarms tab (no alarms), Progress (no data) |
| Error state | NFC fail, validation, network |

## Appendix B — Open questions / v2 candidates

These are intentionally **out of scope** for v1:

- Dark mode token set (mapped, not designed)
- iPad layout (currently iPhone-only)
- Apple Watch companion (start/stop scan from wrist)
- Family / household shared accountability
- Sleep score integration via HealthKit
- Multi-tag-per-alarm routes ("scan bathroom, then kitchen")

These reuse the system above; nothing in this document needs to be rewritten to accommodate them.

---

*End of design.md — v2.0 — Modern iOS visual language*
