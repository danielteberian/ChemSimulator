import ChemLabCore
import SwiftUI

/// Shows what the user has built: its name, formula, hazard icons, or what's missing.
struct InfoPanel: View {
    let reports: [MoleculeReport]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if reports.isEmpty {
                        Text("Nothing here yet. Add atoms and bond them to see what you've made.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(reports) { ReportCard(report: $0) }
                }
                .padding(12)
            }
        }
    }
}

private struct ReportCard: View {
    let report: MoleculeReport

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let id = report.identification {
                identified(id)
            } else if report.isComplete {
                header(title: report.formula.display, subtitle: "Complete, but no name is known for it yet.")
            } else {
                header(title: report.formula.display, subtitle: "Not finished yet")
                ForEach(report.issues.prefix(4), id: \.self) { issue in
                    Label(issue, systemImage: "circle.dotted")
                        .font(.callout)
                        .foregroundStyle(.orange)
                }
                if report.issues.count > 4 {
                    Text("and \(report.issues.count - 4) more").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
    }

    private func header(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.title3.bold().monospaced())
            Text(subtitle).font(.callout).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func identified(_ id: Identification) -> some View {
        Text(id.displayName).font(.title2.bold())
        HStack(spacing: 10) {
            Text(id.displayFormula).font(.title3.monospaced())
            Text(String(format: "%.3f g/mol", id.formula.molarMass))
                .font(.callout).foregroundStyle(.secondary)
        }

        if id.systematicName.lowercased() != id.displayName.lowercased() {
            detail("Systematic name", id.systematicName)
        }
        if !id.aliases.isEmpty {
            detail("Also known as", id.aliases.joined(separator: ", "))
        }
        if !id.isCatalogued {
            Label("Named by naming rules, not from the catalog", systemImage: "wand.and.stars")
                .font(.caption).foregroundStyle(.secondary)
        }
        if let note = id.isomerNote {
            Label(note, systemImage: "info.circle")
                .font(.caption).foregroundStyle(.secondary)
        }
        if !id.hazards.isEmpty {
            Divider()
            HazardIcons(notes: id.hazards)
        }
    }

    private func detail(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value)
        }
    }
}

/// The hazard symbols for a set of notes, icons only. The name of each hazard
/// is kept as its accessibility label.
struct HazardIcons: View {
    let notes: [HazardNote]

    var body: some View {
        let kinds = notes.map(\.hazard).reduce(into: [Hazard]()) { if !$0.contains($1) { $0.append($1) } }
        HStack(spacing: 8) {
            ForEach(kinds, id: \.self) { hazard in
                Image(systemName: hazard.symbolName)
                    .font(.title3)
                    .foregroundStyle(hazard.color)
                    .accessibilityLabel(hazard.title)
            }
        }
    }
}
