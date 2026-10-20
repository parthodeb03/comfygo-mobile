# ComfyGo — Phase 0 Audit + Phase 1 Design System Spec

Project audited: `E:/New folder (2)/Android Studio Projects/StudioProjects/untitled`
(the `C:/Users/FLS/StudioProjects/untitled` folder contains only stale build artifacts).

No screen code has been changed. Only the backend seed/data desync was fixed
(see Appendix A), because it was explicitly requested and is not UI work.

---

## PHASE 0 — AUDIT

Severity: 1 = cosmetic, 5 = breaks a core task/accessibility.

| # | Screen / file | Problem | Why it hurts users | Sev | Fix in |
|---|---|---|---|---|---|
| 1 | `core/theme/app_colors.dart` + `one_ui_colors.dart` + `nature_background.dart` | Two competing colour systems plus painter colours (`#2FA96C`, `#8BCB6B`) that do not exist in either token set. 171 raw `Color(0x…)` literals in `lib/`. | The same "green" changes meaning per screen; dark mode can't be tuned in one place; brand feels inconsistent. | 5 | Phase 1 tokens, Phase 2 migration |
| 2 | `login_screen.dart`, `splash_screen.dart` | White logo icon on `primaryDark #7ED0A2` = **1.84:1**; splash does the same at 48dp. | Brand mark nearly disappears for low-vision users in dark mode. | 5 | Phase 1 `onPrimary`, Phase 3 auth |
| 3 | `core/widgets/one_ui_chip.dart` | Confirmed `#9EAF28` and completed `#B6CC35` are near-identical lime; white label contrast **2.44:1** and **1.80:1**. | Users can't tell a finished trip from an upcoming one, and can't read either label. | 4 | Phase 1 status tokens, Phase 2 chip |
| 4 | `core/widgets/navigation_shell.dart`, `app_router.dart` | Shell declares 4 routes (`/`, `/destinations`, `/bookings`, `/profile`) but renders only 3 tabs; tab 0 calls `context.go('/destinations')`. | Home is unreachable after the first tab switch; "Search" opens the destination list, not search. | 5 | Phase 2 navigation |
| 5 | `destinations_screen.dart` | 2-column grid with fixed `childAspectRatio: 0.72` at 360dp; title max 2 lines with ellipsis. | Long Bengali place names and 1.6× text clip or truncate critical content. | 4 | Phase 3 destination card |
| 6 | `home_screen.dart` | Both carousels are locked to `SizedBox(height: 300)`; loading uses spinners; home header uses 5 hard-coded font sizes. | At 1.6× text the fixed 300dp row can clip; spinner flashes look like a template app. | 3 | Phase 3 home |
| 7 | whole `lib/features` | **318** `fontSize:` literals; radii, durations and spacing are hand-written per screen. | No typographic rhythm; every new screen drifts further from the brand. | 4 | Phase 1 tokens, Phase 2 components |
| 8 | `one_ui_theme.dart` | `useMaterial3: false` in both themes; `GoogleFonts.poppins()` still exposed as a runtime API; M2 defaults leak into dialogs, chips and buttons. | Contradicts the Material 3 constraint, adds a runtime font dependency, and produces "default Material" widgets. | 3 | Phase 1 theme |
| 9 | `one_ui_typography.dart`, `pubspec.yaml` | Muli has no Bengali glyphs; no `fontFamilyFallback`; `৳` is used in 14 UI files and no bundled font is guaranteed to contain it. | Bengali place names and the taka sign fall back unpredictably per OS/device. | 4 | Phase 1 typography |
| 10 | `login_screen.dart` | `"Welcome back 👋"` emoji; 28/14px hard-coded. | Reads as a stock template, contradicts the boutique brief. | 2 | Phase 3 auth |
| 11 | `destinations_screen.dart` | Favourite toggle is 38×38dp, icon-only, no tooltip/semantics. | Below the 48dp minimum and unlabeled for screen readers. | 3 | Phase 2 destination card |
| 12 | `main.dart` offline banner | Retry control is ~28dp tall inside a bare `Container`. **Claimed wrong BuildContext was checked and is false** — Flutter 3.47 wraps `MaterialApp.builder` in `Theme` + `ScaffoldMessenger`, so `AppColors` resolves correctly. Real defect is the 28dp target and duplicated colour logic. | Hard to tap; offline colour drifts from the token set. | 3 | Phase 2 offline banner |
| 13 | list/image layer | 16 `CircularProgressIndicator` vs **one** `Shimmer`; no `memCacheWidth`; `NatureBackground` `CustomPaint` has no `RepaintBoundary`. | Large photos decode at full resolution; painter repaints with scrolling content. | 3 | Phase 2/performance |
| 14 | app-wide | Only **5** `Semantics`/`tooltip` uses across 76 taps; bottom-nav labels are hidden and icons are unlabeled (`Icons.search`, `Icons.bookmark_border`). | Screen-reader users hear "button" three times; keyboard focus has no visible state. | 4 | Phase 2 navigation/components |
| 15 | dark theme | Body contrast is good (15.17:1), but status/tier colours and lime accents are raw constants, not theme-aware. | Chips can become bright lime islands on green-black surfaces. | 3 | Phase 1 tokens, Phase 2 chips |
| 16 | icon set | Mix of `Icons.*`, `Icons.*_rounded`, `Icons.bookmark_border`, and a bundled FontAwesome font. | Violates "one icon family"; inconsistent stroke weight. | 2 | Phase 2 |

