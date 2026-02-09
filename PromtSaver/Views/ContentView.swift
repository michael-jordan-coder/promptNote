//
//  ContentView.swift
//  PromtSaver
//
//  Created by gur arye on 2/8/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var notes: [PromptNote]
    @State private var isShowingCreateSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    EmptyStateView {
                        isShowingCreateSheet = true
                    }
                } else {
                    noteList
                }
            }
            .toolbar {
                if !notes.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingCreateSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateSheet) {
                CreatePromptView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Note List
    private var noteList: some View {
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

#Preview("With Notes") {
    ContentView()
        .modelContainer(PromptNoteMockList.previewContainer)
}

#Preview("Empty State") {
    ContentView()
        .modelContainer(for: PromptNote.self, inMemory: true)
}
