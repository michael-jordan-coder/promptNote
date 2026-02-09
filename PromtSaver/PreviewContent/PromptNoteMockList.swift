import Foundation
import SwiftData

#if DEBUG
/// Aggregated mock prompts for previews and prototyping.
/// This file only composes data; no business logic.
enum PromptNoteMockList {
    /// All available mock notes — returns fresh instances each time.
    static var all: [PromptNote] {
        [
            .mockSystemSwiftUIEngineer,
            .mockSystemCodeReviewer,
            .mockSystemAPIArchitect,
            .mockSystemTechnicalWriter,
            .mockSystemDataAnalyst,
            .mockSystemProductCopy
        ]
    }

    /// In-memory ModelContainer pre-populated with mock data for #Preview blocks.
    @MainActor
    static var previewContainer: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: PromptNote.self, configurations: config)
        for note in all {
            container.mainContext.insert(note)
        }
        return container
    }
}
#endif
