# PromtSaver Case Study
## Product Designer (Apple-Focused Portfolio Version)

## Project summary
PromtSaver is an iOS app I designed and built to help people save, refine, and quickly reuse AI prompts.  
This case study is framed for an Apple Product Designer audience: clarity, craft, system thinking, accessibility, and privacy-first product decisions.

## Role and scope
- Role: Product Designer + Product Developer
- Timeline: 0 to 1 MVP
- Platform: iOS (SwiftUI + SwiftData)
- Ownership: Product strategy, interaction design, visual design, prototyping, implementation

## The problem
AI users repeatedly lose high-value prompts inside chat histories and notes apps. The result is fragmented workflows and inconsistent quality.

Primary user pain:
1. Re-finding prompts is slow during task switching.
2. Rewriting prompts causes quality drift.
3. Existing tools are not optimized for fast, repeatable prompt workflows on mobile.

## Product intent
Design a focused, local-first iOS experience that makes prompt reuse feel immediate and dependable.

Success criteria:
1. Create and retrieve prompts in seconds.
2. Preserve prompt readability for long, structured text.
3. Support iterative refinement without friction.
4. Maintain Apple-level expectations for accessibility and motion restraint.

## Design principles
1. Reduce cognitive load: one clear primary action per context.
2. Respect content: prompts are treated like valuable working artifacts.
3. Build trust: safe destructive actions and predictable behavior.
4. Prefer calm motion: communicate hierarchy and state, never decoration.
5. Accessibility by default: Reduce Motion support and clear touch targets.

## Experience design

### 1) Core flows
1. Capture: create a prompt with title, content, and model context.
2. Review: scan cards with monospaced, syntax-highlighted previews.
3. Retrieve: search by title or content from a persistent bottom control.
4. Refine: open detail view, edit inline, persist on confirm/dismiss.
5. Reuse: copy with immediate visual confirmation.

### 2) Information architecture
- Prompt as core entity: `id`, `title`, `content`, `aiModel`.
- Model context options: ChatGPT, Claude, Gemini, Cursor.
- Why: a minimal schema that still supports fast filtering and future scale (tags/folders/smart collections).

### 3) Visual and interaction system
- Card layout prioritizes legibility and scanning.
- AI model badge communicates context with compact iconography.
- Bottom search/create surface acts as a high-frequency command area.
- Confirmation overlay for delete prevents accidental data loss.
- Material and spring motion are used with restraint to preserve focus.

## Apple-relevant craft decisions
1. Motion respects `accessibilityReduceMotion`; transitions degrade to static when needed.
2. Edit states are explicit and reversible to avoid accidental mutation.
3. Copy feedback is immediate and temporal, not modal.
4. Destructive actions require confirmation and error handling.
5. Local-first persistence reduces privacy risk and keeps performance reliable.

## Technical design (supporting product quality)
- Architecture: MVVM
- Persistence: SwiftData (`@Model`, `@Query`, `ModelContainer`)
- ViewModel ownership by flow:
  - `ContentViewModel`: search, create sheet, delete confirmation lifecycle
  - `CreatePromptViewModel`: input draft and save validation
  - `PromptNoteCardViewModel`: card-level feedback and copy interaction
  - `PromptNoteDetailViewModel`: edit state, draft isolation, persistence

Implementation choices that protect UX quality:
1. Draft isolation prevents noisy per-keystroke persistence behavior.
2. Reactive `@Query` list updates keep state and UI aligned.
3. Task cancellation for transient copy feedback avoids stale state.
4. Rollback path on delete failure preserves data integrity.

## Outcome
PromtSaver delivers a complete local prompt workflow on iOS:
1. Create, browse, search, edit, copy, and delete in one focused loop.
2. Faster retrieval through searchable, model-contextualized notes.
3. Better readability than generic note tools for structured prompt content.

## Metrics I would use in production
1. Activation: first prompt saved in first session.
2. Time-to-value: median time from app open to copy action.
3. Retention: D7 and D30 users with repeated copy behavior.
4. Quality signal: percentage of prompts edited after initial save.

## Next iteration roadmap
1. Smart organization: tags, folders, and model-based filters.
2. Cross-device continuity: iCloud sync and export/import pathways.
3. Accessibility depth: VoiceOver ordering and Dynamic Type edge-case layouts.
4. Validation: usability studies focused on retrieval speed and edit confidence.
5. Reliability: expanded unit/UI tests across search, edit, and delete flows.

## Why this is relevant for Apple Product Design
This project demonstrates end-to-end product thinking grounded in execution: identifying a focused user problem, shaping a clear interaction model, crafting a high-signal interface, and implementing with attention to accessibility, motion discipline, and trust.

## Key implementation references
- `/Users/daniel/Documents/PromtSaver/PromtSaver/Views/ContentView.swift`
- `/Users/daniel/Documents/PromtSaver/PromtSaver/Views/CreatePromptView.swift`
- `/Users/daniel/Documents/PromtSaver/PromtSaver/Views/PromptNoteView.swift`
- `/Users/daniel/Documents/PromtSaver/PromtSaver/Views/PromptNoteDetailView.swift`
- `/Users/daniel/Documents/PromtSaver/PromtSaver/ViewModels/ContentViewModel.swift`
