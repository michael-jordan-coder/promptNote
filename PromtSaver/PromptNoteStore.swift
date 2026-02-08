import SwiftUI

@MainActor @Observable
final class PromptNoteStore {
    var notes: [PromptNote]

    init(notes: [PromptNote] = []) {
        self.notes = notes
    }

    func update(_ note: PromptNote) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index] = note
    }
}
