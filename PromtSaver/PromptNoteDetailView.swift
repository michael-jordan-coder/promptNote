import SwiftUI
import HighlightSwift

struct PromptNoteDetailView: View {
    @StateObject private var viewModel: PromptNoteDetailViewModel
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
            }

            Button {
                viewModel.copy()
            } label: {
                Label(viewModel.didCopy ? "Copied" : "Copy Prompt",
                      systemImage: viewModel.didCopy ? "checkmark.circle.fill" : "doc.on.doc")
                    .frame(maxWidth: .infinity)
                    .animation(.default, value: viewModel.didCopy)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityLabel("Copy content")
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .background(.regularMaterial)
        .cornerRadius(16, corners: [.topLeft, .topRight])
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
