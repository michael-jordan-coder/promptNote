import SwiftUI
import SwiftData

struct CreatePromptView: View {
    @StateObject private var viewModel = CreatePromptViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var contentAppeared = false
    @State private var saveErrorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            // Grabber
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 36, height: 5)
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.top, 8)

            // Title
            HStack{
                AIModelBadge(model: $viewModel.selectedModel)

                TextField("Prompt Title", text: $viewModel.draftTitle)
                    .font(.title.bold())
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            // Content editor
            ZStack(alignment: .topLeading) {
                if viewModel.draftContent.isEmpty {
                    Text("Write your prompt here...")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding(.top, 10)
                        .padding(.leading, 5)
                }
                TextEditor(text: $viewModel.draftContent)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            .padding(8)
            .background(Color(.clear), in: RoundedRectangle(cornerRadius: 8))

            // Save button
            SavePromptButton(
                canSave: viewModel.canSave,
                reduceMotion: reduceMotion
            ) {
                savePrompt()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .opacity(contentAppeared ? 1 : 0)
        .offset(y: contentAppeared ? 0 : 8)
        .onAppear {
            guard !contentAppeared else { return }
            withAnimation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.9).delay(0.15)) {
                contentAppeared = true
            }
        }
        .alert("Save Failed", isPresented: saveErrorPresented) {
            Button("OK", role: .cancel) {
                saveErrorMessage = nil
            }
        } message: {
            Text(saveErrorMessage ?? "Unable to save this prompt right now.")
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

    private func savePrompt() {
        do {
            try viewModel.save(in: modelContext)
            dismiss()
        } catch {
            modelContext.rollback()
            saveErrorMessage = "Couldn't save this prompt. \(error.localizedDescription)"
        }
    }
}

// MARK: - Save Prompt Button
struct SavePromptButton: View {
    let canSave: Bool
    let reduceMotion: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Text("Save Prompt")
                    .font(.body.weight(.semibold))
                Image(systemName: "bookmark.fill")
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background {
                Capsule()
                    .fill(canSave ? Color.accentColor : Color.secondary)
            }
        }
        .buttonStyle(SavePromptButtonStyle(reduceMotion: reduceMotion))
        .disabled(!canSave)
        .accessibilityLabel("Save prompt")
    }
}

private struct SavePromptButtonStyle: ButtonStyle {
    let reduceMotion: Bool

    private let pressAnim: Animation = .spring(response: 0.12, dampingFraction: 0.9)
    private let overshootAnim: Animation = .spring(response: 0.4, dampingFraction: 0.55)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1.0 : (configuration.isPressed ? 0.96 : 1.0))
            .animation(
                reduceMotion ? .none : (configuration.isPressed ? pressAnim : overshootAnim),
                value: configuration.isPressed
            )
    }
}

#Preview {
    CreatePromptView()
        .modelContainer(PromptNoteMockList.previewContainer)
}