### Verified / rejected claims from the brief

- **Verified:** competing colour systems, dark-mode white-on-light-green, near-identical booking statuses, emoji/hard-coded styles, unreachable Home tab, fixed-height cards, spinners instead of skeletons, missing Bengali fallback.
- **Partially verified:** `mainAxisExtent: 300` exists only in the unused `adaptiveGridDelegate` helper; the live fixed sizes are the Home carousels (300dp) and the Destinations grid (`0.72` ratio).
- **Rejected:** `main.dart` does not use a wrong `BuildContext`. `MaterialApp.builder` sits below `Theme` and `ScaffoldMessenger`; the loading screen and banner resolve the theme correctly.
- **Good news:** no `withOpacity`, no `BackdropFilter`, no `ImageFilter.blur` in `lib/`; 42 explicit `maxLines` guards already exist.

### Design diagnosis

ComfyGo already has the raw material of a calm nature brand — forest green, cream, sage, and real Bangladesh photography — but it is applied as decoration rather than as a system. Screens are individually attractive yet inconsistent: three different greens, two token files, 171 raw hex values and 318 hard-coded type sizes, so contrast and rhythm drift from screen to screen. The biggest user-facing failures are not aesthetic: dark-mode buttons are unreadable at 1.84:1, two booking states are indistinguishable at ~2:1, and Home cannot be reached from the tab bar. The redesign should therefore feel less like "more styling" and more like editing: remove competing accents, make photography carry the emotion, and let one forest green and one clay accent do all the semantic work.

### Three governing principles

1. **Photo first, text always legible.** Every image is a full-bleed stage, never a background behind unmeasured text: fixed aspect ratios, a green-black scrim of at least 0.68 alpha under any white copy, and a graceful local-asset fallback.
2. **One accent, one money colour.** Forest green is the only interactive/brand accent. Clay/gold appears only for prices, premium tier and at most one CTA per screen. Nothing else competes.
3. **Quiet UI.** Generous negative space, one primary action per screen, flat surfaces with green-tinted elevation, and motion that explains a transition rather than performing.

---

## PHASE 1 — DESIGN SYSTEM SPEC

> All Pantone references are approximate. Verify every hex in Pantone Connect before print/brand use.

### 1.1 Colour

Palette families (approximate Pantone):

| Family | Role | Light | Dark | Approx. Pantone |
|---|---|---|---|---|
| Forest | primary / CTA | `#176F47` | `#86D6A8` | 3415 C |
| Deep forest | on-primary-container, scrims | `#11372A` | `#0A2416` | 3435 C |
| Moss | secondary | `#556B2F` | `#B7CE86` | 2265 C |
| Sage | containers, tints | `#DDEFE4` | `#1E3A2B` | 621 C |
| Cloud | background | `#F4F5F0` | `#0F1611` | 11-0602 TCX |
| Clay / gold | price, premium, one CTA | `#8A5A00` | `#E8B86A` | 1255 C |
| Stone | secondary text | `#5B6358` | `#C4CBBE` | 418 C |
| River blue | info / completed | `#2A5D7A` | `#9CD3EC` | 7698 C |
| Signal red | error / cancelled | `#B3261E` | `#FFB4AB` | 1805 C |
| Amber | pending / warning | `#8A5A00` | `#F2C14E` | 1255 C |

