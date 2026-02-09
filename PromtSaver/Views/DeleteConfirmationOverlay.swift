import SwiftUI

struct DeleteConfirmationOverlay: View {
    let noteTitle: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black
                .opacity(hasAppeared ? 0.45 : 0)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Are you sure?")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)

                    Text("Delete \"\(noteTitle)\"? This action cannot be undone.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }

                HStack(spacing: 12) {
                    Button("Cancel", role: .cancel) {
                        onCancel()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5), in: Capsule())

                    Button("Delete", role: .destructive) {
                        onConfirm()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(Color.red, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .frame(maxWidth: 340)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 20, y: 10)
            .opacity(hasAppeared ? 1 : 0)
            .scaleEffect(reduceMotion ? 1 : (hasAppeared ? 1 : 0.97))
        }
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.28, dampingFraction: 0.86)) {
                hasAppeared = true
            }
        }
        .onDisappear {
            hasAppeared = false
        }
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    DeleteConfirmationOverlay(
        noteTitle: "Senior SwiftUI Engineer",
        onCancel: {},
        onConfirm: {}
    )
}
