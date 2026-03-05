# CLAUDE.md — PromtSaver

> Living document. Update this file whenever files are added, removed, renamed, or architecture changes.

## Project Overview

**PromtSaver** is an iOS app for storing and managing prompt templates (system prompts, user requests, code snippets). Built with SwiftUI and MVVM.

- **Bundle ID**: `daniels.PromtSaver`
- **iOS Deployment Target**: 26.2
- **Swift Version**: 5.0
- **Team ID**: S37Z3294YB

## Architecture

**Pattern**: MVVM with SwiftData persistence

```
Persistence  → SwiftData @Model + ModelContainer (SQLite-backed, auto-save)
Model        → PromptNote (@Model class with timestamps + model context), AIModel (enum, Codable)
ViewModels   → ContentViewModel (list/search/delete), PromptNoteCardViewModel (card interaction), PromptNoteDetailViewModel (edit), CreatePromptViewModel (create)
Views        → ContentView (composition only), PromptNoteView (card presentation), DeleteConfirmationOverlay, AIModelBadge, detail & create sheets
Entry Point  → PromtSaverApp → ContentView
```

**Data flow**: `ModelContainer` (via `.modelContainer()`) → `ContentView` uses a recency-sorted `@Query` to fetch notes → delegates filtering + delete orchestration to `ContentViewModel` → passes `PromptNote` reference to `PromptNoteView` + `PromptNoteCardViewModel` for card interaction state → `PromptNoteDetailViewModel` stages edits and saves explicitly through `ModelContext` → `@Query` reactively updates the list.

**Draft isolation**: Create and detail flows hold `draftTitle`/`draftContent` plus staged model selection in view-model state. Drafts are only written back to the `@Model` object on explicit save — prevents per-keystroke disk writes and silent persistence on dismiss.

**Edit state machine**:
```
VIEWING (read-only title/model/content) → tap pencil → EDITING (draft title/model/content)
EDITING → tap checkmark → VIEWING (changes persisted via `ModelContext.save()`)
EDITING → tap cancel → VIEWING (draft changes discarded)
```

## File Map

