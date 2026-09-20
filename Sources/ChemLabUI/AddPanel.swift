import ChemLabCore
import SwiftUI

/// The "add something" area: single elements, or ready-made acids, bases and salts.
struct AddPanel: View {
    let model: BuilderModel
    /// The wide layout keeps the periodic table's proportions so the canvas above
    /// doesn't jump in size when switching tabs. Sheets don't need that.
    var keepsTableProportions = true

    private enum Mode: String, CaseIterable, Identifiable {
        case elements = "Elements"
        case acids = "Acids"
        case bases = "Bases"
        case salts = "Salts"
        case gases = "Gases"
        case oxides = "Oxides"
        case organics = "Organics"

        var id: String { rawValue }

        var group: CommonSubstance.Group? {
            switch self {
            case .elements: nil
            case .acids: CommonSubstance.Group.acid
            case .bases: CommonSubstance.Group.base
            case .salts: CommonSubstance.Group.salt
            case .gases: CommonSubstance.Group.gas
            case .oxides: CommonSubstance.Group.oxide
            case .organics: CommonSubstance.Group.organic
            }
        }
    }

    @State private var mode: Mode = .elements

    var body: some View {
        VStack(spacing: 8) {
            Picker("Add", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            if keepsTableProportions {
                // 18 columns by 9.5 rows (the f-block gap is half a row).
                Color.clear
                    .aspectRatio(18.0 / 9.5, contentMode: .fit)
                    .overlay { content }
            } else {
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let group = mode.group {
            SubstanceList(substances: SubstanceLibrary.substances(in: group)) { model.insert($0) }
        } else {
            PeriodicTablePicker(onSelect: { model.addAtom($0) })
        }
    }
}

struct SubstanceList: View {
    let substances: [CommonSubstance]
    var onSelect: (CommonSubstance) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: 8)], spacing: 8) {
                ForEach(substances) { substance in
                    SubstanceCard(substance: substance) { onSelect(substance) }
                }
            }
            .padding(2)
        }
    }
}

private struct SubstanceCard: View {
    let substance: CommonSubstance
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(substance.name)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(substance.displayFormula)
                        .font(.callout.monospaced())
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                    ForEach(substance.hazards, id: \.self) { hazard in
                        Image(systemName: hazard.symbolName)
                            .font(.caption)
                            .foregroundStyle(hazard.color)
                            .accessibilityLabel(hazard.title)
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 8))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add \(substance.name)")
    }
}
