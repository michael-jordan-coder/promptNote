import SwiftUI
import HighlightSwift

struct PromptNoteView: View {

    @StateObject private var viewModel: PromptNoteViewModel
    @State private var isPresentingDetail = false

    // MARK: - Init
    init(note: PromptNote) {
        _viewModel = StateObject(
            wrappedValue: PromptNoteViewModel(note: note)
        )
    }

    // MARK: - View
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            HStack {
                Text(viewModel.note.title)
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                Button {
                    viewModel.copy()
                } label: {
                    Image(systemName: viewModel.didCopy
                          ? "checkmark.circle.fill"
                          : "doc.on.doc")
                        .imageScale(.medium)
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
        .onTapGesture {
            isPresentingDetail = true
        }
        .sheet(isPresented: $isPresentingDetail) {
            PromptNoteDetailView(note: viewModel.note)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
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

