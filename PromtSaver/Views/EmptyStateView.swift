import SwiftUI

struct EmptyStateView: View {
    let createAction: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var isPressed = false

    private let pressAnim: Animation = .spring(response: 0.12, dampingFraction: 0.9)
    private let overshootAnim: Animation = .spring(response: 0.4, dampingFraction: 0.55)

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "text.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Prompts Yet")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("Save your system prompts, templates, and snippets.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // CTA
            Button {
                createAction()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.body.weight(.semibold))

                    Text("Create Your First Prompt")
                        .font(.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .background {
                    Capsule()
                        .fill(Color.accentColor)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.96 : 1.0))
            .animation(reduceMotion ? .none : (isPressed ? pressAnim : overshootAnim), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed { isPressed = true }
                    }
                    .onEnded { _ in isPressed = false }
            )

            Spacer()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            guard !appeared else { return }
            withAnimation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.6).delay(0.1)) {
                appeared = true
            }
        }
    }
}

#Preview {
    EmptyStateView {
        print("Create tapped")
    }
}
