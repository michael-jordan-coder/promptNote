import Foundation

enum AIModel: String, Codable, CaseIterable {
    case chatgpt
    case claude
    case gemini
    case cursor

    var displayName: String {
        switch self {
        case .chatgpt: "ChatGPT"
        case .claude:  "Claude"
        case .gemini:  "Gemini"
        case .cursor:  "Cursor"
        }
    }

    var iconName: String {
        switch self {
        case .chatgpt: "ai-chatgpt"
        case .claude:  "ai-claude"
        case .gemini:  "ai-gemini"
        case .cursor:  "ai-cursor"
        }
    }
}
