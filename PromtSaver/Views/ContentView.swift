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
    @Query private var notes: [PromptNote]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var filteredNotes: [PromptNote] {
        viewModel.filteredNotes(from: notes)
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

    private var overlayAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.86)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if notes.isEmpty {
                        EmptyStateView {
                            viewModel.presentCreateSheet()
                        }
                    } else {
                        noteList
                    }
                }
                .allowsHitTesting(!viewModel.isDeleteConfirmationVisible)
                .overlay(alignment: .bottom) {
                    if !notes.isEmpty {
                        bottomSearchBar
                    }
                }
                .sheet(isPresented: $viewModel.isShowingCreateSheet) {
                    CreatePromptView()
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }

                if let pendingDeleteNote = viewModel.pendingDeleteNote, viewModel.isDeleteConfirmationVisible {
                    DeleteConfirmationOverlay(
                        noteTitle: pendingDeleteNote.title,
                        onCancel: hideDeleteConfirmation,
                        onConfirm: confirmDelete
                    )
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .opacity.combined(with: .scale(scale: 0.98))
                    )
                    .zIndex(1)
                }
            }
            .animation(
                overlayAnimation,
                value: viewModel.isDeleteConfirmationVisible
            )
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
        .padding(.bottom, 64)
    }

    // MARK: - Bottom Search Bar
    private var bottomSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search prompts...", text: $viewModel.searchText)
                .textFieldStyle(.plain)

            Button {
                viewModel.presentCreateSheet()
            } label: {
                Image(systemName: "plus")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.accentColor))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: Capsule())
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func showDeleteConfirmation(_ note: PromptNote) {
        withAnimation(overlayAnimation) {
            viewModel.requestDelete(note)
        }
    }

    private func hideDeleteConfirmation() {
        withAnimation(overlayAnimation) {
            viewModel.cancelDelete()
        }
    }

    private func confirmDelete() {
        withAnimation(overlayAnimation) {
            viewModel.confirmDelete(in: modelContext)
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
