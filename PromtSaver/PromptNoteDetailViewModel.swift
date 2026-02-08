import SwiftUI
import Foundation
import Combine

/// View model for managing the state and actions of a prompt note detail sheet.
@MainActor
final class PromptNoteDetailViewModel: ObservableObject {
    /// The prompt note being displayed and edited.
    @Published var note: PromptNote
    
    /// Indicates whether the note's content was recently copied to the pasteboard.
    @Published var didCopy = false
    
    /// Creates a new view model for the given prompt note.
    /// - Parameter note: The prompt note to manage.
    init(note: PromptNote) {
        self.note = note
    }
    
    /// Copies the note's content to the system pasteboard, with a brief copy feedback.
    func copy() {
        UIPasteboard.general.string = note.content
        didCopy = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            didCopy = false
        }
    }
    
    /// Renames the note by updating its title.
    /// - Parameter newTitle: The new title for the note.
    func rename(to newTitle: String) {
        // If `PromptNote` uses `let` properties, replace the whole value instead of mutating fields.
        note = PromptNote(id: note.id, title: newTitle, content: note.content)
    }
    
    /// Updates the content of the note.
    /// - Parameter newContent: The new content for the note.
    func updateContent(_ newContent: String) {
        // If `PromptNote` uses `let` properties, replace the whole value instead of mutating fields.
        note = PromptNote(id: note.id, title: note.title, content: newContent)
    }
}