#### Light tokens

| Token | Hex | Used for |
|---|---|---|
| `primary` | `#176F47` | CTA fill, links, selected nav |
| `onPrimary` | `#FFFFFF` | text/icon on primary |
| `primaryContainer` | `#DDEFE4` | soft green chips/cards |
| `onPrimaryContainer` | `#11372A` | text on soft green |
| `secondary` | `#556B2F` | secondary accent (≤30%) |
| `onSecondary` | `#FFFFFF` | text on moss |
| `tertiary` | `#8A5A00` | price / premium / one CTA |
| `onTertiary` | `#FFFFFF` | text on clay |
| `background` | `#F4F5F0` | page |
| `surface` | `#FFFFFF` | cards, sheets |
| `surfaceVariant` | `#E7ECE3` | inputs, quiet chips |
| `outline` | `#7C8676` | interactive border/focus |
| `divider` | `#DCE1D8` | decorative separators only |
| `textPrimary` | `#1B211A` | body/headings |
| `textSecondary` | `#5B6358` | supporting copy |
| `textHint` | `#66705F` | placeholders |
| `success` | `#17603E` | success |
| `warning` | `#8A5A00` | warning |
| `error` | `#B3261E` | error |
| `info` | `#2A5D7A` | info |

#### Dark tokens

| Token | Hex | Used for |
|---|---|---|
| `primary` | `#86D6A8` | CTA fill, links, selected nav |
| `onPrimary` | `#0A2416` | text/icon on primary |
| `primaryContainer` | `#1E3A2B` | soft green containers |
| `onPrimaryContainer` | `#CBEBD8` | text on soft green |
| `secondary` | `#B7CE86` | secondary accent |
| `onSecondary` | `#0A2416` | text on moss |
| `tertiary` | `#E8B86A` | price / premium / one CTA |
| `onTertiary` | `#0A2416` | text on gold |
| `background` | `#0F1611` | page (green-black) |
| `surface` | `#171F19` | cards/sheets (elevation = tint) |
| `surfaceVariant` | `#222C24` | inputs/quiet chips |
| `outline` | `#6C7A6A` | interactive border/focus |
| `divider` | `#2C352D` | decorative separators only |
| `textPrimary` | `#F1F4EE` | body/headings |
| `textSecondary` | `#C4CBBE` | supporting copy |
| `textHint` | `#9BA495` | placeholders |
| `success` | `#86D6A8` | success |
| `warning` | `#F2C14E` | warning |
| `error` | `#FFB4AB` | error |
| `info` | `#9CD3EC` | info |

#### Measured WCAG contrast (computed, sRGB)

