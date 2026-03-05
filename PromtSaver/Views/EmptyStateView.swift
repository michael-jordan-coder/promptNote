import SwiftUI

struct EmptyStateView: View {
    let createAction: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("No Prompts Yet", systemImage: "text.badge.plus")
        } description: {
            Text("Save your system prompts, templates, and snippets.")
        } actions: {
            Button("Create Your First Prompt", action: createAction)
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    EmptyStateView {
        print("Create tapped")
    }
}
