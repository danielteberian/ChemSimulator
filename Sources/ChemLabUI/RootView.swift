import ChemLabCore
import SwiftUI

/// The whole app: the molecule builder, the lab, and the learning layer.
public struct ChemLabRootView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case builder = "Builder"
        case lab = "Lab"
        case learn = "Learn"

        var id: String { rawValue }

        var symbolName: String {
            switch self {
            case .builder: "atom"
            case .lab: "flask"
            case .learn: "book"
            }
        }
    }

    @State private var mode: Mode = .builder
    // Both models live here so switching modes doesn't throw away the user's work.
    @State private var builder: BuilderModel
    @State private var lab: LabModel

    public init() {
        _builder = State(initialValue: BuilderModel())
        _lab = State(initialValue: LabModel())
    }

    public var body: some View {
        VStack(spacing: 0) {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Label($0.rawValue, systemImage: $0.symbolName).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 420)
            .padding(.top, 10)

            switch mode {
            case .builder:
                BuilderView(model: builder)
            case .lab:
                LabView(model: lab)
            case .learn:
                LearnView(model: lab) { mode = .lab }
            }
        }
    }
}
