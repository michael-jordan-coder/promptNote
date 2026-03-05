import SwiftUI

struct AIModelBadge: View {
    @Binding private var model: AIModel
    private let tappable: Bool

    init(model: Binding<AIModel>) {
        self._model = model
        self.tappable = true
    }

    init(model: AIModel) {
        self._model = .constant(model)
        self.tappable = false
    }

    var body: some View {
        Group {
            if tappable {
                Menu {
                    Picker("Model", selection: $model) {
                        ForEach(AIModel.allCases, id: \.self) { option in
                            Text(option.displayName)
                                .tag(option)
                        }
                    }
                } label: {
                    badgeLabel(for: model, showsDisclosure: true)
                }
            } else {
                badgeLabel(for: model, showsDisclosure: false)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("AI model")
        .accessibilityValue(model.displayName)
    }

    private func badgeLabel(for aiModel: AIModel, showsDisclosure: Bool) -> some View {
        HStack(spacing: 8) {
            Image(aiModel.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .clipShape(Circle())

            Text(aiModel.displayName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)

            if showsDisclosure {
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.thinMaterial, in: Capsule())
        .contentShape(Capsule())
    }
}

#Preview("Read Only") {
    AIModelBadge(model: .claude)
}

#Preview("Editable") {
    StatefulPreviewWrapper(AIModel.chatgpt) { model in
        AIModelBadge(model: model)
    }
}

private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ value: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
