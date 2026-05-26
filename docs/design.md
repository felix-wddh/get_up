# GetUp — iOS Design System & Product Specification

> **One sentence**: GetUp is an iOS alarm app that forces you out of bed by requiring a physical NFC tag scan to silence the alarm. This document is the single source of truth for its visual language, component library, motion, copy, and implementation.

---

## 0. Table of Contents

1. [Design Principles](#1-design-principles)
2. [Typography](#2-typography)
3. [Spacing System](#3-spacing-system)
4. [Color System](#4-color-system)
5. [Core UI Components](#5-core-ui-components)
6. [Button System](#6-button-system)
7. [Screen Designs](#7-screen-designs)
8. [Navigation Logic](#8-navigation-logic)
9. [Motion & Animation](#9-motion--animation)
10. [NFC-Specific Experience](#10-nfc-specific-experience)
11. [Tone of Voice](#11-tone-of-voice)
12. [Iconography](#12-iconography)
13. [Accessibility](#13-accessibility)
14. [iOS Implementation Notes](#14-ios-implementation-notes)
15. [Design Tokens](#15-design-tokens)

---

## 1. Design Principles

GetUp is a utility you use at the worst moment of the day — half-awake, eyes squinting, brain offline. The product must feel like a quiet, confident tool, not a toy. Six principles guide every decision.

| # | Principle | What it means | What it rules out |
|---|---|---|---|
| 1 | **Simple** | One job per screen. No more than one primary action. | Dashboards, info density, dual CTAs. |
| 2 | **Physical** | The product extends into the real world through the NFC tag. The UI rewards and reinforces that physical motion. | Pure-digital "tap to dismiss" shortcuts. |
| 3 | **Calm urgency** | At 6:30 AM, the app insists — but it never yells. Motion is firm, copy is steady, color stays controlled. | Red flashing screens, aggressive vibration, exclamation marks. |
| 4 | **Trustworthy** | Looks and behaves like an Apple-native utility. Predictable, immediate, no surprises. | Custom alert dialogs, marketing splash screens. |
| 5 | **Minimal friction** | Setup is < 60 seconds. Creating an alarm is two taps after the first run. | Modals stacked on modals, mandatory accounts. |
| 6 | **Consistent white-and-blue logic** | White is the world; black is information; blue is action. Every component obeys this. | Multi-color palettes, gradient buttons, mood-based theming. |

**Golden rule** — *Every pixel justifies its presence. If a screen can be quieter, it should be.*

---

## 2. Typography

GetUp uses **SF Pro** exclusively, following iOS Human Interface Guidelines and Dynamic Type. The variant is implied by usage: SF Pro Display ≥ 20 pt, SF Pro Text < 20 pt. SF Mono is used only inside the alarm countdown for tabular numerals.

### 2.1 Type scale

| Token | Style | Size / Line height | Weight | Tracking | Usage |
|---|---|---|---|---|---|
| `type/largeTitle` | Large Title | 34 / 41 | Bold (700) | +0.37 | Onboarding hero, big moments ("Good morning") |
| `type/title1` | Title 1 | 28 / 34 | Bold (700) | +0.36 | Page titles ("Your alarms") |
| `type/title2` | Title 2 | 22 / 28 | Semibold (600) | +0.35 | Sub-page headings, modal titles |
| `type/title3` | Title 3 | 20 / 25 | Semibold (600) | +0.38 | Section titles inside lists |
| `type/headline` | Headline | 17 / 22 | Semibold (600) | -0.43 | Card titles, list row primary |
| `type/body` | Body | 17 / 22 | Regular (400) | -0.43 | Default paragraph, list row body |
| `type/callout` | Callout | 16 / 21 | Regular (400) | -0.32 | Helper copy adjacent to inputs |
| `type/subhead` | Subheadline | 15 / 20 | Regular (400) | -0.24 | Secondary text, metadata |
| `type/footnote` | Footnote | 13 / 18 | Regular (400) | -0.08 | Disclosures, fine print |
| `type/caption1` | Caption 1 | 12 / 16 | Regular (400) | 0 | Labels, timestamps |
| `type/caption2` | Caption 2 | 11 / 13 | Medium (500) | +0.06 | Micro-labels, tag badges |
| `type/button` | Button | 17 / 22 | Semibold (600) | -0.43 | All button labels |
| `type/countdown` | Alarm Countdown | 96 / 96 | Light (300), SF Pro Display, tabular nums | -1.2 | Active alarm time display |

### 2.2 Usage rules

- **One title per screen.** Never stack `largeTitle` with `title1`.
- **Body color is `text.primary`** unless deliberately demoted to `text.secondary` for hierarchy.
- **Line length** stays between 40–70 characters for `body`. Wider lines break trust.
- **Numerals in time/counters** use tabular figures (`font-feature-settings: "tnum"`).
- **Never bold for emphasis inside body copy.** Use weight to denote role (e.g. card title) only.

### 2.3 Dynamic Type

All text styles map to iOS text-style tokens (`UIFont.TextStyle.body`, etc.) and respect the user's preferred size from XS to AX5. The alarm countdown is the only exception: it scales with the viewport, not Dynamic Type, because legibility at distance matters more than label-level customization.

---

## 3. Spacing System

A single 4-pt scale governs all spacing — internal padding, gaps between siblings, and the gutter between cards.

| Token | Value | Primary use |
|---|---|---|
| `space/2xs` | **4 px** | Icon ↔ adjacent label, hairline separations |
| `space/xs` | **8 px** | Tag inner padding, dense list row vertical gap |
| `space/sm` | **12 px** | Button inner padding (vertical), small card padding |
| `space/md` | **16 px** | Screen edge gutter, list row vertical padding |
| `space/lg` | **20 px** | Card internal padding, comfortable group gap |
| `space/xl` | **24 px** | Section gap, card external margin |
| `space/2xl` | **32 px** | Hero block spacing, top of screen padding |
| `space/3xl` | **40 px** | Onboarding screen verticals, modal top padding |
| `space/4xl` | **56 px** | Major moment dividers (between hero and CTA) |

### 3.1 Layout grid

- **Edge gutter**: `space/md` (16 px) on phones < 390 pt wide; `space/lg` (20 px) on 390+.
- **Vertical rhythm**: prefer 8-pt multiples. 4 px is reserved for icon-to-text relationships and hairlines.
- **Safe areas**: never crowd within 8 px of the home indicator or the dynamic island.
- **One-thumb reach**: primary actions sit within the bottom 280 pt of the screen.

---

## 4. Color System

White is the canvas. Black is meaning. Blue is action. Every other color is a functional exception.

### 4.1 Primary palette

| Token | Hex | Role |
|---|---|---|
| `color/primary` | `#0070E8` | All primary actions, active toggles, focused inputs, key icons |
| `color/primaryPressed` | `#005FC4` | Pressed and hover state for primary action |
| `color/primaryLight` | `#EAF4FF` | Selected row highlight, tag fill, NFC pulse mid-ring |
| `color/primarySoft` | `#F3F8FF` | Page-level emphasis background (e.g. NFC setup card) |

### 4.2 Neutrals

| Token | Hex | Role |
|---|---|---|
| `color/white` | `#FFFFFF` | Card surface, modal surface, button fill (secondary) |
| `color/offWhite` | `#FAFAFA` | App background |
| `color/surface` | `#F5F6F7` | Inactive chips, input fields, time picker wheel |
| `color/border` | `#E5E7EB` | Card border, secondary button stroke |
| `color/divider` | `#EEEEEE` | List separators, group dividers |
| `color/textPrimary` | `#111111` | Headlines, body, primary content |
| `color/textSecondary` | `#4A4A4A` | Subheads, secondary list text |
| `color/textTertiary` | `#7A7A7A` | Captions, metadata, helper text |
| `color/textDisabled` | `#B8B8B8` | Disabled label, placeholder |

### 4.3 Functional

Used only when the meaning is truly green, orange, or red. Never for decoration.

| Token | Hex | Background | Role |
|---|---|---|---|
| `color/success` | `#19A463` | `#EAF8F1` | Streak confirmed, NFC scan accepted, success screen accent |
| `color/warning` | `#FF9500` | `#FFF4E5` | "Tag is too close to bed" advisory, weak NFC signal |
| `color/error` | `#E5484D` | `#FFF0F0` | Failed scan banner, destructive confirm, validation |

### 4.4 Usage rules

- **No more than two non-neutral colors per screen.** Blue + one functional color, never three.
- **Backgrounds for status colors are paired tints** — never use the saturated hex as a fill larger than 24 × 24.
- **Never combine blue and green as adjacent CTAs** — confusion of intent.

---

## 5. Core UI Components

Every component below is defined by its anatomy, default state, interactive states, and the tokens it consumes. Components are listed roughly in order of importance to the product.

### 5.1 Primary Button

The single most important component. Used for the one primary action on a screen.

| Property | Value |
|---|---|
| Height | 52 px |
| Min width | 120 px (or stretch full-width with `space/md` insets) |
| Radius | `radius/lg` (14 px) |
| Padding | 16 vertical, 20 horizontal |
| Background | `color/primary` |
| Label | `type/button`, `color/white` |
| Pressed | Background → `color/primaryPressed`, scale 0.98, 120 ms ease-out |
| Disabled | Background `color/surface`, label `color/textDisabled` |
| Loading | Spinner (18 × 18) replaces label, scale 1, no scale press feedback |
| Haptic | `.impact(.medium)` on tap, `.notification(.success)` on completion |

### 5.2 Secondary Button

Used as the "alternative" to a primary, never alone.

| Property | Value |
|---|---|
| Height | 52 px |
| Background | `color/white` |
| Border | 1 px solid `color/border` |
| Label | `type/button`, `color/textPrimary` |
| Pressed | Background → `color/surface`, scale 0.98 |
| Disabled | Border `color/divider`, label `color/textDisabled` |

### 5.3 Text Button

Inline action, used for low-weight choices like "Skip", "Not now", "Help".

| Property | Value |
|---|---|
| Height | 44 px tap target, label sits centered |
| Background | None |
| Label | `type/button`, `color/primary` |
| Pressed | Label `color/primaryPressed`, opacity 1, no scale |
| Disabled | Label `color/textDisabled` |

### 5.4 Destructive Button

Reserved for irreversible actions ("Delete alarm", "Reset all"). Never appears unless the action truly removes data.

| Property | Value |
|---|---|
| Height | 52 px |
| Background | `color/white` |
| Border | 1 px `color/border` |
| Label | `type/button`, `color/error` |
| Pressed | Background `#FFF0F0`, label `color/error` |
| Inverted form | Used inside an action sheet: solid `color/error` background, white label — only when confirming an already-committed delete. |

### 5.5 NFC Setup Card

The single card that walks the user through placing the NFC tag.

```
┌─────────────────────────────────────────────┐
│                                             │
│   ◎  ←  blue ring icon (32 px)             │
│                                             │
│   Place your tag far from bed               │ ← title3
│                                             │
│   The bathroom or kitchen works best.       │ ← body, textSecondary
│   You'll need to walk to it each morning.   │
│                                             │
│   [ Set up tag ]                            │ ← primary button, full width
│                                             │
└─────────────────────────────────────────────┘
```

- Surface: `color/primarySoft`, no border
- Radius: `radius/xl` (20 px)
- Padding: `space/xl` (24 px)
- Spacing inside: 12 / 8 / 20 (icon → title → body → CTA)
- Used only on Home when no tag exists, and on the dedicated NFC setup screen.

### 5.6 Alarm Card

A row representing one configured alarm.

| Element | Spec |
|---|---|
| Container | `color/white` surface, `radius/lg` 14 px, 1 px `color/border`, no shadow |
| Padding | `space/lg` 20 px vertical, `space/lg` horizontal |
| Time | `type/title1` (28 / 34 bold), tabular nums |
| Label | `type/subhead`, `color/textSecondary` ("Weekdays · Bathroom tag") |
| Toggle | Right-aligned, vertically centered |
| Pressed | Background → `color/surface`, 120 ms |
| Drag-to-reorder | Hidden by default, surfaced via long-press |

### 5.7 Morning Routine Card

A configurable step displayed under an alarm (e.g. "Drink water → Stretch → Open curtains").

- Visual: horizontal pill row with `color/surface` chips, 36 px tall, 12 px horizontal padding, 8 px gap.
- Each chip: leading 16 px icon, `type/subhead` label.
- Reorder via drag; remove via swipe.

### 5.8 Progress Card

Shown on Home and on the Progress screen.

```
┌────────────────────────────────────┐
│   12-day streak                    │ ← headline
│                                    │
│   ●●●●●●●●●●●●○○○○○○○             │ ← 21 dots, 8 px, 4 px gap
│                                    │
│   You've gotten up on time         │ ← subhead, textSecondary
│   12 mornings in a row.            │
└────────────────────────────────────┘
```

- Dot filled: `color/primary`. Dot empty: `color/border`.
- Today's dot pulses softly (opacity 0.6 → 1.0, 1.6 s ease-in-out, infinite, only on this card on Home).

### 5.9 Bottom Navigation

Three tabs only. No more.

| Tab | Icon | Label |
|---|---|---|
| Alarms | bell line, 24 px | Alarms |
| Progress | chart line, 24 px | Progress |
| Settings | gear line, 24 px | Settings |

- Bar height: 49 pt + safe area
- Surface: `color/white` with 1 px top border `color/divider`
- Active: icon + label `color/primary`, weight unchanged
- Inactive: icon + label `color/textTertiary`
- Tap haptic: `.selection`

### 5.10 Toggle

iOS-native UISwitch metrics.

| State | Spec |
|---|---|
| On | Track `color/primary`, thumb `color/white` |
| Off | Track `color/surface`, thumb `color/white`, 1 px border `color/border` on track |
| Disabled on | Track at 40% opacity |
| Animation | 220 ms `easing/standard` |

### 5.11 Time Picker

A custom three-wheel picker (hours, minutes, period) for alarm setup. The wheels visually inherit iOS native picker behavior but use GetUp tokens.

- Wheel width: 96 px each, gap 8 px
- Surface behind the selected row: `color/primarySoft`, 14 px radius, full wheel width
- Selected value: `type/title1` (28 / 34 bold), `color/textPrimary`
- Adjacent values: `type/title3`, `color/textTertiary`, scale 0.9
- Spin haptic: `.selection` per tick
- Bottom CTA: primary "Save" button

### 5.12 Modal Sheet

iOS sheet presentation, with custom chrome.

| Property | Value |
|---|---|
| Background | `color/white` |
| Top radius | 20 px |
| Grabber | 36 × 5 px, `color/border`, 5.5 px radius, 8 px from top |
| Title padding | 24 px top, 16 px bottom |
| Default detent | `medium` (50%) — `large` only when content demands |
| Backdrop | rgba(17,17,17,0.32) |

### 5.13 Confirmation Screen

A full-screen confirmation moment (e.g. tag paired, alarm dismissed).

- 100% viewport, `color/white` background
- Centered icon: 64 × 64, `color/success` for positive confirms
- Title: `type/largeTitle`, 1 line max
- Subtitle: `type/body`, `color/textSecondary`, max 2 lines
- CTA: primary "Done"
- Auto-dismiss only when triggered by a system event (e.g. alarm dismissed), never on user-initiated confirms.

### 5.14 Empty State

Used when a list has no content.

```
        ◎       ← outlined icon, 48 px, color/textTertiary
   
   No alarms yet           ← title3, textPrimary
   
   Tap + to create your    ← body, textSecondary
   first morning alarm.
   
   [ Create alarm ]        ← primary button
```

Centered vertically within the available scrollable region, with `space/2xl` between elements.

### 5.15 Error State

Two variants:

**Inline error** (under a field):
- 12 px above field bottom; `type/footnote`; `color/error`; leading 14 px alert icon.

**Banner error** (top of screen, transient):
- 56 px tall, full width, `color/error` background (8% opacity tint = `#FFF0F0`)
- 1 px top border `color/error`
- Body: `type/subhead`, `color/error`
- Auto-dismisses after 4 s; tappable to retry
- Haptic: `.notification(.error)`

---

## 6. Button System

### 6.1 Visual specs at a glance

| Variant | Bg | Label | Border | Use this when… |
|---|---|---|---|---|
| Primary | `#0070E8` | `#FFFFFF` | none | The screen has one job |
| Secondary | `#FFFFFF` | `#111111` | 1 px `#E5E7EB` | Offering an alternative |
| Text | none | `#0070E8` | none | Low-weight or nav action |
| Destructive | `#FFFFFF` | `#E5484D` | 1 px `#E5E7EB` | Irreversible action |
| Disabled | `#F5F6F7` | `#B8B8B8` | none | Action not yet available |

### 6.2 Sizing

| Size | Height | Horizontal padding | Use |
|---|---|---|---|
| `lg` | 52 px | 24 px | Default for screen-bottom CTAs |
| `md` | 44 px | 20 px | Inline forms, modals |
| `sm` | 36 px | 16 px | Card-internal actions, dense lists |

Radius always `radius/lg` (14 px). Min tap target 44 × 44 regardless of visual size.

### 6.3 States

Every variant supports: **default**, **pressed**, **disabled**, **loading**, **focused (keyboard)**.

- **Pressed** = scale 0.98 + background dim, 120 ms ease-out
- **Loading** = 18 px circular spinner replaces label; button is non-interactive
- **Focused** = 2 px ring `color/primary` at 40% opacity, 4 px offset

### 6.4 Composition rules

- Primary and secondary may share a screen, side by side, only at the screen's bottom. Primary always to the right.
- Never stack two primary buttons.
- Destructive buttons are isolated — they get their own row with no companion.

### 6.5 Examples

```
[ Set tag location ]                   ← primary, full-width, lg

[ Skip ]  [ Continue ]                 ← secondary + primary, 50/50, lg
                                          gap = space/sm

[ Delete alarm ]                       ← destructive, full-width, lg
```

---

## 7. Screen Designs

Each screen below has a one-line purpose, the dominant components, and a layout sketch.

### 7.1 Onboarding Intro

**Purpose**: Explain the premise in one sentence; ask for permissions later, not now.

```
   (top safe area)
   
   ↑ 56 px
   
   ◎ ◎ ◎              ← three primary-light dots, spacer
   
   ↑ 32 px
   
   Get out of bed.        ← largeTitle, primary text
   Actually.              ← largeTitle
   
   ↑ 16 px
   
   GetUp turns off only   ← body, textSecondary
   when you walk to a tag
   in another room.
   
   (flex spacer)
   
   [ Get started ]         ← primary, full-width
   
   ↑ 12 px
   
   [ I already have an account ]  ← text button
   
   ↓ 24 px (bottom safe)
```

### 7.2 NFC Tag Setup

**Purpose**: Pair the physical tag and confirm location.

- Step header: "1 of 2" caption, then title2 "Place the tag"
- NFC Setup Card (5.5) explaining placement away from bed
- Animated illustration placeholder: 240 × 240 area, dashed border, monospace label "phone + tag illustration"
- Primary CTA "Hold phone near tag"
- Text button "I'll do this later"

After successful pairing → Step 2: "Name this location" (Bathroom / Kitchen / Hallway / Custom).

### 7.3 Alarm Creation

**Purpose**: Pick a time, days, and routine.

- Page title "New alarm" (title1), centered, with text-button "Cancel" left and "Save" right (primary text color → enabled when valid).
- Time picker (5.11), centered
- Days row: seven 40 × 40 circular chips, S M T W T F S
  - Default chip: `color/surface` background, `type/subhead` label, `color/textPrimary`
  - Selected: `color/primary` background, `color/white` label
- Section "Tag" — list row showing paired tag location, chevron to change
- Section "Routine" — Morning Routine Card (5.7)
- Section "Sound" — list row, chevron

### 7.4 Alarm Overview (Home)

**Purpose**: At-a-glance status; the most-used screen.

```
   (header)
   Good morning, Mads     ← title1
   Tuesday, May 26        ← subhead, textSecondary
   
   ─ space/xl ─
   
   Progress Card (12-day streak)
   
   ─ space/xl ─
   
   Your alarms            ← title3
   
   Alarm Card  06:30 · Weekdays · Bathroom tag       [ • ]
   Alarm Card  09:15 · Weekends · Kitchen tag        [ • ]
   
   ─ space/xl ─
   
   Add alarm              ← secondary button, full-width with leading +
   
   (bottom nav)
```

### 7.5 Active Alarm Ringing

**Purpose**: Wake the user. Move them physically.

- Full-screen takeover (presented over the lock screen via critical alert)
- Background: `color/white`, no decoration
- Center: `type/countdown` showing current time
- Below: title2 "Go scan your tag"
- Subhead: `color/textSecondary` "Bathroom · about 12 steps away"
- Bottom: NFC ring animation (see §9.4), 200 px diameter
- No dismiss button. No snooze button in the default config. (Snooze, if enabled in settings, appears as text-button only — see §10.)

### 7.6 NFC Scanning Confirmation

**Purpose**: Confirm the tag was read.

- Trigger: NFC reader picks up the paired tag.
- Full-screen flash: background animates `color/white` → `color/primarySoft` over 220 ms
- Centered checkmark icon, 96 × 96, `color/primary` stroke, drawn-in over 300 ms
- Title `type/largeTitle`: "You're up."
- Haptic: `.notification(.success)`
- Auto-advance to Success screen after 800 ms.

### 7.7 Success Screen

**Purpose**: Reward and motivate the next morning.

- Background `color/white`
- Top: `type/largeTitle` "Day 13."
- `type/body` `color/textSecondary` "Best streak yet."
- Progress dot row (8 px dots) showing the last 14 days
- Optional Morning Routine list — checkable items the user can mark as they complete them
- Bottom: text button "Close"

### 7.8 Morning Streak / Progress

**Purpose**: Long-view of consistency.

- Title1 "Progress"
- Big number callout: "**47** mornings on time" (largeTitle + body)
- 12-week heatmap grid: 7 × 12 cells, each 16 × 16, 4 px gap
  - Filled cell `color/primary`, missed `color/border`, future `color/surface`
- Statistics list:
  - "Average wake time — 06:34"
  - "Longest streak — 21 days"
  - "Time to scan — 38 s avg"
- Each row: `type/headline` value, `type/subhead` `color/textSecondary` label

### 7.9 Settings

**Purpose**: Configure permissions, behavior, and personal preferences.

Grouped list, iOS-native style with GetUp tokens.

- **Account**: Name, email, sign out
- **Alarms**: Default sound, Snooze (Off / 5 min once), Vibration
- **NFC**: Paired tags (list), Add new tag
- **Notifications**: Bedtime reminders, Streak nudges
- **Appearance**: Theme (Auto / Light / Dark)
- **Accessibility**: Reduce motion, Large text, Haptics
- **Support**: Help, Contact, Terms, Privacy
- **Danger zone**: "Reset all data" (destructive)

### 7.10 Help / Troubleshooting

**Purpose**: Self-serve answers, calmly written.

- Search field at top (40 px height, `color/surface` background, 10 px radius)
- Featured cards: "NFC not scanning?", "Battery and background", "Why does the app need critical alerts?"
- Below: alphabetical FAQ list
- Last item: "Still stuck → Contact support" (text button)

---

## 8. Navigation Logic

### 8.1 First-time user flow

```
Splash (200 ms)
  → Onboarding 1: Premise
  → Onboarding 2: How it works (3 dots, swipe)
  → Permission ask: Notifications (system sheet)
  → Permission ask: Critical alerts (system sheet, explained first)
  → NFC tag setup (paired in this run, optional skip)
  → First alarm creation
  → Home
```

### 8.2 Returning user flow

```
Splash → Home (Alarms tab)
```

No login wall. Account sync is optional, surfaced under Settings.

### 8.3 Alarm ringing flow

```
[Alarm fires (critical alert)]
  → Active Alarm screen (full-screen takeover)
  → User physically walks to tag
  → Phone enters NFC read range
  → Scanning confirmation flash (220 ms)
  → Success screen
  → Auto-return to Home after 4 s or on tap
```

### 8.4 Failed NFC scan flow

```
Active Alarm
  → User taps phone to tag
  → Tag UID mismatch OR weak read
  → Inline shake (see §9.6) + banner: "That's not your tag. Try again."
  → Alarm keeps ringing
  → 3 consecutive failures within 60 s → guidance modal: "Trouble scanning?"
     - Tip list: hold phone flat, top edge to tag, remove case
     - "Use backup unlock" link (only if enabled in Settings — see §10)
```

### 8.5 Edit alarm flow

```
Home → tap Alarm Card
  → Alarm detail (same layout as Creation, prefilled)
  → Save (returns to Home with confirmation toast: "Alarm updated")
  → Or "Delete alarm" (destructive button, confirm action sheet)
```

### 8.6 Disable alarm flow

```
Home → toggle off on Alarm Card
  → Toggle animates off
  → Subtle haptic .selection
  → No confirmation modal (it's reversible)
  → Card label updates to grey, dimmed to 50%
```

---

## 9. Motion & Animation

Motion in GetUp is short, decisive, and ignorable. Every animation has a job: to confirm a state change, never to entertain.

### 9.1 Easing curves

| Token | Cubic-bezier | Use |
|---|---|---|
| `easing/standard` | `(0.2, 0, 0, 1)` | Default for entrances and most transitions |
| `easing/decelerate` | `(0, 0, 0, 1)` | Sheet entry, card reveal |
| `easing/accelerate` | `(0.3, 0, 1, 1)` | Sheet exit, dismiss |
| `easing/emphasized` | `(0.2, 0, 0, 1)` + 500 ms | Hero moments (success screen) |

### 9.2 Durations

| Token | Value | Use |
|---|---|---|
| `motion/fast` | 150 ms | Toggles, button press scale |
| `motion/base` | 220 ms | Page transitions, modal show/hide |
| `motion/slow` | 300 ms | NFC confirmation flash, checkmark draw |
| `motion/hero` | 500 ms | Success screen entry, streak reveal |

### 9.3 Page transitions

- Push: new screen slides from right, 220 ms `easing/standard`; current screen drifts left 16 px and dims to 60% white overlay.
- Modal sheet: bottom-up slide, 300 ms `easing/decelerate`; backdrop fades in over 220 ms.
- Tab switch: cross-fade, 150 ms — no slide.

### 9.4 Alarm ringing state

- Background subtle pulse: `color/white` → `color/primarySoft` → `color/white`, 2.0 s loop, `easing/standard`.
- NFC ring animation:
  - Two concentric rings, 1.5 px stroke `color/primary`.
  - Inner ring: scale 1 → 1.4 → 1, opacity 0.9 → 0, 1.6 s loop.
  - Outer ring: scale 1 → 1.7 → 1, opacity 0.6 → 0, 1.6 s loop, 200 ms delay.
- Countdown digits do not animate; they reflect device time.

### 9.5 NFC scan animation

1. **Reading state** (while phone is near tag): inner ring becomes solid `color/primaryLight`, scaling 1 → 1.1 → 1 every 600 ms.
2. **Read success**: background flash → checkmark draws in over 300 ms (stroke-dasharray animation), `easing/decelerate`.
3. **Haptic**: `.impact(.light)` on first detection, `.notification(.success)` on confirmed read.

### 9.6 Error shake

- Used for failed NFC, invalid input.
- Horizontal translate: 0, -8, 8, -6, 6, -3, 3, 0 px.
- Duration 320 ms total.
- Accompanied by `.notification(.error)` haptic.
- Reduce motion: replaced by a 200 ms background flash to `#FFF0F0`.

### 9.7 Card entrance

- Cards in a list fade in (opacity 0 → 1) and translate Y +8 px → 0.
- Stagger 40 ms per card, max 5 cards animated; the rest appear instantly.
- Duration 220 ms each, `easing/decelerate`.
- Disabled when "Reduce motion" is on.

### 9.8 Button press

- Scale 1 → 0.98, 120 ms ease-out on touch down.
- On release: scale → 1, 180 ms `easing/standard`, simultaneously background returns to default.
- No bounce on release.

### 9.9 Success animation

- Checkmark: stroke 4 px `color/success`, drawn over 300 ms with `easing/emphasized`.
- After draw: 6 light particles burst — 4 px circles `color/primaryLight`, animated outward 24 px over 400 ms with ease-out, fading to 0.
- Reduce motion: static checkmark, no particles.

---

## 10. NFC-Specific Experience

NFC is the heart of the product. Treat it with care: explain *why* before you ask *how*.

### 10.1 Guiding the user to place the tag

During setup, the app presents three suggested locations (Bathroom, Kitchen, Hallway) with one-line rationales:

> **Bathroom.** Most consistent — you'll go there anyway.
> **Kitchen.** Good for people who eat breakfast.
> **Hallway.** Furthest from bed, hardest to cheat.

The user can also pick "Custom" and name the spot.

### 10.2 Why the tag must be away from bed

Explained once during onboarding, never repeated nagging-style:

> The tag works because it makes you walk. Place it somewhere you have to stand up, take steps, and open your eyes. About 10 feet from your bed is the sweet spot — far enough to wake you, close enough to be realistic.

### 10.3 Scanning screen

See §7.5 and §7.6. Key UX details:

- The reader is **always listening** while the active alarm screen is up. No "tap to scan" button.
- Visual NFC ring animation indicates the reader is on.
- iOS does not allow background NFC reading on lock screen for arbitrary apps. Implementation note: the alarm presents a critical alert that, when interacted with, opens the app into the scanning state. The user only needs to tap the notification once (or use the dynamic island) to bring the reader online — see §14.5.

### 10.4 Failed scan

| Failure type | UI response | Copy |
|---|---|---|
| Unrecognized tag | Banner + shake | "That's not your tag. Try again." |
| Weak read (started but lost signal) | Banner only | "Almost — hold steady for a second." |
| Read timeout (3 s no signal after attempt) | Banner | "Bring your phone closer to the tag." |
| 3 fails / 60 s | Modal sheet with tips | "Trouble scanning?" |

Failures never end the alarm. The alarm continues until a real scan happens (or backup unlock, see §10.6).

### 10.5 NFC unavailable

If the device lacks NFC support (iPhone 6 and earlier) or NFC is disabled by MDM:

- During onboarding: a clear modal: "GetUp needs NFC. Your iPhone doesn't support it." with a link to the help article.
- The user can continue in "Trial mode" using a backup unlock challenge (see §10.6) — but the app is honest that it's not the real experience.

### 10.6 Preventing cheating without hostility

GetUp is a tool, not a prison guard. Guardrails:

- **No screenshot dismiss**: dismissing the alarm requires the NFC read or the Backup Unlock challenge.
- **Backup Unlock** (Settings → Alarms): a single configurable physical-motion alternative (e.g. 30 squats counted via Core Motion). Off by default. Available only after the user opts in, with a clear note: "Use this only when your tag is broken or missing."
- **Phone movement check** (optional): if the user is suspiciously still when the alarm dismisses (i.e. did *not* walk), the app shows a non-blocking "Are you up?" prompt 30 s later. No punishment, just a nudge.
- **No public shaming**: no "you cheated 3 times this week" surfaces. Streaks count *successful walks only*, but missed days are shown neutrally.

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
| "Are you really going to oversleep again?" | "Your alarm is set for 06:30." |
| "Tap to dismiss" | "Scan the tag to turn this off." |

### 11.3 Example copy

**Onboarding**

> Get out of bed. Actually.
> GetUp turns off only when you walk to a tag in another room.

**Alarm setup**

> When should we get you up?
> Pick a time. We'll handle the rest.

**Active alarm**

> Go scan your tag.
> Bathroom · about 12 steps away.

**NFC scan success**

> You're up.

**Error state**

> That's not your tag. Try again.
> *(or)*
> Bring your phone closer to the tag.

**Success state (post-alarm)**

> Day 13.
> Best streak yet.

**Settings**

> Snooze
> One five-minute snooze, then the alarm comes back.

**Permissions ask**

> GetUp needs to wake you reliably.
> Allow critical alerts so the alarm rings even on silent.

---

## 12. Iconography

### 12.1 Style

| Property | Value |
|---|---|
| Default size | 24 × 24 px |
| Other sizes | 16, 20, 24, 32, 48, 64 |
| Stroke | 2 px |
| Caps & joins | Rounded |
| Fill | None — line only, except for filled-state status (e.g. checkmark inside a circle) |
| Default color | `color/textPrimary` for neutral, `color/primary` for active |
| Pixel grid | All paths align to 1 px grid at 24 base |

### 12.2 Core icon set (v1)

`bell` `alarm` `clock` `nfc` `tag` `signal-radio` `home` `chart` `gear` `chevron-right` `chevron-down` `arrow-left` `plus` `check` `x` `info` `alert` `question` `sun` `moon` `eye` `eye-off` `vibration` `volume` `volume-mute` `pencil` `trash` `share`

### 12.3 Hierarchy

- Primary action icon → `color/primary`
- Decorative or navigational icon → `color/textPrimary`
- Disabled → `color/textDisabled`
- On a colored surface → `color/white`

### 12.4 Composition rules

- Icons never sit alone as actions in the bottom nav — always paired with a label.
- Within a button, icon precedes the label with 8 px gap.
- Status icons (alert, info, check) use the functional color for the stroke.

---

## 13. Accessibility

GetUp is most-used by people who are barely awake. Accessibility *is* usability.

### 13.1 Contrast

- All text meets WCAG AA (4.5:1 for body, 3:1 for ≥18 pt or bold ≥14 pt).
- Primary blue `#0070E8` on white = 4.55 : 1. ✅
- Text secondary `#4A4A4A` on white = 9.45 : 1. ✅
- Text tertiary `#7A7A7A` on white = 4.69 : 1. ✅ (only used for non-critical helper text)
- Disabled `#B8B8B8` is intentionally below AA; never used for actionable text.

### 13.2 Dynamic Type

Every text style maps to an iOS text style. Layouts are tested through AX5. Cards and rows grow vertically; no truncation of primary content.

### 13.3 VoiceOver

Every interactive element has a label, value (where dynamic), and hint when non-obvious.

| Element | Label | Hint |
|---|---|---|
| Alarm Card | "Alarm, 06:30, weekdays, bathroom tag, enabled" | "Double tap to edit" |
| Toggle | "Alarm enabled" / "disabled" | "Double tap to toggle" |
| NFC scanning area | "Scanning for tag" | "Hold the top of your phone near the tag" |
| Primary button | label as displayed | omit hint unless needed |
| Bottom tab | "Alarms tab, selected" | omit |

The active alarm screen uses `accessibilityViewIsModal = true` and announces "Alarm ringing. Go scan your tag." on appear.

### 13.4 Haptics

| Trigger | Haptic |
|---|---|
| Tab switch | `.selection` |
| Toggle change | `.selection` |
| Primary button | `.impact(.medium)` |
| NFC first detection | `.impact(.light)` |
| NFC confirmed | `.notification(.success)` |
| Error / failed scan | `.notification(.error)` |
| Alarm fire (in-app) | continuous pattern (heart-like, 0.4 s on / 0.6 s off) |

### 13.5 Reduced motion

When `UIAccessibility.isReduceMotionEnabled`:
- Disable card stagger entrance.
- Replace NFC pulsing rings with a static ring + a 1 px blinking dot at center (1 Hz).
- Replace error shake with background flash.
- Page transitions become cross-fade only.

### 13.6 Touch targets

Minimum 44 × 44 pt for every interactive element. Where a visual is smaller (e.g. a day-of-week chip at 40 px), the tap region is expanded invisibly.

### 13.7 Color-blind safety

- Status is never communicated by color alone. Success = checkmark + green. Error = alert icon + red. Warning = warning icon + orange.
- Streak dots include a today-marker stroke ring, not just a different fill.

---

## 14. iOS Implementation Notes

### 14.1 SwiftUI components

- Adopt SwiftUI for all new surfaces; UIKit only for the alarm presentation layer (which needs `UNNotificationContentExtension` and critical alert handling).
- Define design tokens as a `DesignSystem` namespace (`DesignSystem.Color.primary`, etc.) backed by an asset catalog with light/dark variants.
- Components are SwiftUI views matching the names in §5: `PrimaryButton`, `AlarmCard`, `NFCSetupCard`, etc.

### 14.2 Safe area

All screens respect `safeAreaInsets`. The active alarm screen explicitly extends to the full screen (ignores safe area for background fill) but keeps content within the safe insets.

### 14.3 Dark mode

Dark mode is **roadmapped, not v1**. Tokens are defined as semantic, so the future dark palette will map cleanly. Until then, the app forces light mode (`overrideUserInterfaceStyle = .light`) and we communicate this honestly in settings: "Dark mode coming soon."

When dark mode ships, neutrals invert: background `#0E0E0E`, surface `#1A1B1D`, border `#2A2C30`. Blue remains `#0070E8` (sufficient contrast on dark surfaces).

### 14.4 Haptics

Use `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`, `UISelectionFeedbackGenerator`. Prepare the generator a frame before the event (e.g. when alarm screen mounts, prepare the success generator).

### 14.5 NFC permission handling

- Use `CoreNFC` `NFCNDEFReaderSession` for read.
- Trigger the session when the active alarm screen appears.
- iOS requires a UI-initiated scan; the critical alert tap satisfies this.
- The Info.plist key `NFCReaderUsageDescription` reads: "GetUp uses NFC to read your tag and turn off the alarm."

### 14.6 Alarm permission handling

- Use `UNUserNotificationCenter` with `.criticalAlert`, `.alert`, `.sound`, `.providesAppNotificationSettings`.
- Critical alert entitlement requires an Apple entitlement — onboarding explains the *why* before showing the system prompt.
- If critical alert is denied, the app degrades gracefully: a standard notification + a stern but clear screen explaining the alarm may not ring in silent mode.

### 14.7 Notification behavior

- Each alarm corresponds to one or more scheduled `UNNotificationRequest`s with a custom category (`ALARM_RING`).
- The category has one action: "Open" — tapping it brings the user into the active alarm screen and starts NFC.
- Sound is a 30-second loop (`alarm.caf`) that auto-repeats up to 10 minutes by chaining 20 notifications 30 s apart.

### 14.8 Locked / backgrounded behavior

- When the app is locked: the alarm appears as a critical notification on the lock screen. The user taps it (or uses dynamic island) to enter scanning mode.
- When backgrounded: same path.
- When in foreground: the active alarm screen presents immediately.
- The NFC reader cannot run continuously in background — this is an OS limit, not a design choice. We explain this in Help.

---

## 15. Design Tokens

The complete token table. Every value in this document is a token; nothing in the codebase should be a magic number.

### 15.1 Color tokens

| Token | Hex | Alpha |
|---|---|---|
| `color/primary` | `#0070E8` | 1.0 |
| `color/primaryPressed` | `#005FC4` | 1.0 |
| `color/primaryLight` | `#EAF4FF` | 1.0 |
| `color/primarySoft` | `#F3F8FF` | 1.0 |
| `color/white` | `#FFFFFF` | 1.0 |
| `color/offWhite` | `#FAFAFA` | 1.0 |
| `color/surface` | `#F5F6F7` | 1.0 |
| `color/border` | `#E5E7EB` | 1.0 |
| `color/divider` | `#EEEEEE` | 1.0 |
| `color/textPrimary` | `#111111` | 1.0 |
| `color/textSecondary` | `#4A4A4A` | 1.0 |
| `color/textTertiary` | `#7A7A7A` | 1.0 |
| `color/textDisabled` | `#B8B8B8` | 1.0 |
| `color/success` | `#19A463` | 1.0 |
| `color/successBg` | `#EAF8F1` | 1.0 |
| `color/warning` | `#FF9500` | 1.0 |
| `color/warningBg` | `#FFF4E5` | 1.0 |
| `color/error` | `#E5484D` | 1.0 |
| `color/errorBg` | `#FFF0F0` | 1.0 |
| `color/backdrop` | `#111111` | 0.32 |

### 15.2 Typography tokens

See §2 — each row in the type scale is a token. Names follow `type/<role>`.

### 15.3 Radius tokens

| Token | Value | Use |
|---|---|---|
| `radius/xs` | 4 px | Inline tags |
| `radius/sm` | 8 px | Pills, chips, input fields |
| `radius/md` | 10 px | Search field |
| `radius/lg` | 14 px | Buttons, alarm card |
| `radius/xl` | 20 px | Modal sheets, NFC setup card |
| `radius/full` | 999 px | Day-of-week chips, status dots |

### 15.4 Shadow tokens

GetUp uses **almost no shadows**. Elevation is communicated by surface color and border, not blur.

| Token | Value | Use |
|---|---|---|
| `shadow/none` | none | Default for cards and rows |
| `shadow/sheet` | `0 -2px 12px rgba(17,17,17,0.04)` | Bottom nav, modal sheet top edge |
| `shadow/floating` | `0 8px 24px rgba(17,17,17,0.08)` | Reserved for the floating action button if one is ever introduced (not in v1) |

### 15.5 Spacing tokens

See §3. `space/2xs` (4) → `space/4xl` (56).

### 15.6 Motion tokens

See §9. `motion/fast` (150) → `motion/hero` (500). Easing tokens `easing/standard`, `easing/decelerate`, `easing/accelerate`, `easing/emphasized`.

### 15.7 Z-index / elevation

| Token | Value | Use |
|---|---|---|
| `z/base` | 0 | Content |
| `z/sticky` | 100 | Section sticky headers |
| `z/nav` | 200 | Bottom navigation |
| `z/sheet` | 300 | Modal sheets |
| `z/banner` | 400 | Error / success banners |
| `z/alarm` | 900 | Active alarm full-screen takeover |
| `z/toast` | 1000 | Top-level toasts (above everything) |

### 15.8 Token file shape (reference)

```json
{
  "color": {
    "primary": "#0070E8",
    "primaryPressed": "#005FC4",
    "...": "..."
  },
  "type": {
    "largeTitle": { "size": 34, "lineHeight": 41, "weight": 700, "tracking": 0.37 },
    "...": {}
  },
  "space": { "2xs": 4, "xs": 8, "sm": 12, "md": 16, "lg": 20, "xl": 24, "2xl": 32, "3xl": 40, "4xl": 56 },
  "radius": { "xs": 4, "sm": 8, "md": 10, "lg": 14, "xl": 20, "full": 999 },
  "motion": {
    "duration": { "fast": 150, "base": 220, "slow": 300, "hero": 500 },
    "easing": {
      "standard": [0.2, 0, 0, 1],
      "decelerate": [0, 0, 0, 1],
      "accelerate": [0.3, 0, 1, 1],
      "emphasized": [0.2, 0, 0, 1]
    }
  },
  "z": { "base": 0, "sticky": 100, "nav": 200, "sheet": 300, "banner": 400, "alarm": 900, "toast": 1000 }
}
```

---

## Appendix A — Component → screen matrix

| Component | Used on |
|---|---|
| Primary Button | Every screen with a main action |
| Secondary Button | Onboarding, alarm overview ("Add alarm"), settings rows |
| Text Button | Onboarding skip, modal cancel, help links |
| Destructive Button | Alarm edit (delete), settings danger zone |
| NFC Setup Card | Home (when no tag), NFC setup screen |
| Alarm Card | Home |
| Morning Routine Card | Alarm creation, Success screen |
| Progress Card | Home, Progress screen |
| Bottom Navigation | All top-level screens (hidden during active alarm and modal flows) |
| Toggle | Alarm card, Settings |
| Time Picker | Alarm creation, Alarm edit |
| Modal Sheet | NFC troubleshooting, change tag, sound picker |
| Confirmation Screen | Tag paired, Alarm dismissed, Streak milestones |
| Empty State | Alarms tab (no alarms), Progress (no data) |
| Error State | NFC fail, validation, network |

## Appendix B — Open questions / v2 candidates

These are intentionally **out of scope** for the v1 specified above:

- Dark mode token set (mapped, not designed)
- iPad layout (currently phone-only)
- Apple Watch companion (start/stop scan from wrist)
- Family / household shared accountability
- Sleep score integration via HealthKit
- Multi-tag-per-alarm routes ("scan bathroom, then kitchen")

These should reuse the system above; nothing in this document needs to be rewritten to accommodate them.

---

*End of design.md — v1.0*
