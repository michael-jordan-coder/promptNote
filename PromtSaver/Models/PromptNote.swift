import SwiftUI
import SwiftData

@Model
final class PromptNote {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var aiModelRaw: String = "claude"

    var aiModel: AIModel {
        get { AIModel(rawValue: aiModelRaw) ?? .claude }
        set { aiModelRaw = newValue.rawValue }
    }

    init(id: UUID = UUID(), title: String, content: String, aiModel: AIModel = .claude) {
        self.id = id
        self.title = title
        self.content = content
        self.aiModelRaw = aiModel.rawValue
    }
}