| Pair | Ratio | Target | Result |
|---|---|---|---|
| Light: `onPrimary` on `primary` | **6.17** | 4.5 text / 3 icon | pass |
| Light: `primary` on `background` | **5.64** | 4.5 | pass |
| Light: `primary` on `surfaceVariant` | **5.15** | 4.5 | pass |
| Light: `textPrimary` on `background` | **14.98** | 4.5 | pass |
| Light: `textPrimary` on `surfaceVariant` | **13.69** | 4.5 | pass |
| Light: `textSecondary` on `background` | **5.69** | 4.5 | pass |
| Light: `textSecondary` on `surfaceVariant` | **5.19** | 4.5 | pass |
| Light: `textHint` on `background` | **4.73** | 4.5 | pass |
| Light: `textHint` on `surface` | **5.19** | 4.5 | pass |
| Light: `onPrimaryContainer` on `primaryContainer` | **10.94** | 4.5 | pass |
| Light: `onTertiary` on `tertiary` (clay) | **5.93** | 4.5 | pass |
| Light: `tertiary` on `background` | **5.41** | 4.5 | pass |
| Light: `tertiary` on `surfaceVariant` | **4.94** | 4.5 | pass |
| Light: `onSecondary` on `secondary` | **5.95** | 4.5 | pass |
| Light: `onError` on `error` | **6.54** | 4.5 | pass |
| Light: `onSuccess` on `success` | **7.56** | 4.5 | pass |
| Light: `onInfo` on `info` | **7.13** | 4.5 | pass |
| Light: `outline` on `surface` (UI boundary) | **3.80** | 3.0 | pass |
| Dark: `onPrimary` on `primary` | **9.55** | 4.5 / 3 | pass |
| Dark: `primary` on `background` | **10.67** | 4.5 | pass |
| Dark: `textPrimary` on `background` | **16.55** | 4.5 | pass |
| Dark: `textPrimary` on `surface` | **15.17** | 4.5 | pass |
| Dark: `textSecondary` on `surface` | **10.14** | 4.5 | pass |
| Dark: `textHint` on `surface` | **6.53** | 4.5 | pass |
| Dark: `onPrimaryContainer` on `primaryContainer` | **9.68** | 4.5 | pass |
| Dark: `onSecondary` on `secondary` | **9.54** | 4.5 | pass |
| Dark: `onTertiary` on `tertiary` | **9.00** | 4.5 | pass |
| Dark: `onError` on `error` | **10.82** | 4.5 | pass |
| Dark: `tertiary` on `surfaceVariant` | **7.91** | 4.5 | pass |
| Dark: `outline` on `surface` | **3.71** | 3.0 | pass |
| Dark: `outline` on `surfaceVariant` | **3.18** | 3.0 | pass |

#### Before / after (shades changed)

| Token | Before | After | Evidence |
|---|---|---|---|
| `primary` light | `#1B7A4F` | `#176F47` | white 5.33 → **6.17**; on soft green 4.44 → **5.15** |
| `primary` dark | `#7ED0A2` | `#86D6A8` | fix is the on-colour: white 1.84 → dark ink **9.55** |
| `statusPending` | `#FFC107` | `#8A5A00` on `#FFF1CC` | white-on-amber 1.63 → **5.28** |
| `statusConfirmed` | `#9EAF28` | `#17603E` on `#DDF0E4` | white 2.44 → **6.35** |
| `statusCompleted` | `#B6CC35` | `#2A5D7A` on `#DCECF5` | white 1.80 → **5.89** |
| `statusCancelled` | `#F44336` | `#A32A22` on `#FBE3E0` | white 3.68 → **5.90** |
| `textHint` light | `#858678` | `#66705F` | 3.70 → **4.73** |
| `outline` light | `#C9CFC3` | `#7C8676` | 1.59 → **3.80** (UI boundary) |

#### Booking statuses (colour + icon + label — never colour alone)

| Status | Light fg / bg | Dark fg / bg | Icon | Label |
|---|---|---|---|---|
| Pending | `#8A5A00` / `#FFF1CC` (5.28) | `#F2C14E` / `#3A2E12` (7.92) | `schedule_rounded` | Pending |
| Confirmed | `#17603E` / `#DDF0E4` (6.35) | `#8FE0B0` / `#173A28` (8.05) | `check_circle_rounded` | Confirmed |
| Completed | `#2A5D7A` / `#DCECF5` (5.89) | `#9CD3EC` / `#16333F` (8.19) | `done_all_rounded` | Completed |
| Cancelled | `#A32A22` / `#FBE3E0` (5.90) | `#FFB4AB` / `#3E1D1A` (8.86) | `cancel_rounded` | Cancelled |

#### Package tiers

| Tier | Light | Dark | Notes |
|---|---|---|---|
| Basic | `#5B6470` on `#E8EBEF` (5.02) | `#C3CBD6` on `#2A3038` (8.13) | neutral, no accent |
| Pro | `#17603E` on `#DDF0E4` (6.35) | `#8FE0B0` on `#173A28` (8.05) | forest tint |
| Premium | `#8A5A00` on `#FBEDD8` (5.14) | `#F2C14E` on `#3A2E12` (7.92) | gold, price-adjacent |
| Ultimate | `#5B3E8E` on `#EDE7F7` (6.88) | `#D6C2F5` on `#332647` (8.55) | deep violet, one-off |

Usage: **60% neutral surfaces / 30% forest & moss / 10% clay**. Clay only for price, Premium badge, and a single CTA per screen.

### 1.2 Typography

