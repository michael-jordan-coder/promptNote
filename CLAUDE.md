# CLAUDE.md — PromtSaver

> Living document. Update this file whenever files are added, removed, renamed, or architecture changes.

## Project Overview

**PromtSaver** is an iOS app for storing and managing prompt templates (system prompts, user requests, code snippets). Built with SwiftUI and MVVM.

- **Bundle ID**: `daniels.PromtSaver`
- **iOS Deployment Target**: 26.2
- **Swift Version**: 5.0
- **Team ID**: S37Z3294YB

## Architecture

**Pattern**: MVVM with shared `@Observable` store

```
Store        → PromptNoteStore (@Observable, source of truth, injected via .environment)
Model        → PromptNote (value type, Identifiable + Equatable)
ViewModels   → PromptNoteDetailViewModel (detail/edit with edit state machine)
Views        → PromptNoteView (card), PromptNoteDetailView (modal sheet)
Entry Point  → PromtSaverApp → ContentView
```

**Data flow**: `PromptNoteStore` → environment → `ContentView` reads `store.notes` → passes `note` to `PromptNoteView` → passes `note` + `store` to `PromptNoteDetailView` → ViewModel calls `store.update()` on save → reactive update back to list.

**Edit state machine**:
```
VIEWING (pencil icon, CodeText) → tap edit → EDITING (checkmark icon, TextEditor)
EDITING → tap save → VIEWING (updated content persisted to store)
```

## File Map

| File | Purpose |
|---|---|
| `PromtSaverApp.swift` | App entry point — creates `PromptNoteStore`, injects via `.environment()` |
| `ContentView.swift` | Root view — reads `store.notes`, staggered list entrance |
| `PromptNote.swift` | Core data model — `id`, `title`, `content` |
| `PromptNoteStore.swift` | `@Observable` shared store — source of truth, `update()` method |
| `PromptNoteView.swift` | Card UI — tap scale, staggered entrance, inline copy |
| `PromptNoteDetailViewModel.swift` | Detail logic — edit/save state machine, copy, rename, persists to store |
| `PromptNoteDetailView.swift` | Modal sheet — edit/save toggle, CodeText ↔ TextEditor swap, copy pill button |
| `PromptNoteViewModel.swift` | **(unused)** — legacy list item ViewModel, kept for reference |
| `PromptNote+Mocks.swift` | `#if DEBUG` mock data (6 pro markdown system prompts) |
| `PromptNoteMockList.swift` | `#if DEBUG` aggregation of all mocks |

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| [HighlightSwift](https://github.com/appstefan/HighlightSwift) | 1.0.9+ | Syntax highlighting via `CodeText` component |

## Key Patterns & Conventions

- **Threading**: `@MainActor` on all ViewModels; async work via `Task.sleep(nanoseconds:)`
- **State management**: `@StateObject` in views, `@Published` in view models
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

## Known Issues

1. ~~**Model missing fields** — `PromptNoteDetailViewModel` references `createdAt` / `updatedAt` not yet in `PromptNote`~~ **FIXED** — removed extra arguments from `rename(to:)` and `updateContent(_:)`
2. ~~**Property name mismatch** — `PromptNoteDetailView` uses `viewModel.copied` but ViewModel has `didCopy`~~ **FIXED** — renamed to `didCopy`, fixed `CodeHighlightLanguage` → `HighlightLanguage`, `.plain` → `.plaintext`, `let` title binding, `#Preview` macro
3. ~~**ContentView disconnected** — Still shows placeholder, not wired to prompt list~~ **FIXED** — wired to `PromptNoteMockList`, tap gesture on whole card

## What's Not Yet Implemented

- Data persistence (no Core Data / SwiftData / file storage)
- Networking / API layer
- Unit tests
- Error handling
- Search / filtering
- Create / delete prompts from UI
- Accessibility beyond basic labels

## Git

- **Main branch**: `main`
- **Initial commit**: `ab4c67d`
