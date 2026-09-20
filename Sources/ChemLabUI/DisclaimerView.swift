import ChemLabCore
import SwiftUI

/// Safety notice shown on first launch and from the About & Safety button.
struct DisclaimerView: View {
    var buttonTitle = "I understand"
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Simulation only", systemImage: "exclamationmark.triangle.fill")
                .font(.title2.bold())
                .foregroundStyle(.orange)

            Text(SafetyDisclaimer.full)

            Text(
                "You are free to build and mix anything here, including dangerous things. "
                    + "That is how you learn what makes them dangerous. ChemLab marks hazards "
                    + "and explains why."
            )
            .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button(buttonTitle, action: onDismiss)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(maxWidth: 460)
    }
}
