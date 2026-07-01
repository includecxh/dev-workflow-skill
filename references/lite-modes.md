# Lite Modes — Phase 1 Lite & Phase 2 Lite

This document details the streamlined modes available for 🟢 Simple complexity projects.

## When Lite Mode Applies

Lite mode is only available when Phase 0 assessed complexity as 🟢 (Simple). If at any point during Lite mode the scope expands beyond simple, upgrade to 🟡 and switch to standard mode.

## Phase 1 Lite — Quick Design Confirmation

Instead of the full brainstorming process (explore → ask → propose approaches → present design → write spec → review), Lite mode condenses this into 3 steps:

### Step 1: Quick Confirmation (2-3 questions)

Ask focused questions about key constraints and boundary conditions. Prefer multiple choice. Examples:

- "This change only affects the profile page — does it need to persist across sessions?"
- "Should this validation be client-side only, or also server-side?"
- "Which edge cases matter: empty input, special characters, or max length?"

### Step 2: Inline Design (conversation, not document)

Present the design directly in the conversation — one paragraph covering:
- Architecture: what component(s) change and how
- Data flow: what data moves where
- Key decisions: any choices made and why

Example:
> "Design: Add a `maxLength` prop to the TextInput component. The prop validates on both keystroke (client) and form submit (server via existing validation middleware). No new tables or APIs — just extend the existing validation chain. Error message uses the existing i18n key pattern."

### Step 3: Quick Approval

User confirms → move to Phase 2 Lite. No separate design document, no spec review loop.

**What you DON'T do in Lite mode:**
- Multiple approach comparison (there's usually one clear approach for simple changes)
- Separate design document file
- Visual Companion offer
- Spec self-review loop

**What you STILL do in Lite mode:**
- `frontend-design` / `ui-ux-pro-max` invocation — if the change involves ANY frontend/UI work, both skills must be used regardless of complexity. Even simple UI tweaks can fall into anti-patterns.
  - `frontend-design` is read in full (cheap, anti-default protection).
  - `ui-ux-pro-max` uses a lightweight single `--domain` search in Lite mode (not the full `--design-system`).

## Phase 2 Lite — Affected-Items-Only Confirmation

Instead of confirming all 5 items, only confirm items that are actually affected by the change. Mark unaffected items as **N/A** and skip them.

### How to Determine Affected Items

| Item | Affected When | Example of N/A |
|------|--------------|----------------|
| **Data Model** | New/modified tables, fields, constraints | Pure frontend change, no DB impact |
| **API Design** | New/modified endpoints, changed request/response format | No API changes |
| **Business Rules** | New logic, state changes, permissions | Simple UI tweak with no logic change |
| **Spec Impact** | Project spec documents need updating | No spec docs affected |
| **Testing Strategy** | Behaviors need verification | Always confirm — there's always something to test |

### Example: Pure Frontend UI Adjustment

```
Data Model: N/A (no database changes)
API Design: N/A (no API changes)
Business Rules: N/A (no logic changes, purely visual)
Spec Impact: N/A (no spec documents affected)
Testing Strategy: Verify visual rendering on 3 breakpoints (mobile, tablet, desktop)
```

### Example: Adding a Required Field Validation

```
Data Model: N/A (no schema change, field already exists)
API Design: N/A (same endpoint, added validation in existing middleware)
Business Rules: Email field is now required on signup form. Empty email → 400 error with existing error key.
Spec Impact: N/A
Testing Strategy: 1) Submit with empty email → see error. 2) Submit with valid email → success.
```

## Escalation from Lite to Standard

If during Lite mode you discover any of these, upgrade to 🟡 standard mode:

- The scope is bigger than initially assessed
- There are multiple valid approaches that need comparison
- The change affects more components than expected
- Security or performance implications emerge
- The user asks questions that reveal hidden complexity

Announce: "Scope has expanded beyond 🟢 simple. Upgrading to 🟡 standard — will proceed with full Phase 1/2 process."
