import SwiftUI
import HighlightSwift
import SwiftData

struct PromptNoteView: View {
    @StateObject private var viewModel = PromptNoteCardViewModel()

    let note: PromptNote
    let appearIndex: Int
    let onDeleteIntent: (PromptNote) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let cardCornerRadius: CGFloat = 24

    init(
        note: PromptNote,
        appearIndex: Int = 0,
        onDeleteIntent: @escaping (PromptNote) -> Void = { _ in }
    ) {
        self.note = note
        self.appearIndex = appearIndex
        self.onDeleteIntent = onDeleteIntent
    }

    // MARK: - View
    var body: some View {
        cardContent
            .scaleEffect(viewModel.isPresentingDetail && !reduceMotion ? 0.96 : 1.0)
            .animation(
                reduceMotion ? .none :
                viewModel.isPresentingDetail
                    ? .spring(response: 0.15, dampingFraction: 0.9)
                    : .spring(response: 0.35, dampingFraction: 0.6),
                value: viewModel.isPresentingDetail
            )
            .onTapGesture {
                viewModel.presentDetail()
            }
            .accessibilityAction(named: Text("Delete")) {
                onDeleteIntent(note)
            }
            .accessibilityHint("Swipe left on the row to delete this prompt note.")
        .opacity(viewModel.appeared ? 1 : 0)
        .offset(y: viewModel.appeared ? 0 : 12)
        .onAppear {
            guard !viewModel.appeared else { return }
            let delay = viewModel.appearanceDelay(for: appearIndex, reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.7).delay(delay)) {
                viewModel.markAppeared()
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
        .sheet(isPresented: $viewModel.isPresentingDetail) {
            PromptNoteDetailView(note: note)
                .presentationDetents([.large])
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
                    viewModel.copy(content: note.content)
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

            // Prompt content preview
            CodeText(note.content)
                .highlightLanguage(.markdown)
                .font(Font.system(.subheadline, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
                .lineLimit(6)
                .id(note.content)
        }
        .padding(24)
        .background(Color(.systemGray6))
        .cornerRadius(cardCornerRadius)
    }
}


