import ChemLabCore
import SwiftUI

/// Explains what is going on in the selected beaker: what is inside, which
/// hazard icons are showing, and every reaction with its "why did that
/// happen?" explanation.
struct BenchPanel: View {
    let beaker: Beaker

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if beaker.isEmpty {
                        Text("This beaker is empty. Pick something from the shelf to add.")
                            .foregroundStyle(.secondary)
                    } else {
                        contents
                    }

                    let hazards = beaker.activeHazards
                    if !hazards.isEmpty {
                        HazardIcons(notes: hazards)
                    }

                    if !beaker.events.isEmpty {
                        section("What happened") {
                            ForEach(Array(beaker.events.reversed().enumerated()), id: \.element.id) { index, event in
                                ReactionCard(event: event, startsOpen: index == 0)
                            }
                        }
                    }

                    let recent = Array(beaker.observations.suffix(6).reversed())
                    if !recent.isEmpty {
                        section("Log") {
                            ForEach(Array(recent.enumerated()), id: \.offset) { _, observation in
                                Text(observation.text).font(.callout).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(12)
            }
        }
    }

    private var contents: some View {
        section("In \(beaker.name)") {
            ForEach(beaker.gases + beaker.contents) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.species.color.color)
                        .overlay(Circle().stroke(Color.primary.opacity(0.3), lineWidth: 0.8))
                        .frame(width: 12, height: 12)
                    Text("\(item.species.name) \(item.state.label)")
                    Spacer(minLength: 8)
                    Text(String(format: "%.2f g", item.grams))
                        .font(.callout.monospaced())
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
            }
            HStack {
                Label(
                    beaker.openToAir ? "Open to air" : "Covered: no oxygen gets in",
                    systemImage: beaker.openToAir ? "wind" : "square.dashed.inset.filled")
                Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
        }
    }
}

private struct ReactionCard: View {
    let event: ReactionEvent
    @State private var showsWhy: Bool

    init(event: ReactionEvent, startsOpen: Bool) {
        self.event = event
        _showsWhy = State(initialValue: startsOpen)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.reaction.kind.title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(event.reaction.equation)
                .font(.title3.monospaced())
                .fixedSize(horizontal: false, vertical: true)

            if abs(event.heatReleased) >= 1 {
                Label(
                    event.heatReleased > 0
                        ? String(format: "Gave off about %.0f kJ of heat", event.heatReleased)
                        : String(format: "Absorbed about %.0f kJ of heat", -event.heatReleased),
                    systemImage: event.heatReleased > 0 ? "thermometer.high" : "thermometer.low"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            if !event.hazards.isEmpty { HazardIcons(notes: event.hazards) }

            DisclosureGroup("Why did that happen?", isExpanded: $showsWhy) {
                Text(event.why)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
    }
}
