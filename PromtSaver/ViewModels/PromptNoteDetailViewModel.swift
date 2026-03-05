import SwiftUI
import Foundation
import SwiftData
import Combine

@MainActor
final class PromptNoteDetailViewModel: ObservableObject {

    // MARK: - State
    let note: PromptNote
    @Published var isEditing = false
    @Published var draftContent: String
    @Published var draftTitle: String
    @Published var draftModel: AIModel
    @Published var didCopy = false

    private var copyTask: Task<Void, Never>?

    // MARK: - Init
    init(note: PromptNote) {
        self.note = note
        self.draftContent = note.content
        self.draftTitle = note.title
        self.draftModel = note.aiModel
    }

    var canSave: Bool {
        !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasUnsavedChanges: Bool {
        draftTitle != note.title ||
        draftContent != note.content ||
        draftModel != note.aiModel
    }

    // MARK: - Edit / Save

    func beginEditing() {
        restoreDraftsFromNote()
        isEditing = true
    }

    func discardEdits() {
        restoreDraftsFromNote()
        isEditing = false
    }

    func save(in context: ModelContext) throws {
        note.title = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        note.content = draftContent
        note.aiModel = draftModel
        note.touch()
        try context.save()
        isEditing = false
    }

    // MARK: - Copy

    func copy() {
        UIPasteboard.general.string = note.content
        didCopy = true
        copyTask?.cancel()
        copyTask = Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            didCopy = false
        }
    }

    func cleanup() {
        copyTask?.cancel()
        copyTask = nil
    }

    // MARK: - Private

    private func restoreDraftsFromNote() {
        draftTitle = note.title
        draftContent = note.content
        draftModel = note.aiModel
    }
}
