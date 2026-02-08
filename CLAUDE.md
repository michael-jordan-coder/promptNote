# CLAUDE.md — PromtSaver

> Living document. Update this file whenever files are added, removed, renamed, or architecture changes.

## Project Overview

**PromtSaver** is an iOS app for storing and managing prompt templates (system prompts, user requests, code snippets). Built with SwiftUI and MVVM.

- **Bundle ID**: `daniels.PromtSaver`
- **iOS Deployment Target**: 26.2
- **Swift Version**: 5.0
- **Team ID**: S37Z3294YB

## Architecture

**Pattern**: MVVM (Model-View-ViewModel)

```
Model        → PromptNote (value type, Identifiable + Equatable)
ViewModels   → PromptNoteViewModel (list item), PromptNoteDetailViewModel (detail/edit)
Views        → PromptNoteView (card), PromptNoteDetailView (modal sheet)
Entry Point  → PromtSaverApp → ContentView
```

All ViewModels use `@MainActor` isolation and `@Published` properties for reactive UI updates.

## File Map

| File | Purpose |
|---|---|
| `PromtSaverApp.swift` | App entry point, `WindowGroup` bootstrap |
| `ContentView.swift` | Root view — prompt list with staggered entrance |
| `PromptNote.swift` | Core data model — `id`, `title`, `content` |
| `PromptNoteViewModel.swift` | List item logic — copy to pasteboard, feedback state |
| `PromptNoteView.swift` | Card UI — press squash, staggered entrance, icon morph on copy |
| `PromptNoteDetailViewModel.swift` | Detail logic — copy, rename, update content |
| `PromptNoteDetailView.swift` | Modal sheet — editable title, content fade-in, copy button with press/success animation |
| `PromptNote+Mocks.swift` | `#if DEBUG` mock data (6 sample prompts) |
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
| Card tap | `CardPressStyle` — scale 0.96 on press, overshoot spring back |
| Card entrance | Staggered fade + slide up, 60ms delay per item, capped at 8 |
| Copy icon (card) | `.contentTransition(.symbolEffect(.replace))` + green color |
| Copy button (detail) | `CopyButtonStyle` — squash 0.97 on press, scale bump 1.05 on success, green bg |
| Detail content | Fade in + slide up on appear with 150ms delay |

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