**Families:** Playfair Display (display/headings/prices; alt Cormorant Garamond) + DM Sans (body/UI; alt Plus Jakarta Sans) + **Hind Siliguri** as the bundled Bengali fallback. Exactly 3 families, 9 files total.

Do **not** call `GoogleFonts.*`; bundle files instead. Remove the `google_fonts` dependency at implementation time.

```yaml
flutter:
  fonts:
    - family: PlayfairDisplay
      fonts:
        - asset: assets/fonts/PlayfairDisplay-Regular.ttf
        - asset: assets/fonts/PlayfairDisplay-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/PlayfairDisplay-Bold.ttf
          weight: 700
    - family: DMSans
      fonts:
        - asset: assets/fonts/DMSans-Regular.ttf
        - asset: assets/fonts/DMSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/DMSans-Bold.ttf
          weight: 700
    - family: HindSiliguri
      fonts:
        - asset: assets/fonts/HindSiliguri-Regular.ttf
        - asset: assets/fonts/HindSiliguri-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/HindSiliguri-Bold.ttf
          weight: 700
```

Every generated `TextStyle` must include:

```dart
fontFamily: 'DMSans',
fontFamilyFallback: const ['HindSiliguri', 'NotoSansBengali'],
```

Bengali acceptance strings: **`ঢাকা`**, **`সিলেট`**, **`৳ 12,500`**. Verify the taka sign in Hind Siliguri; if missing, add `NotoSansBengali-Regular.ttf` as the last fallback (10th file, allowed by the "4 per family" rule).

#### Type scale (logical px at textScale 1.0; line heights scale with text)

| Role | Family | Size | Weight | Line height | Tracking | 1.3× | 1.6× |
|---|---|---|---|---|---|---|---|
| Display XL | Playfair | 32 | 700 | 38 | −0.5 | 41.6/49.4 | 51.2/60.8 |
| Display L | Playfair | 28 | 700 | 34 | −0.3 | 36.4/44.2 | 44.8/54.4 |
| Heading H1 | Playfair | 24 | 700 | 30 | −0.2 | 31.2/39 | 38.4/48 |
| Heading H2 | Playfair | 20 | 600 | 26 | 0 | 26/33.8 | 32/41.6 |
| Section title | Playfair | 22 | 700 | 28 | −0.2 | 28.6/36.4 | 35.2/44.8 |
| Card title | DM Sans | 18 | 700 | 24 | 0 | 23.4/31.2 | 28.8/38.4 |
| Body L | DM Sans | 16 | 400 | 24 | 0 | 20.8/31.2 | 25.6/38.4 |
| Body M | DM Sans | 14 | 400 | 22 | 0 | 18.2/28.6 | 22.4/35.2 |
| Body S | DM Sans | 13 | 400 | 20 | 0 | 16.9/26 | 20.8/32 |
| Label | DM Sans | 12 | 600 | 16 | 0.4 | 15.6/20.8 | 19.2/25.6 |
| Caption | DM Sans | 11 | 500 | 16 | 0.4 | 14.3/20.8 | 17.6/25.6 |
| Button | DM Sans | 15 | 700 | 20 | 0.2 | 19.5/26 | 24/32 |
| Price | Playfair | 20 | 700 | 24 | 0 | 26/31.2 | 32/38.4 |
| Bottom nav | DM Sans | 11 | 600 | 14 | 0.2 | 14.3/18.2 | 17.6/22.4 |

- Numeric text uses `fontFeatures: [FontFeature.tabularFigures()]` (prices, dates, counts). Playfair may fall back to proportional figures; DM Sans is the fallback for dense tables.
- Test the whole scale at 1.0, 1.3, 1.6 in the widget test harness; scroll, never clip.

### 1.3 Spacing, shape, elevation

4pt grid tokens: `space-1 4`, `space-2 8`, `space-3 12`, `space-4 16`, `space-5 20`, `space-6 24`, `space-8 32`, `space-10 40`, `space-12 48`, `space-16 64`.

| Breakpoint | Width | Page padding | Gutters | Columns | Nav |
|---|---|---|---|---|---|
| Compact | <600 | 20 | 12 | 1 (lists) / 2 (destination grid, only when width ≥360 and scale ≤1.3) | Bottom bar |
| Medium | 600–839 | 24 | 16 | 2 | Bottom bar / rail if landscape |
| Expanded | ≥840 | 32 | 24 | 3–4 | NavigationRail |

