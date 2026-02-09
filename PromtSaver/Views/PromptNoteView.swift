import SwiftUI
import HighlightSwift
import SwiftData

struct PromptNoteView: View {

    let note: PromptNote
    let appearIndex: Int

    @State private var isPresentingDetail = false
    @State private var appeared = false
    @State private var didCopy = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(note: PromptNote, appearIndex: Int = 0) {
        self.note = note
        self.appearIndex = appearIndex
    }

    // MARK: - View
    var body: some View {
        cardContent
            .scaleEffect(isPresentingDetail && !reduceMotion ? 0.96 : 1.0)
            .animation(
                reduceMotion ? .none :
                isPresentingDetail
                    ? .spring(response: 0.15, dampingFraction: 0.9)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: isPresentingDetail
            )
            .onTapGesture {
                isPresentingDetail = true
            }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            guard !appeared else { return }
            let delay = reduceMotion ? 0 : Double(min(appearIndex, 8)) * 0.06
            withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.7).delay(delay)) {
                appeared = true
            }
        }
        .sheet(isPresented: $isPresentingDetail) {
            PromptNoteDetailView(note: note)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Card Content
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            HStack {
                AIModelBadge(model: note.aiModel)

                Text(note.title)
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    copyToClipboard()
                } label: {
                    Image(systemName: didCopy
                          ? "checkmark.circle.fill"
                          : "doc.on.doc")
                        .imageScale(.medium)
                        .foregroundStyle(didCopy ? .green : .primary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
            }

            // Scrollable prompt content
            ScrollView {
                CodeText(note.content)
                    .highlightLanguage(.markdown)
                    .font(Font.system(.subheadline, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 2)
                    .id(note.content)
            }
        }
        .padding(24)
        .background(Color(.systemGray6))
        .cornerRadius(24)
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = note.content
        didCopy = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            didCopy = false
        }
    }
}

#Preview("SwiftUI Engineer") {
    PromptNoteView(note: .mockSystemSwiftUIEngineer)
        .modelContainer(PromptNoteMockList.previewContainer)
}

#Preview("Code Reviewer") {
    PromptNoteView(note: .mockSystemCodeReviewer)
        .modelContainer(PromptNoteMockList.previewContainer)
}

#Preview("Product Copywriter") {
    PromptNoteView(note: .mockSystemProductCopy)
        .modelContainer(PromptNoteMockList.previewContainer)
}
