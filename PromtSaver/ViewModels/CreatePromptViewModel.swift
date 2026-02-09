import SwiftUI
import SwiftData
import Combine

@MainActor
final class CreatePromptViewModel: ObservableObject {

    // MARK: - State
    @Published var draftTitle: String = ""
    @Published var draftContent: String = ""

    var canSave: Bool {
        !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions

    func save(in context: ModelContext) {
        let note = PromptNote(
            title: draftTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            content: draftContent
        )
        context.insert(note)
    }
}
