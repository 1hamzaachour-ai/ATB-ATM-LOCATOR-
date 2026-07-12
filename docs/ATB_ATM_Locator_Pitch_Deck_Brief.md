# ATB ATM Locator — Stakeholder Pitch Deck
### Content Outline & Design Brief
*Prepared by: Principal UI/UX Product Designer & Mobile Product Strategist*

---

## 0. Global Design Language (applies to every slide)

**Canvas:** 16:9, 1920×1080 px. **Grid:** 12 columns, 96 px outer margins, 24 px gutters. **Spacing:** strict 8 pt system (8/16/24/40/64). **Corner radii:** 16 px cards, 28 px phone frames, 999 px pills.

**Color tokens**
| Token | Hex | Use | Contrast on white |
|---|---|---|---|
| `Crimson/Primary` | `#8B1832` | Brand, CTAs, active map markers | 8.9:1 (AAA) |
| `Burgundy/Deep` | `#5C0F21` | Gradjuent base, dark surfaces | — |
| `Rose/Accent` | `#B22C4A` | Gradient highlight, selected states | 5.1:1 (AA) |
| `Mist/Tint` | `#FFEEF1` | Chips, icon backplates | — |
| `Status/Available` | `#2E7D32` | Cash available, "open" | 4.6:1 (AA) |
| `Status/Low` | `#F0A500` | Low cash / busy | paired w/ icon+label |
| `Status/Out` | `#C62828` | Out of cash / broken | 5.0:1 (AA) |
| `Ink/900` | `#1A1A1A` | Primary text | 16:1 |
| `Slate/500` | `#666666` | Secondary text | 5.7:1 |

**Type:** *Inter* (or SF Pro / Roboto Flex for OS-native feel). Display 64/72 ExtraBold · H1 40/48 Bold · H2 28/36 SemiBold · Body 18/28 Regular · Caption 14/20 Medium. Tabular numerals for all metrics.

**Motion baseline:** standard ease `cubic-bezier(0.2, 0, 0, 1)`, durations 200–400 ms (Doherty threshold). **Imagery:** real Tunis street/map context, never generic stock. **Tone:** sleek, minimalist, confident — heavy negative space, one focal point per slide.

---

## Slide 1 — Title & Vision

**Objective:** Land a high-impact, trust-forward first impression that fuses *financial reliability* with *speed*. The audience should "get" the product in under 3 seconds.

**On-slide copy**
- Logotype: **ATB ATM Locator** (app icon to the left — rounded-square, crimson, location-pin glyph)
- Headline: **"Cash, found. Instantly."**
- Sub-headline: *Real-time ATM intelligence for every street in Tunisia.*
- Footer (small): Presenter name · Role · Date · "Confidential — ATB Mobile Innovation"

**Visual & UI layout**
- Full-bleed diagonal gradient `Burgundy/Deep → Crimson` (top-left → bottom-right).
- Right 5 columns: a single floating **device mockup** (Android/iOS, rounded 28 px frame) showing the live map with a **pulsing crimson location dot** and three clustered ATM pins. Subtle drop shadow + 6° tilt for depth.
- Left 6 columns: logotype top-aligned, then the headline in Display weight, sub-headline below at 40 % opacity white.
- A thin crimson-to-rose underline accent (4 px) sits beneath the headline. No clutter — ~55 % of the slide is intentional empty space.

**UX rationale:** The *halo effect* — a polished cover primes stakeholders to perceive the whole product as credible. A single hero device (Von Restorff isolation) anchors attention; the color gradient signals premium fintech. Stating the value as a 3-word promise respects working-memory limits and is instantly quotable.

---

## Slide 2 — The Friction (Problem Statement)

**Objective:** Make the audience *feel* the pain. Build empathy and urgency before revealing the solution.

**On-slide copy**
- Header: **"Finding cash shouldn't be a gamble."**
- Pain points (cards):
  1. **Outdated data** — *"It says open. It's been closed for months."*
  2. **Out-of-cash machines** — wasted trips, no warning.
  3. **Long, invisible queues** — no way to know before arriving.
  4. **Zero accessibility info** — is it wheelchair-reachable? Unknown.
  5. **Maps that won't load** — dead weight in low-signal zones.
- Stat strip (placeholders): **1 in 3** ATM trips end in failure · **~8 min** average wasted per failed trip.

**Visual & UI layout**
- Deliberately **desaturated** palette (greys, muted ink) — color is drained to mirror frustration.
- Left 4 columns: large header + the stat strip in bold tabular numerals.
- Right 8 columns: a **2×3 card grid** (5 pain cards + 1 empty breathing card), each with a thin single-weight line icon (broken pin, empty wallet, queue, wheelchair-question, no-wifi). Cards are flat, hairline-bordered, low elevation.
- Optional faint background: a blurred, dimmed photo of a person at a broken ATM at dusk.

