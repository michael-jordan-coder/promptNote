import Foundation
import SwiftData
import Combine

@MainActor
final class ContentViewModel: ObservableObject {

    // MARK: - State
    @Published var isShowingCreateSheet = false
    @Published var searchText = ""
    @Published private(set) var pendingDeleteNote: PromptNote?
    @Published var deleteErrorMessage: String?

    // MARK: - Query Helpers

    func filteredNotes(from notes: [PromptNote]) -> [PromptNote] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return notes }

        return notes.filter {
            $0.title.lowercased().contains(query) ||
            $0.content.lowercased().contains(query)
        }
    }

    // MARK: - Sheet Actions

    func presentCreateSheet() {
        isShowingCreateSheet = true
    }

    // MARK: - Delete Flow

    func requestDelete(_ note: PromptNote) {
        pendingDeleteNote = note
    }

    func cancelDelete() {
        clearDeleteState()
    }

    func confirmDelete(in modelContext: ModelContext) {
        guard let note = pendingDeleteNote else { return }

        modelContext.delete(note)
        do {
            try modelContext.save()
            clearDeleteState()
        } catch {
            modelContext.rollback()
            clearDeleteState()
            deleteErrorMessage = "Couldn't delete \"\(note.title)\". \(error.localizedDescription)"
        }
    }

    // MARK: - Private

    private func clearDeleteState() {
        pendingDeleteNote = nil
    }
}
