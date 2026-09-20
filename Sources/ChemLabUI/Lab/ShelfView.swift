import ChemLabCore
import SwiftUI

/// The reagent shelf: pick a group, pick an amount, tap a substance to add it
/// to the selected beaker. Nothing on the shelf is ever locked or refused.
struct ShelfView: View {
    @Bindable var model: LabModel

    private var showsStrength: Bool {
        model.speciesOnShelf.contains { $0.hasSolutionForm }
    }

    var body: some View {
        VStack(spacing: 8) {
            Picker("Shelf", selection: $model.group) {
                ForEach(SpeciesGroup.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            HStack {
                Picker("Amount", selection: $model.amountIndex) {
                    Text("Small").tag(0)
                    Text("Medium").tag(1)
                    Text("Large").tag(2)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
                Spacer(minLength: 0)
            }

            if showsStrength {
                VStack(alignment: .leading, spacing: 2) {
                    Picker("Strength", selection: $model.strength) {
                        ForEach(ReagentStrength.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    Text("Acids and ammonia come as a solution. \"As sold\" is the strong reagent from the bottle.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                    ForEach(model.speciesOnShelf) { species in
                        ShelfCard(species: species, amountIndex: model.amountIndex) {
                            model.add(species)
                        }
                    }
                }
                .padding(2)
            }

            Text("Adds to \(model.beaker.name)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ShelfCard: View {
    let species: Species
    let amountIndex: Int
    let action: () -> Void

    private var amount: String {
        let choices = species.amountChoices
        return choices[min(max(amountIndex, 0), choices.count - 1)].label
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(species.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                HStack(spacing: 6) {
                    Text(species.displayFormula)
                        .font(.callout.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    ForEach(hazardKinds, id: \.self) { hazard in
                        Image(systemName: hazard.symbolName)
                            .font(.caption)
                            .foregroundStyle(hazard.color)
                    }
                }
                Text("+ \(amount)")
                    .font(.caption)
                    .foregroundStyle(.tint)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 8))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add \(amount) of \(species.name)")
    }

    private var hazardKinds: [Hazard] {
        var seen = Set<Hazard>()
        return species.hazards.map(\.hazard).filter { seen.insert($0).inserted }
    }
}
