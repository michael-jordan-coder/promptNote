import SwiftUI
import HighlightSwift

struct PromptNoteDetailView: View {
    @StateObject private var viewModel: PromptNoteDetailViewModel
    @State private var contentAppeared = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                TextField("Title", text: Binding(
                    get: { viewModel.note.title },
                    set: { viewModel.rename(to: $0) }
                ))
                    .font(.title3.bold())
                    .textFieldStyle(.plain)

            }

            ScrollView(.vertical) {
                CodeText(viewModel.note.content)
                    .highlightLanguage(.markdown)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 8)
            }
            .onAppear {
                guard !contentAppeared else { return }
                withAnimation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.9).delay(0.15)) {
                    contentAppeared = true
                }
            }

            Button {
                viewModel.copy()
            } label: {
                Label(viewModel.didCopy ? "Copied" : "Copy Prompt",
                      systemImage: viewModel.didCopy ? "checkmark.circle.fill" : "doc.on.doc")
                    .frame(maxWidth: .infinity)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(CopyButtonStyle(didCopy: viewModel.didCopy, reduceMotion: reduceMotion))
            .controlSize(.large)
            .accessibilityLabel("Copy content")
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .background(.regularMaterial)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

// MARK: - Copy Button Style
/// Prominent button with press squash and success scale bump.
struct CopyButtonStyle: ButtonStyle {
    let didCopy: Bool
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .background(didCopy ? Color.green : Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
            .scaleEffect(scaleValue(isPressed: configuration.isPressed))
            .animation(
                reduceMotion ? .none :
                configuration.isPressed
                    ? .spring(response: 0.15, dampingFraction: 0.9)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: configuration.isPressed
            )
            .animation(
                reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.6),
                value: didCopy
            )
    }

    private func scaleValue(isPressed: Bool) -> CGFloat {
        if isPressed && !reduceMotion { return 0.97 }
        if didCopy && !reduceMotion { return 1.05 }
        return 1.0
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showingSheet = true
        var body: some View {
            Color.clear
                .sheet(isPresented: $showingSheet) {
                    PromptNoteDetailView(note: PromptNote(id: UUID(), title: "Example Prompt", content: "print(\"Hello, world!\")"))
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
        }
    }
    return PreviewWrapper()
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
