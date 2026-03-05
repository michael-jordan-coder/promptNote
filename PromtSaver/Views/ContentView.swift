//
//  ContentView.swift
//  PromtSaver
//
//  Created by gur arye on 2/8/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @Query(
        sort: [
            SortDescriptor(\PromptNote.updatedAt, order: .reverse),
            SortDescriptor(\PromptNote.createdAt, order: .reverse)
        ]
    ) private var notes: [PromptNote]
    @FocusState private var isSearchFocused: Bool

    @Environment(\.modelContext) private var modelContext

    private var filteredNotes: [PromptNote] {
        viewModel.filteredNotes(from: notes)
    }

    private var deleteConfirmationPresented: Binding<Bool> {
        Binding(
            get: { viewModel.pendingDeleteNote != nil },
            set: { newValue in
                if !newValue {
                    viewModel.cancelDelete()
                }
            }
        )
    }

    private var deleteErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.deleteErrorMessage != nil },
            set: { newValue in
                if !newValue {
                    viewModel.deleteErrorMessage = nil
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    EmptyStateView {
                        viewModel.presentCreateSheet()
                    }
                } else if filteredNotes.isEmpty {
                    SearchEmptyStateView {
                        viewModel.searchText = ""
                        isSearchFocused = false
                    }
                } else {
                    noteList
                }
            }
            .navigationTitle("Prompts")
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search prompts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.presentCreateSheet()
                    } label: {
                        Label("New Prompt", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingCreateSheet) {
                CreatePromptView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.thickMaterial)
            }
            .confirmationDialog(
                "Delete Prompt?",
                isPresented: deleteConfirmationPresented,
                titleVisibility: .visible,
                presenting: viewModel.pendingDeleteNote
            ) { note in
                Button("Delete", role: .destructive) {
                    confirmDelete()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
            } message: { note in
                Text("Delete \"\(note.title)\"? This action cannot be undone.")
            }
            .alert("Delete Failed", isPresented: deleteErrorPresented) {
                Button("OK", role: .cancel) {
                    viewModel.deleteErrorMessage = nil
                }
            } message: {
                Text(viewModel.deleteErrorMessage ?? "Unable to delete this prompt right now.")
            }
        }
    }

    // MARK: - Note List
    private var noteList: some View {
        List {
            ForEach(Array(filteredNotes.enumerated()), id: \.element.id) { index, note in
                PromptNoteView(
                    note: note,
                    appearIndex: index,
                    onDeleteIntent: showDeleteConfirmation
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        showDeleteConfirmation(note)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func showDeleteConfirmation(_ note: PromptNote) {
        viewModel.requestDelete(note)
    }

    private func confirmDelete() {
        viewModel.confirmDelete(in: modelContext)
    }
}

private struct SearchEmptyStateView: View {
    let clearAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ContentUnavailableView(
                "No Matching Prompts",
                systemImage: "magnifyingglass",
                description: Text("Try a different keyword or clear your current search.")
            )

            Button("Clear Search", action: clearAction)
                .buttonStyle(.borderedProminent)
        }
        .padding(.bottom, 96)
    }
}



#Preview("Empty State") {
    ContentView()
        .modelContainer(for: PromptNote.self, inMemory: true)
}
