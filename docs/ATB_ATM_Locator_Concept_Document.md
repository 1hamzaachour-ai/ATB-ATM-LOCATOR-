# ATB ATM Locator — Product Concept Document

| | |
|---|---|
| **Project** | ATB ATM Locator (codename: *ATB Mobile*) |
| **Document type** | Product Concept Document |
| **Version** | 1.0 |
| **Status** | Draft for review |
| **Author** | Hamza Achour — Mobile Software Engineer |
| **Date** | 25 June 2026 |
| **Audience** | Product stakeholders, engineering, design, ATB digital banking team |

---

## 1. Executive Summary

**ATB ATM Locator** is a cross-platform mobile application that helps Arab Tunisian Bank customers **find the nearest, most relevant ATM or branch in seconds** — with live status, smart filters, reliable routing, and full offline availability. It pairs a real-time interactive map with an AI assistant that answers banking questions in **Tunisian dialect (Derja)**, French, and English, all wrapped in ATB's burgundy brand identity.

The concept addresses a concrete, everyday friction — *"Where is the nearest ATM that is open and offers the service I need?"* — and answers it with an experience that is **fast, resilient, and inclusive**, while remaining economically sustainable through open data and free-tier services (no paid map keys).

---

## 2. Vision & Mission

- **Vision:** To be the most trusted and effortless way for every Tunisian to access cash services — anywhere, anytime, online or offline.
- **Mission:** Remove the uncertainty from finding and using an ATM by delivering real-time location intelligence, accessibility information, and conversational guidance in the language people actually speak.

**Design principles**
1. **Never a dead end** — every feature degrades gracefully; the map is never empty.
2. **Speak the user's language** — literally (Derja/FR/EN) and figuratively (zero jargon).
3. **One-handed, one-tap** — optimized for hurried, on-the-go use.
4. **Inclusive by default** — accessibility and offline support are core, not add-ons.

---

## 3. Background & Context

Cash remains central to daily life in Tunisia, yet locating a usable ATM is unreliable: data is stale, service hours vary, and many tools fail in low-connectivity areas. Existing bank apps focus on accounts, not on the *physical journey* to cash. ATB ATM Locator reframes the problem around that journey, turning a generic map into a **purpose-built cash-access companion**.

---

## 4. Problem Statement

Users repeatedly face avoidable failed trips because:

- **Outdated location data** — listed ATMs may be relocated or closed.
- **Unknown availability** — no signal of open/closed, deposit, or cardless support before arriving.
- **No proximity intelligence** — results are not sorted by real distance from the user.
- **Connectivity gaps** — maps fail to load exactly when needed (basements, transit, weak signal).
- **Language barrier** — guidance is rarely available in natural Tunisian dialect.

**Impact:** wasted time, detours, and erosion of trust in digital banking tools.

---

## 5. Concept Overview

ATB ATM Locator is conceived as a **single Flutter application** combining five capability pillars:

1. **Live ATM Map** — real ATM/branch locations on an interactive map, sorted by geodesic distance, with color-coded open/closed markers and composable filters.
2. **AI Assistant (Derja)** — a conversational helper grounded in the user's nearby ATMs, answering in Tunisian dialect, French, or English.
3. **Offline Maps** — downloadable city regions that render with zero connection.
4. **Card & Account Touchpoints** — card carousel, services, transactions, and notifications that anchor the locator inside a familiar banking shell.
5. **Routing & Actions** — one-tap navigation handoff and contextual ATM detail.

The product is **offline-first and resilient by construction**: GPS, live data, and AI each have a graceful fallback so the core task — *find a working ATM* — always completes.

---

## 6. Goals & Objectives

| Objective | Description | Target |
|---|---|---|
| Speed | Time from app open to a routed ATM | ≤ 30 seconds |
| Reliability | Task success (find a usable ATM) | ≥ 95 % |
| Resilience | Core map usable with no network | 100 % (cached region) |
| Inclusivity | WCAG-aligned, multilingual support | AA, 3 languages |
| Sustainability | Marginal cost of map/data | ~0 (open data) |

---

## 7. Target Users & Personas

- **Sami — The Hurried Commuter.** Needs cash fast between transit stops. Values speed, distance sorting, and "is it open *now*."
- **Emma — The Tourist.** Unfamiliar with streets and language. Values clear map context, routing, and English/French guidance.
- **Mr. Khaled — The Accessibility-Reliant User.** Needs predictable, reachable machines and larger text. Values accessibility info and dynamic type.
- **Leïla — The Everyday Customer.** Manages cards and checks balances; discovers the locator from the home screen's quick action.

---

## 8. Key Features (Functional Concept)

### 8.1 Live ATM Map
- Real ATM data fetched around the user; **fallback dataset of 20 Tunisian ATMs** when offline or on API failure.
- **Filters:** Open now · Deposit-capable · Cardless withdrawal (composable, one-handed chips).
- **Markers:** crimson = open, grey = closed, amber outline = selected; animated GPS dot.
- **ATM detail:** name, address, hours, services, distance; **Directions** (maps handoff) and **Details**.

### 8.2 AI Assistant (Derja / FR / EN)
- Conversational answers about ATB services, fees, card blocking, and nearby ATMs.
- Context-aware: injects the user's nearest ATMs and recent conversation.
- Mirrors the user's language and handles code-switching; falls back to scripted Derja replies offline.