**UX rationale:** *Loss aversion* — quantifying wasted time/trips makes the cost concrete and motivates change. The desaturation is an emotional design device: the contrast with Slide 3's color "switch-on" creates a felt sense of relief. A 2×3 grid chunks problems for scannability (Miller's law).

---

## Slide 3 — The Seamless Solution (Value Proposition)

**Objective:** Reveal ATB ATM Locator as the obvious answer; convert felt pain into hope.

**On-slide copy**
- Eyebrow: *Introducing*
- Title: **ATB ATM Locator**
- One-liner: **"Every ATM. Real status. Right now."**
- Three pillars:
  - 🛰 **Lightning Geolocation** — nearest working ATM in one tap, sorted by true walking distance.
  - ✅ **Real-Time Reliability** — live "cash available / low / out" status, never stale.
  - 👥 **Crowdsourced Truth** — verified by the people who just used it, seconds ago.

**Visual & UI layout**
- **Color returns at full saturation** — crisp white surface, crimson accents — a visual "exhale" after Slide 2.
- Center: hero device showing the ATM **detail card** with a green "Cash available · verified 2 min ago" badge.
- Beneath/around it, three **pillar chips** in a horizontal row, each with an icon plate (`Mist/Tint`), bold label, one supporting line.
- Connective micro-detail: a faint route line animates from the location dot to the ATM pin.

**UX rationale:** The saturation jump is engineered emotional contrast (relief = positive product association). *Rule of three* keeps the value prop memorable and balanced. Leading with the user benefit ("verified 2 min ago") rather than the tech builds trust through social proof.

---

## Slide 4 — Target Personas & User Journey Map

**Objective:** Prove we designed for real humans, and show how dramatically we compress their effort.

**On-slide copy**
- Header: **"Designed for three very different urgencies."**
- Persona cards:
  - **Sami · The Hurried Commuter** — *Goal:* cash in <5 min between metro stops. *Frustration:* detours to dead machines.
  - **Emma · The Tourist** — *Goal:* a trustworthy ATM that accepts foreign cards. *Frustration:* language + unfamiliar streets.
  - **Mr. Khaled · The Accessibility-Reliant User** — *Goal:* a step-free, wheelchair-reachable ATM. *Frustration:* no a11y data anywhere.
- Journey ribbon: **NEED → LOCATE → WITHDRAW** *(3 taps. Under 30 seconds.)*

**Visual & UI layout**
- Top 7 rows: three **persona cards** side by side — circular avatar, name + archetype, a short italic quote, and Goal/Frustration mini-rows with green/red dot markers.
- Bottom 5 rows: a horizontal **3-step journey ribbon**. Each node is a circled icon (pin-search → map → cash) connected by a progress line. Below the ribbon, a thin **emotion curve** dips at "Need" (anxious) and rises to a peak at "Withdraw" (satisfied).
- Each persona card subtly tints its accent (commuter=crimson, tourist=rose, a11y=teal) for differentiation without breaking palette.

**UX rationale:** Personas convert abstract "users" into people stakeholders can champion (empathy + memorability). The journey ribbon with an **emotion curve** visualizes friction removal — the rising line is the product's value, made literal. Showing "3 taps / 30 s" sets a measurable experience promise.

---

## Slide 5 — The Design System & Brand Identity

**Objective:** Demonstrate craft and consistency; reassure stakeholders the brand is cohesive and accessible by construction.

**On-slide copy**
- Header: **"One system. Every pixel accountable."**
- Blocks:
  - **Palette** — swatches with hex + WCAG contrast ratio labels (trust-building financial crimson + calm neutrals + semantic status colors).
  - **Typography** — *Inter* scale specimen: Display / H1 / Body / Caption with px + line-height.
  - **Iconography** — 2 px rounded-stroke line set; filled variants for active map states; live "micro-interaction" note.
  - **Dark Mode** — first-class, not an afterthought.

**Visual & UI layout**
- Modular dashboard layout, 4 quadrants on an 8 pt grid:
  - **Top-left:** color row — 8 swatches, each a rounded chip with hex + contrast badge (e.g., "8.9:1 AAA").
  - **Top-right:** type specimen stack, left-aligned, showing the full scale with the word "Sfax · Tunis · Sousse" as sample.
  - **Bottom-left:** 5×2 icon grid (pin, cash, wheelchair, clock, route, filter, report, deposit, cardless, profile).
  - **Bottom-right:** **two phone frames** side by side — identical ATM card in **Light** and **Dark** mode, proving token parity.
