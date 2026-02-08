import SwiftUI
import HighlightSwift

struct PromptNoteView: View {

    @StateObject private var viewModel: PromptNoteViewModel
    @State private var isPresentingDetail = false
    @State private var appeared = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let appearIndex: Int

    // MARK: - Init
    init(note: PromptNote, appearIndex: Int = 0) {
        _viewModel = StateObject(
            wrappedValue: PromptNoteViewModel(note: note)
        )
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
            PromptNoteDetailView(note: viewModel.note)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Card Content
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            HStack {
                Text(viewModel.note.title)
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    viewModel.copy()
                } label: {
                    Image(systemName: viewModel.didCopy
                          ? "checkmark.circle.fill"
                          : "doc.on.doc")
                        .imageScale(.medium)
                        .foregroundStyle(viewModel.didCopy ? .green : .primary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
            }

            // Scrollable prompt content
            ScrollView {
                CodeText(viewModel.note.content)
                    .highlightLanguage(.markdown)
                    .font(Font.system(.subheadline, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 2)
            }
        }
        .padding(24)
        .background(Color(.systemGray6))
        .cornerRadius(24)
    }
}

#Preview {
    PromptNoteView(
        note: PromptNote(
            id: UUID(),
            title: "System Prompt",
            content: """
            You are an expert SwiftUI engineer.
            Follow MVVM strictly.
            Prefer clarity over cleverness.
            """
        )
    )
}
#Preview("List – Mock Prompts") {
    List(PromptNoteMockList.all, id: \ .id) { note in
        PromptNoteView(note: note)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
    .listStyle(.plain)
}
