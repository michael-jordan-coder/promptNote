import SwiftUI
import Foundation
import Combine

@MainActor
final class PromptNoteDetailViewModel: ObservableObject {

    // MARK: - State
    @Published var note: PromptNote
    @Published var isEditing = false
    @Published var draftContent: String
    @Published var didCopy = false

    private let store: PromptNoteStore

    // MARK: - Init
    init(note: PromptNote, store: PromptNoteStore) {
        self.note = note
        self.draftContent = note.content
        self.store = store
    }

    // MARK: - Edit / Save

    func toggleEdit() {
        if isEditing {
            save()
        } else {
            draftContent = note.content
            isEditing = true
        }
    }

    private func save() {
        note = PromptNote(id: note.id, title: note.title, content: draftContent)
        store.update(note)
        isEditing = false
    }

    // MARK: - Title

    func rename(to newTitle: String) {
        note = PromptNote(id: note.id, title: newTitle, content: note.content)
        store.update(note)
    }

    // MARK: - Copy

    func copy() {
        UIPasteboard.general.string = note.content
        didCopy = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            didCopy = false
        }
    }
}
