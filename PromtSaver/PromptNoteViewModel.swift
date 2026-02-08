//
//  PromptNoteViewModel.swift
//  PromtSaver
//
//  Created by gur arye on 2/8/26.
//


import Foundation
import SwiftUI
import Combine

@MainActor
final class PromptNoteViewModel: ObservableObject {

    // MARK: - Model
    let note: PromptNote

    // MARK: - UI State
    @Published private(set) var didCopy: Bool = false

    // MARK: - Init
    init(note: PromptNote) {
        self.note = note
    }

    // MARK: - Actions
    func copy() {
        UIPasteboard.general.string = note.content
        didCopy = true

        resetCopyState()
    }

    // MARK: - Private
    private func resetCopyState() {
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            didCopy = false
        }
    }
}
