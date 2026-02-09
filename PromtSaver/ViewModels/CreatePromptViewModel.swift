import SwiftUI
import SwiftData
import Combine

@MainActor
final class CreatePromptViewModel: ObservableObject {

    // MARK: - State
    @Published var draftTitle: String = ""
    @Published var draftContent: String = ""
    @Published var selectedModel: AIModel = .claude

    var canSave: Bool {
        !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions

    func save(in context: ModelContext) {
        let note = PromptNote(
            title: draftTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            content: draftContent,
            aiModel: selectedModel
        )
        context.insert(note)
    }
}
