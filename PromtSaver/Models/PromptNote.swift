import SwiftUI
import SwiftData

@Model
final class PromptNote {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var aiModelRaw: String = "claude"
    var createdAt: Date
    var updatedAt: Date

    var aiModel: AIModel {
        get { AIModel(rawValue: aiModelRaw) ?? .claude }
        set { aiModelRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        aiModel: AIModel = .claude,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.aiModelRaw = aiModel.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func touch(date: Date = .now) {
        updatedAt = date
    }

    static func resolvedTitle(draftTitle: String, content: String) -> String {
        let trimmedTitle = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.isEmpty else { return trimmedTitle }

        return content
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .joined(separator: " ")
    }
}
