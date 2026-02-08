import Foundation

#if DEBUG
/// Aggregated mock prompts for previews and prototyping.
/// This file only composes data; no business logic.
enum PromptNoteMockList {
    /// All available mock notes in a stable, curated order.
    static let all: [PromptNote] = [
        .mockSystemSwiftUIEngineer,
        .mockSystemCodeReviewer,
        .mockSystemAPIArchitect,
        .mockSystemTechnicalWriter,
        .mockSystemDataAnalyst,
        .mockSystemProductCopy
    ]
}
#endif