```
PromtSaver/
├── App/
│   └── PromtSaverApp.swift          — App entry point, .modelContainer(for: PromptNote.self)
├── Models/
│   ├── PromptNote.swift              — @Model class (id, title, content, aiModel, createdAt, updatedAt), SwiftData-persisted
│   └── AIModel.swift                 — enum AIModel (chatgpt, claude, gemini, cursor), Codable, tap-to-cycle
├── ViewModels/
│   ├── ContentViewModel.swift        — List orchestration (search/filter, create sheet state, delete confirm flow, SwiftData delete)
│   ├── PromptNoteCardViewModel.swift — Card interaction state (tap presentation, staged appear animation, copy feedback task)
│   ├── PromptNoteDetailViewModel.swift — Explicit edit/save state machine, draft fields, save/discard actions
│   └── CreatePromptViewModel.swift   — Create flow drafts, validation, explicit insert + save via ModelContext
├── Views/
│   ├── ContentView.swift             — Root composition view, recency-sorted notes, search empty state, create sheet, delete overlay
│   ├── EmptyStateView.swift          — Minimal CTA screen when no notes exist
│   ├── CreatePromptView.swift        — Create sheet, AI model badge + title + content editor + explicit save/error handling
│   ├── AIModelBadge.swift            — Reusable circle badge, tappable (Binding) or read-only
│   ├── PromptNoteView.swift          — Card presentation, binds to PromptNoteCardViewModel for state and copy interactions
│   ├── DeleteConfirmationOverlay.swift — Centered modal overlay for destructive delete confirmation
│   └── PromptNoteDetailView.swift    — Modal sheet, explicit edit/cancel/save controls, staged model selection, CodeText ↔ TextEditor, copy pill
├── PreviewContent/
│   ├── PromptNote+Mocks.swift        — #if DEBUG mock data (6 pro markdown system prompts)
│   └── PromptNoteMockList.swift      — #if DEBUG mock aggregation + previewContainer
└── Assets.xcassets/
    ├── ai-chatgpt.imageset/          — OpenAI logo, light/dark appearances
    ├── ai-claude.imageset/           — Claude logo, light/dark appearances
    ├── ai-gemini.imageset/           — Gemini logo (gradient, single variant)
    └── ai-cursor.imageset/           — Cursor logo, light/dark appearances
```

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| [HighlightSwift](https://github.com/appstefan/HighlightSwift) | 1.0.9+ | Syntax highlighting via `CodeText` component |
| SwiftData | System framework | Persistence via `@Model`, `@Query`, `ModelContainer` |

## Key Patterns & Conventions

- **Threading**: `@MainActor` on all ViewModels; async work via managed `Task` (stored + cancelled on teardown)
- **Persistence**: SwiftData `@Model` + `ModelContainer`; create, edit, and delete flows call `ModelContext.save()` explicitly for predictable user-facing error handling
- **State management**: `@StateObject` in views, `@Published` in view models, `@Query` for data fetching
- **Mock data**: Always wrapped in `#if DEBUG`
- **UI**: Cards with rounded corners, monospaced fonts for code, `.regularMaterial` backgrounds, `.markdown` syntax highlight language
- **Copy feedback**: 1.2-second checkmark animation after copying to pasteboard
- **Library order**: Notes are sorted by `updatedAt` descending, then `createdAt` descending
- **HighlightSwift modifier order**: `CodeText`-specific modifiers (`.highlightLanguage()`) must come *before* SwiftUI view modifiers (`.font()`, `.textSelection()`) — SwiftUI modifiers erase the `CodeText` type to `some View`
- **Reduced motion**: All custom animations check `accessibilityReduceMotion` and fall back to `.none`

## Motion & Animation

Easing tokens (SwiftUI springs mapped from CSS motion guide):

| Token | SwiftUI | Use |
|---|---|---|
| Overshoot | `.spring(response: 0.35, dampingFraction: 0.6)` | Hover, emphasis, entrance |
| Ease-out | `.spring(response: 0.4, dampingFraction: 0.9)` | Settle, return to rest |
| Ease-in | `.spring(response: 0.15, dampingFraction: 0.9)` | Press, quick exit |

Interactions:

| Element | Animation |
|---|---|
| Card tap | Scale 0.96 while sheet open, overshoot spring back on dismiss |
| Card entrance | Staggered fade + slide up, 60ms delay per item, capped at 8 |
| Copy icon (card) | `.contentTransition(.symbolEffect(.replace))` + green color |
| Copy button (detail) | `CopyPromptButton` — pill, press squash 0.96, icon/text/color morph on success |
| Edit/save button | `pencil.circle` ↔ `checkmark.circle.fill` symbol morph with `.contentTransition` |
| Detail content | Fade in + slide up on appear with 150ms delay |
| Edit mode swap | CodeText ↔ TextEditor with `.opacity` transition, copy button slides out |
| Empty state | Fade in + slide up with overshoot spring, 100ms delay |
| Create sheet | Fade in + slide up content with ease-out spring, 150ms delay |
| Save button | Pill, press squash 0.96, disabled state grays out |

## Known Issues

1. ~~**Model missing fields** — `PromptNoteDetailViewModel` references `createdAt` / `updatedAt` not yet in `PromptNote`~~ **FIXED** — removed extra arguments from `rename(to:)` and `updateContent(_:)`
2. ~~**Property name mismatch** — `PromptNoteDetailView` uses `viewModel.copied` but ViewModel has `didCopy`~~ **FIXED** — renamed to `didCopy`, fixed `CodeHighlightLanguage` → `HighlightLanguage`, `.plain` → `.plaintext`, `let` title binding, `#Preview` macro
3. ~~**ContentView disconnected** — Still shows placeholder, not wired to prompt list~~ **FIXED** — wired to `PromptNoteMockList`, tap gesture on whole card
4. ~~**Title rename per-keystroke store updates** — `rename(to:)` called `store.update()` on every keystroke, causing unnecessary list re-renders~~ **FIXED** — decoupled to `draftTitle` binding, persisted only on save or sheet dismiss via `persistIfNeeded()`
5. ~~**Edit state not reset on dismiss** — swiping down during edit left stale `isEditing` state~~ **FIXED** — `onDisappear` calls `persistIfNeeded()` which resets editing and persists title
6. ~~**Dead code** — `PromptNoteViewModel.swift` unused after card simplification~~ **FIXED** — deleted
7. ~~**Unmanaged copy Task** — fire-and-forget Task kept ViewModel alive after dismiss~~ **FIXED** — stored as `copyTask`, cancelled on new copy or dismiss

## What's Not Yet Implemented

- Networking / API layer
- Unit tests
- Full test coverage for delete and search flows
- Accessibility beyond basic labels

## Git

- **Main branch**: `main`
- **Initial commit**: `ab4c67d`
