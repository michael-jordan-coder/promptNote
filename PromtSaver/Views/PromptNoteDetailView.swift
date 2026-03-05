import SwiftUI
import HighlightSwift
import SwiftData

struct PromptNoteDetailView: View {
    @StateObject private var viewModel: PromptNoteDetailViewModel
    @State private var contentAppeared = false
    @State private var saveErrorMessage: String?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.modelContext) private var modelContext

    init(note: PromptNote) {
        _viewModel = StateObject(wrappedValue: PromptNoteDetailViewModel(note: note))
    }

    var body: some View {
        VStack(spacing: 16) {
            // Grabber
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 36, height: 5)
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.top, 8)

            // Header
            HStack {
                if viewModel.isEditing {
                    AIModelBadge(model: $viewModel.draftModel)
                } else {
                    AIModelBadge(model: viewModel.note.aiModel)
                }

                TextField("Title", text: $viewModel.draftTitle)
                    .font(.title3.bold())
                    .textFieldStyle(.plain)
                    .disabled(!viewModel.isEditing)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                Spacer(minLength: 12)

                if viewModel.isEditing {
                    Button {
                        withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8)) {
                            viewModel.discardEdits()
                        }
                    } label: {
                        Image(systemName: "xmark.circle")
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                    Button {
                        saveEdits()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(viewModel.canSave ? .green : .secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canSave)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Button {
                        withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.6)) {
                            viewModel.beginEditing()
                        }
                    } label: {
                        Image(systemName: "pencil.circle")
                            .imageScale(.large)
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }

            // Content — swap between read-only and editable
            if viewModel.isEditing {
                TextEditor(text: $viewModel.draftContent)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .transition(.opacity)
            } else {
                ScrollView(.vertical) {
                    CodeText(viewModel.note.content)
                        .highlightLanguage(.markdown)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(contentAppeared ? 1 : 0)
                        .offset(y: contentAppeared ? 0 : 8)
                        .id(viewModel.note.content)
                }
                .transition(.opacity)
                .onAppear {
                    guard !contentAppeared else { return }
                    withAnimation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.9).delay(0.15)) {
                        contentAppeared = true
                    }
                }
            }

            // Copy button — hidden during editing
            if !viewModel.isEditing {
                CopyPromptButton(didCopy: viewModel.didCopy, reduceMotion: reduceMotion) {
                    viewModel.copy()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .background(.regularMaterial)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .animation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8), value: viewModel.isEditing)
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
        .onDisappear {
            viewModel.cleanup()
        }
        .alert("Save Failed", isPresented: saveErrorPresented) {
            Button("OK", role: .cancel) {
                saveErrorMessage = nil
            }
        } message: {
            Text(saveErrorMessage ?? "Unable to save changes right now.")
        }
    }

    private var saveErrorPresented: Binding<Bool> {
        Binding(
            get: { saveErrorMessage != nil },
            set: { newValue in
                if !newValue {
                    saveErrorMessage = nil
                }
            }
        )
    }

    private func saveEdits() {
        do {
            try viewModel.save(in: modelContext)
        } catch {
            modelContext.rollback()
            saveErrorMessage = "Couldn't save changes to this prompt. \(error.localizedDescription)"
        }
    }
}

// MARK: - Copy Prompt Button
struct CopyPromptButton: View {
    let didCopy: Bool
    let reduceMotion: Bool
    let action: () -> Void

    @State private var isPressed = false

    private let pressAnim: Animation = .spring(response: 0.12, dampingFraction: 0.9)
    private let overshootAnim: Animation = .spring(response: 0.4, dampingFraction: 0.55)
    private let settleAnim: Animation = .spring(response: 0.5, dampingFraction: 0.8)

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                    .contentTransition(.symbolEffect(.replace.offUp))
                    .font(.body.weight(.semibold))

                Text(didCopy ? "Copied" : "Copy Prompt")
                    .contentTransition(.numericText())
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background {
                Capsule()
                    .fill(didCopy ? Color.green : Color.accentColor)
                    .animation(reduceMotion ? .none : settleAnim, value: didCopy)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.96 : 1.0))
        .animation(reduceMotion ? .none : (isPressed ? pressAnim : overshootAnim), value: isPressed)
        .animation(reduceMotion ? .none : overshootAnim, value: didCopy)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { isPressed = true }
                }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel("Copy content")
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showingSheet = true
        var body: some View {
            Color.clear
                .sheet(isPresented: $showingSheet) {
                    PromptNoteDetailView(
                        note: .mockSystemSwiftUIEngineer
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
        }
    }
    return PreviewWrapper()
        .modelContainer(PromptNoteMockList.previewContainer)
}

// Extension for corner radius on specific corners
fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
