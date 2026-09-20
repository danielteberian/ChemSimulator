import ChemLabCore
import SwiftUI

/// Shows what the user has built: its name, formula, hazards, or what's missing.
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
            Divider()
            Label(SafetyDisclaimer.short, systemImage: "exclamationmark.triangle")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(10)
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
                Label("Hazards not reviewed. Do not assume it is safe.", systemImage: "questionmark.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
        Divider()
        if id.hazards.isEmpty {
            // An empty list must never read as an all-clear.
            Label(
                id.isCatalogued
                    ? "No hazards are listed for this, which does not mean it is safe."
                    : "Hazards not reviewed. Do not assume it is safe.",
                systemImage: "questionmark.circle"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        } else {
            ForEach(id.hazards, id: \.self) { HazardRow(note: $0) }
        }
    }

    private func detail(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value)
        }
    }
}

struct HazardRow: View {
    let note: HazardNote

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: note.hazard.symbolName)
                .font(.title3)
                .foregroundStyle(note.hazard.color)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(note.hazard.title).font(.headline)
                Text(note.reason).font(.callout).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