- Material You note: "Dynamic color — UI can adapt to the user's wallpaper on Android 12+."

**UX rationale:** A visible design system signals engineering maturity and lowers long-term cost (consistency = fewer bugs, faster iteration). Surfacing **contrast ratios on the swatches** proves accessibility is built-in, not bolted-on. Dark mode parity respects user comfort, battery (OLED), and OS-native expectations (iOS HIG + Material You).

---

## Slide 6 — Core Features & High-Fidelity Wireframes

**Objective:** Show, don't tell. Make three hero screens tangible and demonstrate frictionless interaction.

**On-slide copy**
- Header: **"Three screens do the heavy lifting."**
1. **Map & Adaptive Clustering** — *Smart filters: Cash now · Wheelchair · Deposit · 24/7.* Pins cluster at zoom-out, fan out on zoom-in.
2. **ATM Detail Card** — *Live status · predicted wait · distance & one-tap routing.*
3. **Quick Report** — *"Out of cash?" Two taps. Done.*

**Visual & UI layout**
- Three **annotated phone frames** across 12 columns, evenly spaced, each with leader-line callouts in `Slate/500`.
  - **Screen 1 (Map):** full-screen map; floating pill search at top; horizontal **filter chip row** (thumb-reachable); circular crimson **cluster badges** showing counts ("12"); a `my-location` FAB bottom-right. Callouts: "Adaptive clustering," "One-handed filters."
  - **Screen 2 (Detail Card):** bottom-sheet card (peek → expand). Top row: ATM name + **green status badge "Cash available · 2 min ago."** Middle: **wait-time prediction** ("~3 min queue"), distance "320 m · 4 min walk," accessibility icons. Primary CTA **"Directions"** (crimson, full-width), secondary "Report issue." Callouts: "Progressive disclosure," "Thumb-zone CTA."
  - **Screen 3 (Quick Report):** minimalist modal — big header "What's wrong?", **two oversized tap targets**: "💸 Out of cash" / "🚫 Broken," then an auto-dismiss success state with checkmark. Callout: "2-tap report → <5 s."
- Visual treatment: high-fidelity, realistic shadows, true map tiles behind Screen 1.

**UX rationale:** *Hick's Law* — filters are reduced to 4 high-intent chips to minimize decision time. *Fitts's Law / thumb-zone* — primary actions and filters live in the lower reachable arc for one-handed use. The detail card uses **progressive disclosure** (peek then expand) to avoid overwhelming. The 2-tap report deliberately minimizes effort so crowdsourced data actually gets contributed — the data network effect depends on this friction being near-zero.

---

## Slide 7 — UX Differentiators & Accessibility (A11y)

**Objective:** Position accessibility and resilience as competitive moats, not compliance checkboxes.

**On-slide copy**
- Header: **"Usable by everyone, everywhere — even offline."**
- Pillars:
  - **WCAG 2.2 AA by default** — 4.5:1 text contrast, 44×44 pt touch targets, visible focus states.
  - **Status never relies on color alone** — every state pairs an icon + text label (color-blind safe).
  - **Offline-first maps** — pre-cached tiles render with zero signal; the map is never a blank screen.
  - **Dynamic Type** — text scales to 200 % without breaking layout; built for older eyes.
  - **Screen-reader native** — semantic labels for VoiceOver / TalkBack on every control.

**Visual & UI layout**
- Split layout. **Left 5 cols:** a vertical checklist, each item a green check + bold standard + one-line proof.
- **Right 7 cols:** a single phone frame in **"Large Text" mode** — the ATM card re-flowed at 180 % type, with a **VoiceOver focus ring** highlighting the status badge and a speech-bubble showing the spoken label: *"Agence Tunis Marine, cash available, 320 meters, button."*
- Inset chip: "✈️ Offline" badge on a rendered map proving tiles load without network.

**UX rationale:** ~15–20 % of users have a disability and a far larger share experience *situational* impairments (bright sun, one hand full, poor signal). Designing for the edges improves the experience for everyone (curb-cut effect) and **expands the addressable market**. Color-independent status is a hard requirement for ~8 % color-vision-deficient men. Offline rendering directly attacks the Slide 2 "maps won't load" pain.

---

## Slide 8 — Micro-Interactions & Motion Design

**Objective:** Convey the *feel* of the product — the polish that turns a utility into something delightful and trusted.

**On-slide copy**
- Header: **"Motion that informs, never distracts."**
- Moments:
  - **Locating pulse** — a soft crimson radar pulse on the current-location dot (1.4 s loop).
  - **Map ease** — fluid recenter on tap, decelerating with a natural spring.
  - **Marker bounce-in** — pins drop and settle when results load.
  - **Skeleton shimmer** — perceived-instant loading for the ATM list.
  - **Haptic reward** — a crisp success tick + checkmark burst after a report is submitted.
  - **Status transition** — badge cross-fades green→amber→red as live data changes.

