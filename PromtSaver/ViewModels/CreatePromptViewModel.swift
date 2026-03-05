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
        !resolvedTitle.isEmpty
    }

    // MARK: - Actions

    func save(in context: ModelContext) throws {
        let note = PromptNote(
            title: resolvedTitle,
            content: draftContent,
            aiModel: selectedModel
        )
        context.insert(note)
        try context.save()
    }

    private var resolvedTitle: String {
        PromptNote.resolvedTitle(draftTitle: draftTitle, content: draftContent)
    }
}