- Content max width **1120**, centered; text measure max **68ch**.
- Radius: `sm 8` (inputs small), `md 12` (inputs), `lg 16` (small cards), `xl 20` (cards/images), `sheet 24`, `pill 999` (buttons/chips/avatars).
- Elevation (light only; dark uses surface tint + 1px outline):

| Level | Offset | Blur | Colour | Use |
|---|---|---|---|---|
| 1 | 0,1 | 2 | `#0B1F17` @ 6% | chips, inputs |
| 2 | 0,4 | 12 | `#0B1F17` @ 8% | cards, bottom bar |
| 3 | 0,12 | 28 | `#0B1F17` @ 10% | sheets, dialogs |

No hard borders except the 1px focus ring (`outline`, 3.8:1) and dark-mode elevation outlines.

### 1.4 Motion

| Token | Duration | Curve | Use |
|---|---|---|---|
| `fast` | 150ms | `easeOutCubic` | press, chip select |
| `base` | 250ms | `easeOutCubic` | page fade/slide, theme switch |
| `slow` | 400ms | `easeOutCubic` enter / `easeInCubic` exit | sheets, hero return |

- Hero image transition only (card image → detail image). No hero on text, buttons or icons.
- Animate opacity/offset/scale ≤1.02; never animate layout height in a scrolling list.
- `MediaQuery.disableAnimations` / reduce-motion: durations → 0, hero → fade, parallax off.
- No looping decorative animation; shimmer is the only permitted loop and stops when data arrives.

### 1.5 Imagery

| Content | Ratio | Notes |
|---|---|---|
| Destination card | 4:5 | full-bleed, title bottom-left |
| Destination hero | 3:2 (compact), 16:9 (expanded) | collapsing header |
| Hotel card | 16:10 | |
| Guide avatar | 1:1 | circular crop |
| Package/booking thumb | 1:1 | 56dp |

- Scrim: transparent at 0.0 → `#0B1F17` @ 0.25 at 0.45 → `#0B1F17` @ 0.78 at 1.0. Worst-case white photo: **8.50:1** under the 0.78 stop; minimum 0.62 alpha anywhere white text sits (**4.87:1** worst case).
- Placeholder: solid `surfaceVariant` + shimmer, never a spinner; error → local division asset; empty URL → local asset.
- Decode: `memCacheWidth = (logicalWidth * devicePixelRatio).round().clamp(…, 1600)`; avatars 2× logical; never decode a 4K photo for a 240dp card.
- Alt text: `Semantics(label: 'Photo of $name, $division')`; decorative scrims excluded.

### 1.6 Performance rules

- No `BackdropFilter`/blur inside scrolling lists. Static headers may use one blur layer.
- No `Opacity` on large subtrees; use colour alpha or `FadeTransition`.
- `RepaintBoundary` around `NatureBackground`/photo painters; `isComplex` only where measured.
- `const` constructors everywhere possible; `ListView.builder`/`SliverList`; stable keys.
- Riverpod `select()` for narrow watches; no provider reads in build loops.
- Skeleton cards for all list/detail loads; no full-screen spinners except splash.
- `cacheWidth`/`memCacheWidth` on every network image; `precacheImage` only for the next hero.

### 1.7 Accessibility

- Minimum 48×48dp for every tap; chips get vertical padding to reach 48.
- `Semantics(button: true, label: …)` on every icon-only control; avatar nav item labeled "Profile".
- Visible focus ring: 2px `outline` + 2px offset; logical focus order follows reading order.
- Contrast: body ≥4.5, large text/icons ≥3.0, UI boundaries ≥3.0; disabled states exempt but still ≥3.0.
- Works at 1.6×: content scrolls, never clips; no fixed-height text containers.
- Colour-blind safe: status/tier always icon + text label.
- Reduce-motion honored; no flashing >3Hz.

### 1.8 State contract (system level)

Every data screen must define all seven states before component work:

| State | Treatment |
|---|---|
| Loading | 2–4 skeleton cards matching final geometry; shimmer 1.2s |
| Empty | illustration/photo, one sentence, one secondary action |
| Error | cause + retry button (48dp), no raw exception text |
| Offline | persistent banner under the app bar, retry action, cached content stays visible |
| Success | content + one primary action |
| Long text | 2-line titles with ellipsis, expandable body on detail |
| 100 items | lazy list/grid, no `shrinkWrap`, no nested scrollables |