**Visual & UI layout**
- A horizontal **filmstrip** of 5–6 frames showing a single interaction (e.g., tap pin → card slides up → directions), with motion arrows and ghosted "before/after" states.
- Below each frame: a **timing token chip** ("220 ms · ease-out") and the **easing curve** drawn as a tiny graph.
- Right edge: a small panel illustrating the **haptic pattern** (waveform) tied to "Report success."
- Keep backgrounds clean white so motion annotations read clearly.

**UX rationale:** Motion provides *feedback* and *continuity* — it tells users the system heard them (reducing uncertainty) and maintains spatial context during transitions. Staying under the **Doherty threshold (~400 ms)** keeps interactions feeling instantaneous. The success haptic is an *operant reward* that reinforces the reporting behavior the crowdsourced model depends on. Skeleton loaders improve *perceived* performance even when network latency is unchanged.

---

## Slide 9 — Product Roadmap & Success Metrics

**Objective:** Give stakeholders a credible path from MVP to scale, anchored to measurable UX outcomes.

**On-slide copy**
- Header: **"From MVP to category leader."**
- Timeline:
  - **Phase 1 · MVP (Q1)** — Map, real-time status, geolocation, 2-tap report, offline tiles.
  - **Phase 2 · V1 (Q2–Q3)** — Wait-time prediction, accessibility data layer, dark mode, multilingual (AR/FR/EN).
  - **Phase 3 · V2 (Q4+)** — In-app ATB account linking, branch services, predictive "cash-likely" ML, rewards for top reporters.
- **UX KPIs (targets):**
  - **Task Success Rate** ≥ **95 %** (find a working ATM)
  - **Time-to-Task Completion** ≤ **30 s** (open → directions)
  - **Report submission rate** ≥ **1 per 5 sessions**
  - **App Store rating** ≥ **4.6★**
  - **D30 retention** ≥ **35 %**

**Visual & UI layout**
- **Top 6 rows:** a horizontal **timeline** with three phase nodes on a left→right progress rail; each node is a card with phase label, quarter tag, and 3–4 feature bullets. Completed/MVP node filled crimson, future nodes outlined.
- **Bottom 6 rows:** a **KPI dashboard** strip — 5 metric tiles, each with a big tabular-number target, a tiny sparkline trend, and a label. Use semantic green accents for "on target."
- A faint North-Star callout above the dashboard: *North Star = Successful Withdrawals Enabled / week.*

**UX rationale:** Tying the roadmap to **behavioral KPIs** (not vanity downloads) signals product maturity and gives stakeholders a shared definition of success. A single **North-Star metric** aligns the team. Showing the MVP as already-scoped reduces perceived risk and makes the ask concrete.

---

## Slide 10 — Thank You / Call to Action

**Objective:** End on an emotional, memorable high and a single clear next step (peak-end rule).

**On-slide copy**
- Mantra (Display weight): **"Stop searching. Start withdrawing."**
- Sub-line: *ATB ATM Locator — the shortest distance between you and your cash.*
- CTA: **Scan to try the beta** (QR placeholder) · or **request a live demo**.
- Contacts (placeholders): Name · Role · email@atb.com.tn · +216 XX XXX XXX · @ATBMobile

**Visual & UI layout**
- Return to the Slide 1 **`Burgundy → Crimson` gradient** for bookend symmetry.
- Center-stage: oversized mantra, the app icon above it, and a clean **QR code** in a white rounded card (high contrast for scannability).
- Bottom band: a single thin row of contact placeholders in caption type, evenly spaced, low-emphasis.
- One small flourish: the location-dot pulse from Slide 1, now static and "landed" on a pin — visual closure of the narrative.

**UX rationale:** *Peak-end rule* — audiences remember the emotional peak and the ending, so the closing mantra carries the whole pitch's sentiment. Bookending the gradient creates narrative closure. A **single, scannable CTA (QR)** removes friction from the one action you want stakeholders to take next — consistent with the app's own frictionless philosophy.

---

### Deck-level production notes
- **Build:** Figma (components + auto-layout) → export to Keynote/PPTX, or a reveal.js/HTML deck for live interactivity.
- **Consistency:** one focal element per slide; never more than ~30 words of body copy visible at once.
- **Accessibility of the deck itself:** 24 pt minimum on-screen text, AA contrast, alt-text on all exported images.
- **Demo backup:** embed a 20-second screen recording of the real map + report flow after Slide 6 for live pitches.
