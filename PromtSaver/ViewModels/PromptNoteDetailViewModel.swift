import SwiftUI
import Foundation
import Combine

@MainActor
final class PromptNoteDetailViewModel: ObservableObject {

    // MARK: - State
    let note: PromptNote
    @Published var isEditing = false
    @Published var draftContent: String
    @Published var draftTitle: String
    @Published var didCopy = false

    private var copyTask: Task<Void, Never>?

    // MARK: - Init
    init(note: PromptNote) {
        self.note = note
        self.draftContent = note.content
        self.draftTitle = note.title
    }

    // MARK: - Edit / Save

    func toggleEdit() {
        if isEditing {
            save()
        } else {
            draftContent = note.content
            draftTitle = note.title
            isEditing = true
        }
    }

    private func save() {
        note.title = draftTitle
        note.content = draftContent
        isEditing = false
    }

    /// Persist title change on sheet dismiss (title is always editable).
    func persistIfNeeded() {
        if isEditing {
            isEditing = false
        }
        if draftTitle != note.title {
            note.title = draftTitle
        }
        copyTask?.cancel()
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
}
