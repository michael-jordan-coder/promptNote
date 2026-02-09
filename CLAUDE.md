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
Model        → PromptNote (@Model class, Identifiable)
ViewModels   → PromptNoteDetailViewModel (edit), CreatePromptViewModel (create)
Views        → ContentView (empty state / list), PromptNoteView (card), detail & create sheets
Entry Point  → PromtSaverApp → ContentView
```

**Data flow**: `ModelContainer` (via `.modelContainer()`) → `ContentView` uses `@Query` to fetch notes → passes `PromptNote` reference to `PromptNoteView` → passes to `PromptNoteDetailView` → ViewModel mutates `@Model` properties directly on save → SwiftData auto-persists → `@Query` reactively updates list.

**Draft isolation**: ViewModel holds `draftTitle`/`draftContent` as separate `String` properties. Only written back to the `@Model` object on explicit save or dismiss — prevents per-keystroke disk writes.

**Edit state machine**:
```
VIEWING (pencil icon, CodeText) → tap edit → EDITING (checkmark icon, TextEditor)
EDITING → tap save → VIEWING (updated content persisted via SwiftData)
```

## File Map

```
PromtSaver/
├── App/
│   └── PromtSaverApp.swift          — App entry point, .modelContainer(for: PromptNote.self)
├── Models/
│   └── PromptNote.swift              — @Model class (id, title, content), SwiftData-persisted
├── ViewModels/
│   ├── PromptNoteDetailViewModel.swift — Edit/save state machine, draft fields, mutates @Model directly
│   └── CreatePromptViewModel.swift   — Create flow drafts, validation, insert via ModelContext
├── Views/
│   ├── ContentView.swift             — Root view, @Query, empty state vs note list, toolbar +, create sheet
│   ├── EmptyStateView.swift          — Minimal CTA screen when no notes exist
│   ├── CreatePromptView.swift        — Create sheet, title + content editor + save pill button
│   ├── PromptNoteView.swift          — Card UI, tap scale, staggered entrance, inline copy
│   └── PromptNoteDetailView.swift    — Modal sheet, edit/save toggle, CodeText ↔ TextEditor, copy pill
├── PreviewContent/
│   ├── PromptNote+Mocks.swift        — #if DEBUG mock data (6 pro markdown system prompts)
│   └── PromptNoteMockList.swift      — #if DEBUG mock aggregation + previewContainer
└── Assets.xcassets/
```

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| [HighlightSwift](https://github.com/appstefan/HighlightSwift) | 1.0.9+ | Syntax highlighting via `CodeText` component |
| SwiftData | System framework | Persistence via `@Model`, `@Query`, `ModelContainer` |

## Key Patterns & Conventions

- **Threading**: `@MainActor` on all ViewModels; async work via managed `Task` (stored + cancelled on teardown)
- **Persistence**: SwiftData `@Model` + `ModelContainer`, auto-save on property mutation; ViewModel draft pattern isolates edits until explicit save
- **State management**: `@StateObject` in views, `@Published` in view models, `@Query` for data fetching
- **Mock data**: Always wrapped in `#if DEBUG`
- **UI**: Cards with rounded corners, monospaced fonts for code, `.regularMaterial` backgrounds, `.markdown` syntax highlight language
- **Copy feedback**: 1.2-second checkmark animation after copying to pasteboard
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
- Error handling
- Search / filtering
- Delete prompts from UI
- Accessibility beyond basic labels

## Git

- **Main branch**: `main`
- **Initial commit**: `ab4c67d`