### 8.3 Offline Maps
- Download regions (e.g., Greater Tunis) as a single cached file.
- **Resumable** downloads with progress feedback; renders fully without internet.

### 8.4 Banking Shell
- **Cards:** carousel (VISA/Mastercard), services (mobile pay, card security, history, limits).
- **Messages:** notifications grouped by date with Bank/Security/Contacts filters.
- **Profile:** account overview, security, notifications, and language settings.

---

## 9. Value Proposition & Differentiators

- **Real distance sorting** — nearest *usable* ATM, not just nearest pin.
- **Truly offline** — works where competitors show a blank screen.
- **Derja-native AI** — guidance in the language users actually speak.
- **Resilient by design** — every dependency has a fallback; never a dead end.
- **Zero proprietary cost** — open data keeps the product sustainable and scalable.

---

## 10. User Experience Concept

**Primary journey — "Find cash" (3 steps, < 30 s):**
1. **Need** → open app, tap the **DAB / ATM** quick action (or Assistance).
2. **Locate** → map centers on the user; nearest ATMs appear, sorted and filterable.
3. **Withdraw** → select an ATM → view live detail → tap **Directions** → walk and withdraw.

**Secondary journeys:** ask the AI assistant a question; download an offline region; manage a card; review a transaction alert.

The experience favors **progressive disclosure** (map → peek card → full detail), **thumb-zone actions**, and **instant feedback** through motion and status badges.

---

## 11. Technical Concept (High Level)

- **Framework:** Flutter (Dart) — one codebase for Android and iOS, Skia rendering for consistent map overlays.
- **Architecture:** layered — `models` (data) · `services` (logic/I-O) · `screens` (UI) — with a lightweight reactive state model (`setState` + stateless service layer) and `IndexedStack` tab navigation.
- **Mapping:** `flutter_map` + OpenStreetMap raster tiles (no proprietary key).
- **Location:** `geolocator` for permissions, position, and geodesic distance.
- **Data:** Overpass API for live ATM data; curated fallback dataset.
- **AI:** Groq LLaMA (hosted inference) with a trilingual system persona.
- **Offline:** MBTiles (SQLite) cache via a custom tile provider; chunked, resumable downloads.
- **Routing:** deep-link handoff to Google Maps (no embedded routing SDK).

> A detailed architecture diagram and justification are maintained in the companion *Technical Choices & Architecture* paper.

---

## 12. Data, Security & Privacy Concept

- **Open data sources** (OpenStreetMap / Overpass) aligned to a single geographic reference.
- **Least privilege:** only Internet and location permissions; no personally identifiable data stored on device beyond cached map tiles in the app's private directory.
- **Secrets management:** API keys isolated in an untracked config with a versioned template; **recommended production hardening** is to proxy sensitive calls through an ATB backend and inject configuration at build time.
- **Transport:** all network traffic over HTTPS/TLS with explicit timeouts and graceful error handling.

---

## 13. Scope

**In scope (MVP):** live ATM map, distance sorting, filters, ATM detail + routing, offline region download, AI assistant, card/messages/profile shell.

**Out of scope (MVP):** real transactional banking (transfers/payments), biometric auth, push notifications, ATM cash-level prediction, crowdsourced reporting.

**Assumptions:** device has GPS; intermittent connectivity; OpenStreetMap coverage is adequate for target cities.

**Constraints:** OSM fair-use tile policy; AI hosted-inference availability; no paid map services.

---

## 14. Success Metrics (KPIs)

- **Task Success Rate** ≥ 95 % (find a usable ATM)
- **Time-to-Task Completion** ≤ 30 s (open → directions)
- **Offline render success** = 100 % for cached regions
- **App Store rating** ≥ 4.6★
- **D30 retention** ≥ 35 %
- **North Star:** successful ATM navigations enabled per week.

---

## 15. Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Stale/incomplete OSM ATM data | Wrong results | Curated fallback set; future crowdsourced verification |
| API/AI downtime | Degraded help | Scripted offline replies; cached data |
| Tile-policy throttling | Download blocked | Rate-limited, identified User-Agent; staged downloads |
| Embedded API key exposure | Security | Backend proxy + build-time injection (production) |
| GPS battery drain | User churn | One-shot location instead of continuous tracking |

---

## 16. Roadmap (Concept Evolution)

- **Phase 1 — MVP:** map, status, geolocation, offline tiles, AI assistant, banking shell.
- **Phase 2 — V1:** accessibility data layer, dark mode, multilingual polish, wait-time hints.
- **Phase 3 — V2:** real ATB backend integration, biometric auth, push notifications, crowdsourced ATM status, predictive "cash-likely" insights.

---

## 17. Glossary

- **DAB** — *Distributeur Automatique de Billets* (ATM).
- **Derja** — Tunisian Arabic dialect.
- **MBTiles** — single-file (SQLite) map tile storage format.
- **Overpass API** — query service over OpenStreetMap data.
- **Offline-first** — design approach where the app works without network by default.

---

## 18. Conclusion

ATB ATM Locator turns an everyday frustration into a fast, dependable, and inclusive experience. By combining real-time location intelligence, offline resilience, and Derja-native conversational guidance on an open, sustainable technology base, the concept delivers clear user value today and a credible path to a richer banking companion tomorrow.
