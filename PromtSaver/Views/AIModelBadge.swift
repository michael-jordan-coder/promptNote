import SwiftUI

struct AIModelBadge: View {
    @Binding var model: AIModel
    let tappable: Bool

    @State private var isExpanded = false
    @State private var visibleOptions: [AIModel] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let badgeSize: CGFloat = 28
    private let staggerDelay: Double = 0.06

    init(model: Binding<AIModel>) {
        self._model = model
        self.tappable = true
    }

    init(model: AIModel) {
        self._model = .constant(model)
        self.tappable = false
    }

    private var options: [AIModel] {
        AIModel.allCases.filter { $0 != model }
    }

    var body: some View {
        HStack(spacing: 6) {
            selectedBadge

            ForEach(options, id: \.self) { option in
                if visibleOptions.contains(option) {
                    optionBadge(for: option)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .accessibilityLabel(model.displayName)
    }

    // MARK: - Selected badge
    private var selectedBadge: some View {
        Button {
            guard tappable else { return }
            if isExpanded {
                collapse()
            } else {
                expand()
            }
        } label: {
            badgeImage(for: model)
        }
        .buttonStyle(.plain)
        .disabled(!tappable)
    }

    // MARK: - Option badge
    private func optionBadge(for option: AIModel) -> some View {
        Button {
            let selected = option
            collapse {
                model = selected
            }
        } label: {
            badgeImage(for: option)
                .opacity(0.7)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Expand with stagger
    private func expand() {
        isExpanded = true
        for (index, option) in options.enumerated() {
            let delay = reduceMotion ? 0 : Double(index) * staggerDelay
            withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.6).delay(delay)) {
                visibleOptions.append(option)
            }
        }
    }

    // MARK: - Collapse with reverse stagger
    private func collapse(completion: (() -> Void)? = nil) {
        let reversed = visibleOptions.reversed()
        for (index, option) in reversed.enumerated() {
            let delay = reduceMotion ? 0 : Double(index) * staggerDelay
            withAnimation(reduceMotion ? .none : .spring(response: 0.15, dampingFraction: 0.9).delay(delay)) {
                visibleOptions.removeAll { $0 == option }
            }
        }
        let totalDuration = reduceMotion ? 0 : Double(reversed.count) * staggerDelay + 0.15
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            isExpanded = false
            completion?()
        }
    }

    // MARK: - Shared image
    private func badgeImage(for aiModel: AIModel) -> some View {
        Image(aiModel.iconName)
            .resizable()
            .scaledToFit()
            .frame(width: badgeSize, height: badgeSize)
            .clipShape(Circle())
            .contentShape(Circle())
    }
}
