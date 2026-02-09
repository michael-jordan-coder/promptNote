import SwiftUI
import SwiftData

struct CreatePromptView: View {
    @StateObject private var viewModel = CreatePromptViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var contentAppeared = false

    var body: some View {
        VStack(spacing: 16) {
            // Grabber
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 36, height: 5)
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.top, 8)

            // Title
            TextField("Prompt Title", text: $viewModel.draftTitle)
                .font(.title3.bold())
                .textFieldStyle(.plain)

            // Content editor
            TextEditor(text: $viewModel.draftContent)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color(.clear), in: RoundedRectangle(cornerRadius: 8))

            // Save button
            SavePromptButton(
                canSave: viewModel.canSave,
                reduceMotion: reduceMotion
            ) {
                viewModel.save(in: modelContext)
                dismiss()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .background(.regularMaterial)
        .opacity(contentAppeared ? 1 : 0)
        .offset(y: contentAppeared ? 0 : 8)
        .onAppear {
            guard !contentAppeared else { return }
            withAnimation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.9).delay(0.15)) {
                contentAppeared = true
            }
        }
    }
}

// MARK: - Save Prompt Button
struct SavePromptButton: View {
    let canSave: Bool
    let reduceMotion: Bool
    let action: () -> Void

    @State private var isPressed = false

    private let pressAnim: Animation = .spring(response: 0.12, dampingFraction: 0.9)
    private let overshootAnim: Animation = .spring(response: 0.4, dampingFraction: 0.55)

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.body.weight(.semibold))

                Text("Save Prompt")
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background {
                Capsule()
                    .fill(canSave ? Color.accentColor : Color.secondary)
            }
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
        .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.96 : 1.0))
        .animation(reduceMotion ? .none : (isPressed ? pressAnim : overshootAnim), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed && canSave { isPressed = true }
                }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel("Save prompt")
    }
}

#Preview {
    CreatePromptView()
        .modelContainer(PromptNoteMockList.previewContainer)
}