---

## Self-review gate (hostile pass)

| # | Criterion | Score | Evidence |
|---|---|---|---|
| 1 | Visual hierarchy | 4 | One primary action per screen, photo-first cards, serif headings vs sans body. |
| 2 | Contrast | 5 | All 31 text/icon pairs computed; lowest body ratio 4.73:1; dark mode lowest 6.53:1. |
| 3 | Token consistency | 4 | Single token table, explicit before/after; migration still pending. |
| 4 | Spacing rhythm | 4 | 4pt scale, three breakpoints, named radii and elevation. |
| 5 | Typography | 4 | 3 families, 9 files, full scale at 1.0/1.3/1.6, tabular figures. |
| 6 | Dark mode | 4 | Designed green-black surface set, tint elevation, 6.53:1 minimum hint text. |
| 7 | Responsiveness | 4 | 360dp, 600/840 breakpoints, max 1120 content, rail at ≥840. |
| 8 | Text scale 1.6× | 4 | Scale table plus scroll-not-clip rule; fixed heights banned. |
| 9 | Loading/empty/error | 4 | Seven-state contract with skeleton geometry. |
| 10 | Performance | 4 | Decode widths, no list blur, RepaintBoundary, lazy lists. |
| 11 | Accessibility | 4 | 48dp, semantics, focus ring, contrast targets. |
| 12 | Bengali rendering | 4 | Bundled Hind Siliguri fallback + explicit test strings for `ঢাকা`, `সিলেট`, `৳ 12,500`. |
| 13 | Designed, not default | 4 | Editorial serif + nature palette + scrim rules; no M2 default leak planned. |

All scores ≥4. No self-rejection triggered.

---

## Verification checklist

Already run on 2026-10-18:

| Check | Result |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test` (full suite) | **173 passed, 12 skipped** (integration skipped by env flag) |
| `pytest -q` (backend) | **138 passed** |
| Live backend integration (`RUN_BACKEND_INTEGRATION=true`) | **12/12 passed** after the guide-media fix |

Still to run after implementation: hot restart, light/dark toggle, 360dp emulator, tablet/landscape, 1.6× font scale, airplane mode, slow network, empty data, screen reader.

---

## Appendix A — Backend synchronization

**Contract audit:** all Flutter service calls match a FastAPI route:

- `/auth` login, register, forgot-password, verify-code, reset-password, refresh, profile (GET/PUT)
- `/destinations` list, featured, detail; `/hotels` CRUD; `/transports` CRUD; `/guides` CRUD
- `/bookings` list/detail/create/cancel/status; `/payments` list/detail/create/confirm/refund
- `/packages`, `/user-packages` current/subscribe/upgrade/cancel
- `/favorites`, `/reviews`, `/contact`, `/admin` login/users/bookings/payments/listings/user-packages/stats

**Desync found and fixed:** every row in `backend/comfygo.db.guides` had `profile_image = NULL`. `seed.py` defines portraits for the first two guides, and `seed_more.py` inserted `NULL` for the other four, so the live API returned `profile_image: null` for all six and the Flutter integration test failed at `guides load and parse`.

- `backend/scripts/seed_more.py` now owns a canonical `GUIDE_IMAGES` map for all six guides.
- New inserts write the portrait instead of `NULL`.
- Existing rows are backfilled idempotently (`update … where profile_image is null or ''`).
- Re-ran `seed_more.py`; all six rows now have portraits; live integration is **12/12 green**.

**Not yet covered end-to-end:** booking creation → payment → review, favourites, and admin flows are exercised by backend pytest but not by the Flutter live integration test. Phase 4 should add those.

---

## Next step (needs approval)

Phase 2 starts with the token/theme foundation and shared components. I need:

1. Approval of this spec (or specific changes).
2. The three font families (`.ttf` files) or permission to fetch and bundle them.
3. Confirmation that the working path is `E:/New folder (2)/Android Studio Projects/StudioProjects/untitled` (the C: copy is stale).
4. Which screen to implement first after the theme foundation: Home or Destinations.
