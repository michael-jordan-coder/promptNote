import Foundation
import UIKit
import Combine

@MainActor
final class PromptNoteCardViewModel: ObservableObject {

    // MARK: - State
    @Published var isPresentingDetail = false
    @Published private(set) var appeared = false
    @Published private(set) var didCopy = false

    private var copyTask: Task<Void, Never>?

    // MARK: - Interaction

    func presentDetail() {
        isPresentingDetail = true
    }

    func markAppeared() {
        appeared = true
    }

    func appearanceDelay(for index: Int, reduceMotion: Bool) -> Double {
        reduceMotion ? 0 : Double(min(index, 8)) * 0.06
    }

    func copy(content: String) {
        UIPasteboard.general.string = content
        didCopy = true

        copyTask?.cancel()
        copyTask = Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            didCopy = false
        }
    }

    func cleanup() {
        copyTask?.cancel()
        copyTask = nil
    }

    deinit {
        copyTask?.cancel()
    }
}
