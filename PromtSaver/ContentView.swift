//
//  ContentView.swift
//  PromtSaver
//
//  Created by gur arye on 2/8/26.
//

import SwiftUI

struct ContentView: View {
    private let notes = PromptNoteMockList.all

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(notes.enumerated()), id: \.element.id) { index, note in
                    PromptNoteView(note: note, appearIndex: index)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    ContentView()
}
